import sys
import time
import math
import json
import urllib
import httplib
import os.path
import datetime
import urlparse
import optparse
import decode, compose

parser = optparse.OptionParser(usage="""poll.py [options]
""")

parser.add_option('-p', '--password', dest='password',
                  help='Paperwalking queue password',
                  action='store')

parser.add_option('-b', '--apibase', dest='apibase',
                  help='URL root of queue API',
                  action='store')

def getMarkers():
    """
    """
    markers = {}

    for basename in ('Header', 'Hand', 'CCBYSA'):
        basepath = os.path.dirname(os.path.realpath(__file__)) + '/corners/' + basename
        markers[basename] = decode.Marker(basepath)

    return markers

def updateQueue(apibase, password, message_id, timeout):
    """
    """
    params = {'id': message_id, 'password': password}

    if timeout is False:
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
    
    s, host, path, p, q, f = urlparse.urlparse(options.apibase)
    
    poll_failures = 0

    while True:
        try:
            params = urllib.urlencode({'timeout': 5, 'password': options.password})
            
            req = httplib.HTTPConnection(host, 80)
            req.request('POST', path+'/dequeue.php', params, {'Content-Type': 'application/x-www-form-urlencoded'})
            res = req.getresponse()
            
            assert res.status == 200, 'poll POST to dequeue.php resulting in status %s instead of 200' % res.status
            
            # success means we drop back to zero
            poll_failures = 0
            
            try:
                message_id, content = res.read().split()
                message_id = int(message_id)
            except ValueError:
                # probably no queue message
                pass
            else:
                try:
                    message = json.loads(content)
                    
                    print_id, url, paper = [message[p] for p in ('print_id', 'geotiff_url', 'paper_size')]

                    print >> sys.stderr, datetime.datetime.now(), 'Decoding message id', message_id, '-', url
                    progress = compose.main(print_id, url, paper, options.apibase.rstrip('/'), options.password)
                    
                except ValueError:
                    if content.startswith('http://'):
                        url = content

                        print >> sys.stderr, datetime.datetime.now(), 'Decoding message id', message_id, '-', url
                        progress = decode.main(url, getMarkers(), options.apibase.rstrip('/'), options.password)

                    else:
                        raise Exception('Not sure what to do with this message: ' + content)
                
                for timeout in progress:
                    updateQueue(options.apibase.rstrip('/'), options.password, message_id, timeout)

        except KeyboardInterrupt:
            raise

        except Exception, e:
            print >> sys.stderr, 'Something went wrong:', e
            raise e

            poll_failures += 1
            
            if poll_failures > 10:
                print >> sys.stderr, 'No, seriously.'
                raise

        if len(args) and args[0] == 'once':
            break

        # exponential back off
        time.sleep(math.pow(2, poll_failures))
