from array import array
from urllib import urlencode
from urlparse import urlparse, urlunparse, urljoin
from os.path import dirname, basename
from httplib import HTTPConnection
from xml.etree import ElementTree
from mimetypes import guess_type

def finish_print(apibase, password, print_id, pdf_url, preview_url, print_data):
    """
    """
    s, host, path, p, q, f = urlparse(apibase)
    host, port = (':' in host) and host.split(':') or (host, 80)
    
    #if urlparse(print_data_url)[1] == 'localhost':
    #    # just use an absolute path for preview URL if it's on localhost
    #    parts = urlparse(print_data_url)
    #    print_data_url = urlunparse((None, None, parts[2], parts[3], parts[4], parts[5]))
    
    headers = {'Content-Type': 'application/x-www-form-urlencoded'}
    
    query = urlencode({'id': print_id})
    params = urlencode({'password': password,
                        'last_step': 6,
                        'pdf_url': pdf_url,
                        'preview_url': preview_url,
                        'print_data': print_data})
    
    req = HTTPConnection(host, port)
    req.request('POST', path + '/print.php?' + query, params, headers)
    res = req.getresponse()
    
    assert res.status == 200, 'POST to print.php resulting in status %s instead of 200' % res.status

    return

def append_print_file(print_id, file_path, file_contents, apibase, password):
    """ Upload a file via the API append.php form input provision thingie.
    """

    s, host, path, p, q, f = urlparse(apibase)
    host, port = (':' in host) and host.split(':') or (host, 80)
    
    query = urlencode({'print': print_id, 'password': password,
                       'dirname': dirname(file_path),
                       'mimetype': (guess_type(file_path)[0] or '')})
    
    req = HTTPConnection(host, port)
    req.request('GET', path + '/append.php?' + query)
    res = req.getresponse()
    
    html = ElementTree.parse(res)
    
    for form in html.findall('*/form'):
        form_action = form.attrib['action']
        
        inputs = form.findall('.//input')
        
        file_inputs = [input for input in inputs if input.attrib['type'] == 'file']
        
        fields = [(input.attrib['name'], input.attrib['value'])
                  for input in inputs
                  if input.attrib['type'] != 'file' and 'name' in input.attrib]
        
        files = [(input.attrib['name'], basename(file_path), file_contents)
                 for input in inputs
                 if input.attrib['type'] == 'file']

        if len(files) == 1:
            base_url = [el.text for el in form.findall(".//*") if el.get('id', '') == 'base-url'][0]
            resource_url = urljoin(base_url, file_path)
        
            post_type, post_body = encode_multipart_formdata(fields, files)
            
            s, host, path, p, query, f = urlparse(urljoin(apibase, form_action))
            host, port = (':' in host) and host.split(':') or (host, 80)
            
            req = HTTPConnection(host, port)
            req.request('POST', path+'?'+query, post_body, {'Content-Type': post_type, 'Content-Length': str(len(post_body))})
            res = req.getresponse()
            
            # res.read().startswith("Sorry, encountered error #1 ")
            
            assert res.status in range(200, 308), 'POST of file to %s resulting in status %s instead of 2XX/3XX' % (host, res.status)

            return resource_url
        
    raise Exception('Did not find a form with a file input, why is that?')

def encode_multipart_formdata(fields, files):
    """ fields is a sequence of (name, value) elements for regular form fields.
        files is a sequence of (name, filename, value) elements for data to be uploaded as files
        Return (content_type, body) ready for httplib.HTTP instance
        
        Adapted from http://aspn.activestate.com/ASPN/Cookbook/Python/Recipe/146306
    """
    BOUNDARY = '----------multipart-boundary-multipart-boundary-multipart-boundary$'
    CRLF = '\r\n'

    content_type = 'multipart/form-data; boundary=%s' % BOUNDARY
    bytes = array('c')

    for (key, value) in fields:
        bytes.fromstring('--' + BOUNDARY + CRLF)
        bytes.fromstring('Content-Disposition: form-data; name="%s"' % key + CRLF)
        bytes.fromstring(CRLF)
        bytes.fromstring(value + CRLF)

    for (key, filename, value) in files:
        bytes.fromstring('--' + BOUNDARY + CRLF)
        bytes.fromstring('Content-Disposition: form-data; name="%s"; filename="%s"' % (key, filename) + CRLF)
        bytes.fromstring('Content-Type: %s' % (guess_type(filename)[0] or 'application/octet-stream') + CRLF)
        bytes.fromstring(CRLF)
        bytes.fromstring(value + CRLF)

    bytes.fromstring('--' + BOUNDARY + '--' + CRLF)

    return content_type, bytes.tostring()
