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

import compose2, decode2
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

if __name__ == '__main__':

    (options, args) = parser.parse_args()
    
    if len(args) and args[0] == 'once':
        due = time.time()
    
    elif len(args) and args[0].isdigit():
        due = time.time() + float(args[0])
    
    else:
        due = time.time() + 60
    
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

                    if action == 'decode' and prints_only:
                        updateQueue(apibase, password, message_id, 15)
                        time.sleep(2)
                        continue

                    print >> sys.stderr, '_' * 80
        
                    if action == 'decode':
                        if 'url' not in msg:
                            # we're no longer set up to handle these.
                            print >> sys.stderr, datetime.datetime.now(), 'No URL in message id', message_id, "so we'll just pretend it never happened."

                            updateQueue(apibase, password, message_id, ALL_FINISHED)
                            continue
                        
                        url = msg['url']

                        print >> sys.stderr, datetime.datetime.now(), 'Decoding message id', message_id, '- scan', msg['scan_id']
                        progress = decode2.main(apibase, password, msg['scan_id'], url, getMarkers())
                    
                    elif action == 'compose':
                        kwargs = {'paper_size': msg['paper_size']}
                        
                        try:
                            kwargs['geotiff_url'] = msg['geotiff_url']
                        except KeyError:
                            kwargs['provider'] = msg['provider']
                            kwargs['orientation'] = msg['orientation']
                            kwargs['layout'] = msg['layout']
                            kwargs['bounds'] = msg['bounds']
                            kwargs['zoom'] = msg['zoom']
    
                        print >> sys.stderr, datetime.datetime.now(), 'Decoding message id', message_id, '- print', msg['print_id']
                        progress = compose2.main(apibase, password, msg['print_id'], **kwargs)
                
                try:
                    for timeout in progress:
                        # push back the message in time
                        updateQueue(apibase, password, message_id, timeout)

                except KeyboardInterrupt:
                    raise
        
                except Exception, e:
                    print >> sys.stderr, datetime.datetime.now(), 'Error in message id', message_id, '-', e
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
