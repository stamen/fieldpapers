import os
import sys
import time
import math
import json
import time
import urllib
import httplib
import os.path
import datetime
import urlparse
import optparse
from itertools import chain

import compose2, decode2, forms
from apiutils import ALL_FINISHED

from decode import Marker

parser = optparse.OptionParser(usage="""poll.py [options]
""")

parser.set_defaults(prints_only=False)

parser.add_option('-p', '--password', dest='password',
                  help='Paperwalking queue password',
                  action='store')

parser.add_option('-b', '--apibase', dest='apibase',
                  help='URL root of queue API',
                  action='store')

parser.add_option('--prints-only', dest='prints_only',
                  help='Just do prints, no scans',
                  action='store_true')

def getMarkers():
    """
    """
    markers = {}
    basepath = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'corners')

    for basename in ('Header', 'Hand', 'CCBYSA'):
        markers[basename] = Marker(os.path.join(basepath, basename))

    markers['Sticker'] = Marker(os.path.join(basepath, 'mrs-star'))
    
    return markers

def updateQueue(apibase, password, message_id, timeout):
    """
    """
    s, host, path, p, q, f = urlparse.urlparse(apibase.rstrip('/'))
    host, port = (':' in host) and host.split(':') or (host, '80')

    params = {'id': message_id, 'password': password}

    if timeout == ALL_FINISHED:
        params['delete'] = 'yes'
    else:
        params['timeout'] = timeout
    
    headers = {'Content-Type': 'application/x-www-form-urlencoded'}

    req = httplib.HTTPConnection(host, 80)
    req.request('POST', path + '/dequeue.php', urllib.urlencode(params), headers)
    res = req.getresponse()
    
    assert res.status == 200, 'POST to dequeue.php resulting in status %s instead of 200' % res.status
    
    return

def decodeScan(apibase, password, message_id, msg):
    """
    """
    url = msg['url']

    print >> sys.stderr, datetime.datetime.now(), 'Decoding message id', message_id, '- scan', msg['scan_id']
    return decode2.main(apibase, password, msg['scan_id'], url)

def composePrint(apibase, password, message_id, msg):
    """
    """
    kwargs = dict(print_id=msg['print_id'],
                  paper_size=msg['paper_size'],
                  orientation=msg['orientation'],
                  layout=msg.get('layout', 'full-page'),
                  pages=msg['pages'])
    
    if 'form_id' in msg and 'form_url' in msg:
        def on_fields(fields):
            for page in msg['pages']:
                page['text'] = forms.fields_as_text(fields)
        
        print_progress = compose2.main(apibase, password, **kwargs)
        form_progress = forms.main(apibase, password, msg['form_id'], msg['form_url'], on_fields)

        print >> sys.stderr, datetime.datetime.now(), 'Decoding message id', message_id, '- print', msg['print_id'], 'and form', msg['form_id']
        progress = chain(form_progress, print_progress)
    
    else:
        print >> sys.stderr, datetime.datetime.now(), 'Decoding message id', message_id, '- print', msg['print_id']
        progress = compose2.main(apibase, password, **kwargs)

    return progress

def parseForm(apibase, password, message_id, msg):
    """
    """
    print >> sys.stderr, datetime.datetime.now(), 'Decoding message id', message_id, '- parsing a form.'
    return forms.main(apibase, password, msg['form_id'], msg['url'])

if __name__ == '__main__':

    if os.path.dirname(__file__):
        os.chdir(os.path.dirname(__file__))

    (options, args) = parser.parse_args()
    
    if len(args) and args[0] == 'once':
        due = time.time()
    
    elif len(args) and args[0].isdigit():
        due = time.time() + float(args[0])
    
    else:
        due = time.time() + 60
    
    print >> sys.stderr, 'Polling for %d seconds...' % round(due - time.time())
    
    s, host, path, p, q, f = urlparse.urlparse(options.apibase.rstrip('/'))
    host, port = (':' in host) and host.split(':') or (host, '80')
    
    prints_only = options.prints_only
    apibase = options.apibase.rstrip('/')
    password = options.password
    
    poll_failures = 0

    while True:
        try:
            params = urllib.urlencode({'timeout': 5, 'password': password})
            
            req = httplib.HTTPConnection(host, 80)
            req.request('POST', path+'/dequeue.php', params, {'Content-Type': 'application/x-www-form-urlencoded'})
            res = req.getresponse()
            
            if res.status == 503:
                retry = int(res.getheader('Retry-After', 60))
                print >> sys.stderr, 'poll POST to dequeue.php resulted in status 503; will sleep for %d seconds' % retry
                time.sleep(retry)
                continue
            
            assert res.status == 200, 'poll POST to dequeue.php resulting in status %s instead of 200' % res.status
            
            # success means we drop back to zero
            poll_failures = 0
            
            try:
                message_id, content = res.read().split(' ', 1)
                message_id = int(message_id)
            except ValueError:
                # probably no queue message
                pass
            else:
                try:
                    msg = json.loads(content)
                    
                except ValueError:
                    # who knows
                    raise Exception('Not sure what to do with this message: ' + content)

                else:
                    # JSON parse succeeded so we'll determine if there's a print or scan here.
                    action = msg.get('action', 'compose')

                    if action != 'compose' and prints_only:
                        updateQueue(apibase, password, message_id, 15)
                        time.sleep(2)
                        continue

                    print >> sys.stderr, '_' * 80
        
                    if action == 'decode':
                        progress = decodeScan(apibase, password, message_id, msg)
                    
                    elif action == 'compose':
                        progress = composePrint(apibase, password, message_id, msg)
                    
                    elif action == 'import form':
                        progress = parseForm(apibase, password, message_id, msg)
                
                try:
                    for timeout in progress:
                        # push back the message in time
                        updateQueue(apibase, password, message_id, timeout)

                except KeyboardInterrupt:
                    raise
        
                except Exception, e:
                    print >> sys.stderr, datetime.datetime.now(), 'Error in message id', message_id, '-', e
                    raise
                    updateQueue(apibase, password, message_id, ALL_FINISHED)

                ## clean out the queue message
                #updateQueue(apibase, password, message_id, False)

        except KeyboardInterrupt:
            raise

        except Exception:
            raise
            
            print >> sys.stderr, 'Something went wrong:', e

            poll_failures += 1
            
            if poll_failures > 10:
                print >> sys.stderr, 'No, seriously.'
                raise

        if time.time() >= due:
            break

        # exponential back off
        time.sleep(math.pow(2, poll_failures))
