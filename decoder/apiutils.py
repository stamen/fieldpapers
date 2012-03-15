from array import array
from urllib import urlencode
from urlparse import urlparse, urlunparse, urljoin
from os.path import dirname, basename
from httplib import HTTPConnection
from xml.etree import ElementTree
from mimetypes import guess_type

# yield this value from decode and compose main() in lieu of a timeout
ALL_FINISHED = -1

def _prepare_http_connection(url):
    """
    """
    s, host, path, p, q, f = urlparse(url)
    host, port = (':' in host) and host.split(':') or (host, 80)
    
    return HTTPConnection(host, port), path

def update_print(apibase, password, print_id, progress):
    """
    """
    headers = {'Content-Type': 'application/x-www-form-urlencoded'}
    query = urlencode({'id': print_id})

    params = urlencode(dict(progress=progress, password=password))
    
    req, path = _prepare_http_connection(apibase)
    req.request('POST', path + '/update-print.php?' + query, params, headers)
    res = req.getresponse()
    
    assert res.status == 200, 'POST to update-print.php resulting in status %s instead of 200' % res.status

    return

def finish_print(apibase, password, print_id, print_info):
    """
    """
    #if urlparse(print_data_url)[1] == 'localhost':
    #    # just use an absolute path for preview URL if it's on localhost
    #    parts = urlparse(print_data_url)
    #    print_data_url = urlunparse((None, None, parts[2], parts[3], parts[4], parts[5]))
    
    headers = {'Content-Type': 'application/x-www-form-urlencoded'}
    query = urlencode({'id': print_id})

    print_info.update(dict(password=password))
    params = urlencode(print_info)
    
    req, path = _prepare_http_connection(apibase)
    req.request('POST', path + '/finish-print.php?' + query, params, headers)
    res = req.getresponse()
    
    assert res.status == 200, 'POST to finish-print.php resulting in status %s instead of 200' % res.status

    return

def update_scan(apibase, password, scan_id, progress):
    
    """
    """
    headers = {'Content-Type': 'application/x-www-form-urlencoded'}
    query = urlencode({'id': scan_id})
    
    params = urlencode({'password': password,
                        'progress': progress})
    
    req, path = _prepare_http_connection(apibase)
    req.request('POST', path + '/update-scan.php?' + query, params, headers)
    res = req.getresponse()
    
    assert res.status == 200, 'POST to update-scan.php resulting in status %s instead of 200' % res.status

    return

def finish_scan(apibase, password, scan_id, uploaded_file, print_id, print_page_number, print_href, min_coord, max_coord, geojpeg_bounds):
    """
    """
    headers = {'Content-Type': 'application/x-www-form-urlencoded'}
    query = urlencode({'id': scan_id})
    
    params = urlencode({'print_id': print_id,
                        'print_page_number': print_page_number,
                        'print_href': print_href,
                        'password': password,
                        'uploaded_file': uploaded_file,
                        'has_geotiff': 'yes',
                        'has_geojpeg': 'yes',
                        'has_stickers': 'no',
                        'min_row': min_coord.row, 'max_row': max_coord.row,
                        'min_column': min_coord.column, 'max_column': max_coord.column,
                        'min_zoom': min_coord.zoom, 'max_zoom': max_coord.zoom,
                        'geojpeg_bounds': '%.8f,%.8f,%.8f,%.8f' % geojpeg_bounds})
    
    req, path = _prepare_http_connection(apibase)
    req.request('POST', path + '/finish-scan.php?' + query, params, headers)
    res = req.getresponse()
    
    assert res.status == 200, 'POST to finish-scan.php resulting in status %s instead of 200' % res.status

    return

def fail_scan(apibase, password, scan_id):
    """
    """
    s, host, path, p, q, f = urlparse(apibase)
    host, port = (':' in host) and host.split(':') or (host, 80)
    
    headers = {'Content-Type': 'application/x-www-form-urlencoded'}
    
    query = urlencode({'id': scan_id})
    params = urlencode({'password': password})
    
    req = HTTPConnection(host, port)
    req.request('POST', path + '/fail-scan.php?' + query, params, headers)
    res = req.getresponse()
    
    assert res.status == 200, 'POST to fail-scan.php resulting in status %s instead of 200' % res.status

    return

def finish_form(apibase, password, form_id, action_url, http_method, title, fields):
    """
    """
    s, host, path, p, q, f = urlparse(apibase)
    host, port = (':' in host) and host.split(':') or (host, 80)
    
    headers = {'Content-Type': 'application/x-www-form-urlencoded'}
    
    params = dict(password=password, action_url=action_url, http_method=http_method, title=title)
    
    for (index, field) in enumerate(fields):
        params['fields[%d][name]' % index] = field['name']
        params['fields[%d][label]' % index] = field['label']
        params['fields[%d][type]' % index] = field['type']
    
    query = urlencode({'id': form_id})
    params = urlencode(params)
    
    req = HTTPConnection(host, port)
    req.request('POST', path + '/finish-form.php?' + query, params, headers)
    res = req.getresponse()
    
    assert res.status == 200, 'POST to finish-form.php resulting in status %s instead of 200' % res.status

    return

def fail_form(apibase, password, form_id):
    """
    """
    s, host, path, p, q, f = urlparse(apibase)
    host, port = (':' in host) and host.split(':') or (host, 80)
    
    headers = {'Content-Type': 'application/x-www-form-urlencoded'}
    
    query = urlencode({'id': form_id})
    params = urlencode({'password': password})
    
    req = HTTPConnection(host, port)
    req.request('POST', path + '/fail-form.php?' + query, params, headers)
    res = req.getresponse()
    
    assert res.status == 200, 'POST to fail-form.php resulting in status %s instead of 200' % res.status

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
    req.request('GET', path + '/append.php?' + query, headers=dict(Accept='application/paperwalking+xml'))
    res = req.getresponse()
    
    form = ElementTree.parse(res).getroot()
    
    if form.tag == 'form':
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

def append_scan_file(scan_id, file_path, file_contents, apibase, password):
    """ Upload a file via the API append.php form input provision thingie.
    """

    s, host, path, p, q, f = urlparse(apibase)
    host, port = (':' in host) and host.split(':') or (host, 80)
    
    query = urlencode({'scan': scan_id, 'password': password,
                       'dirname': dirname(file_path),
                       'mimetype': (guess_type(file_path)[0] or '')})
    
    req = HTTPConnection(host, port)
    req.request('GET', path + '/append.php?' + query, headers=dict(Accept='application/paperwalking+xml'))
    res = req.getresponse()
    
    form = ElementTree.parse(res).getroot()
    
    if form.tag == 'form':
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
            post_type, post_body = encode_multipart_formdata(fields, files)
            
            s, host, path, p, query, f = urlparse(urljoin(apibase, form_action))
            host, port = (':' in host) and host.split(':') or (host, 80)
            
            req = HTTPConnection(host, port)
            req.request('POST', path+'?'+query, post_body, {'Content-Type': post_type, 'Content-Length': str(len(post_body))})
            res = req.getresponse()
            
            # res.read().startswith("Sorry, encountered error #1 ")
            
            assert res.status in range(200, 308), 'POST of file to %s resulting in status %s instead of 2XX/3XX' % (host, res.status)

            return True
        
    raise Exception('Did not find a form with a file input, why is that?')

def get_print_info(print_url):
    """
    """
    s, host, path, p, query, f = urlparse(print_url)
    host, port = (':' in host) and host.split(':') or (host, 80)
    
    req = HTTPConnection(host, port)
    req.request('GET', path + '?' + query, headers=dict(Accept='application/paperwalking+xml'))
    res = req.getresponse()
    
    print_ = ElementTree.parse(res).getroot()
    
    print_id = print_.attrib['id']
    paper = print_.find('paper').attrib['size']
    orientation = print_.find('paper').attrib['orientation']
    layout = print_.find('paper').attrib.get('layout', 'full-page')

    north = float(print_.find('bounds').find('north').text)
    south = float(print_.find('bounds').find('south').text)
    east = float(print_.find('bounds').find('east').text)
    west = float(print_.find('bounds').find('west').text)
    
    return print_id, north, west, south, east, paper, orientation, layout

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
