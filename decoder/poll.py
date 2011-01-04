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
    basepath = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'corners')

    for basename in ('Header', 'Hand', 'CCBYSA'):
        markers[basename] = decode.Marker(os.path.join(basepath, basename))

    markers['Sticker'] = decode.Marker(os.path.join(basepath, 'mrs-star'))
    
    return markers

def updateQueue(apibase, password, message_id, timeout):
    """
    """
    s, host, path, p, q, f = urlparse.urlparse(apibase.rstrip('/'))
    host, port = (':' in host) and host.split(':') or (host, '80')

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
    
    s, host, path, p, q, f = urlparse.urlparse(options.apibase.rstrip('/'))
    host, port = (':' in host) and host.split(':') or (host, '80')
    
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
                    # JSON parse failed so it's likely we've got a scan to do.
                    # This is legacy behavior - all messages are now JSON.

                    if content.startswith('http://'):
                        url = content.strip()

                        print >> sys.stderr, datetime.datetime.now(), 'Decoding message id', message_id, '-', url
                        progress = decode.main(None, url, getMarkers(), apibase, password, None, True)

                    else:
                        raise Exception('Not sure what to do with this message: ' + content)

                else:
                    # JSON parse successed so we'll look at the intended action.

                    if msg['action'] == 'compose':
                        #
                        # Compose a new map.
                        #
                        kwargs = {'paper_size': msg['paper_size']}
                        
                        if 'geotiff_url' in msg:
                            kwargs['geotiff_url'] = msg['geotiff_url']
                        else:
                            kwargs['provider'] = msg['provider']
                            kwargs['orientation'] = msg['orientation']
                            kwargs['layout'] = msg['layout']
                            kwargs['bounds'] = msg['bounds']
                            kwargs['zoom'] = msg['zoom']
    
                        print >> sys.stderr, datetime.datetime.now(), 'Decoding message id', message_id, '- print', msg['print_id']
                        progress = compose.main(apibase, password, msg['print_id'], **kwargs)

                    elif msg['action'] == 'decode':
                        #
                        # Decode a scan.
                        #
                        scan_id = msg['scan_id']
                        image_url = msg['image_url']
                        
                        kwargs = {'qrcode_contents': msg.get('qrcode_contents', None)}
                        
                        if 'markers' in msg:
                            kwargs['do_sifting'] = False
                            markers = [(name, xy) for (name, xy) in msg['markers'].items()]
                            markers = [(n, decode.Minimarker(**xy)) for (n, xy) in markers]
                            markers = dict(markers)
                        else:
                            kwargs['do_sifting'] = True
                            markers = getMarkers()
                        
                        print >> sys.stderr, datetime.datetime.now(), 'Decoding message id', message_id, '- scan', scan_id
                        progress = decode.main(scan_id, image_url, markers, apibase, password, **kwargs)
                
                for timeout in progress:
                    updateQueue(apibase, password, message_id, timeout)

        except KeyboardInterrupt:
            raise

        except Exception, e:
            print >> sys.stderr, 'Something went wrong:', e

            poll_failures += 1
            
            if poll_failures > 10:
                print >> sys.stderr, 'No, seriously.'
                raise

        if len(args) and args[0] == 'once':
            break

        # exponential back off
        time.sleep(math.pow(2, poll_failures))
