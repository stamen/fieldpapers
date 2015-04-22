import sys

from urlparse import urljoin
from os.path import dirname, basename
from xml.etree import ElementTree
from mimetypes import guess_type
from StringIO import StringIO

import requests


def update_print(apibase, password, print_id, progress):
    """
    """
    params = {'id': print_id}
    data = dict(progress=progress, password=password)
    
    res = requests.post(urljoin(apibase, '/update-atlas.php'), params=params, data=data)
    
    assert res.status_code == 200, 'POST to update-atlas.php resulting in status %s instead of 200' % res.status


def finish_print(apibase, password, print_id, print_info):
    """
    """
    params = {'id': print_id}
    print_info.update(dict(password=password))
    
    res = requests.post(urljoin(apibase, '/finish-atlas.php'), params=params, data=print_info)
    
    assert res.status_code == 200, 'POST to finish-atlas.php resulting in status %s instead of 200' % res.status


def update_scan(apibase, password, scan_id, progress):
    """
    """
    params = {'id': scan_id}
    
    data = {'password': password,
            'progress': progress}
    
    res = requests.post(urljoin(apibase, '/update-scan.php'), params=params, data=data)
    
    assert res.status_code == 200, 'POST to update-scan.php resulting in status %s instead of 200' % res.status


def finish_scan(apibase, password, scan_id, uploaded_file, print_id, print_page_number, print_href, min_coord, max_coord, geojpeg_bounds):
    """
    """
    params = {'id': scan_id}
    data = {
            'print_id': print_id,
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
            'geojpeg_bounds': '%.8f,%.8f,%.8f,%.8f' % geojpeg_bounds
           }
    
    res = requests.post(urljoin(apibase, '/finish-scan.php'), params=params, data=data)
    
    assert res.status_code == 200, 'POST to finish-scan.php resulting in status %s instead of 200' % res.status


def fail_scan(apibase, password, scan_id):
    """
    """
    params = {'id': scan_id}
    data = {'password': password}
    
    res = requests.post(urljoin(apibase, '/fail-scan.php'), params=params, data=data)
    
    # TODO when does this fail? this failing shouldn't be fatal
    assert res.status_code == 200, 'POST to fail-scan.php resulting in status %s instead of 200' % res.status


def finish_form(apibase, password, form_id, action_url, http_method, title, fields):
    """
    """
    data = dict(password=password, action_url=action_url, http_method=http_method, title=title)
    
    for (index, field) in enumerate(fields):
        data['fields[%d][name]' % index] = field['name']
        data['fields[%d][label]' % index] = field['label']
        data['fields[%d][type]' % index] = field['type']
    
    params = {'id': form_id}
    
    res = requests.post(urljoin(apibase, '/finish-form.php'), params=params, data=data)
    
    assert res.status_code == 200, 'POST to finish-form.php resulting in status %s instead of 200' % res.status


def fail_form(apibase, password, form_id):
    """
    """
    params = {'id': form_id}
    data = {'password': password}
    
    res = requests.post(urljoin(apibase, '/fail-form.php'), params=params, data=data)
    
    assert res.status_code == 200, 'POST to fail-form.php resulting in status %s instead of 200' % res.status


def upload(params, file_path, file_contents, apibase, password):
    """ Upload a file via the API append.php form input provision thingie.
        This allows uploads to either target S3 or the app itself.
    """

    params.update(dict(password=password,
                       dirname=dirname(file_path),
                       mimetype=(guess_type(file_path)[0] or '')))

    res = requests.get(urljoin(apibase, '/append.php'), params=params, headers=dict(Accept='application/paperwalking+xml'))
    
    form = ElementTree.parse(StringIO(res.text)).getroot()
    
    if form.tag == 'form':
        form_action = form.attrib['action']
        
        inputs = form.findall('.//input')
        
        fields = {}
        files = {}

        for input in inputs:
            if input.attrib['type'] != 'file' and 'name' in input.attrib:
                fields[input.attrib['name']] = input.attrib['value']
            elif input.attrib['type'] == 'file':
                files[input.attrib['name']] = (basename(file_path), file_contents)

        if len(files) == 1:
            base_url = [el.text for el in form.findall(".//*") if el.get('id', '') == 'base-url'][0]
            resource_url = urljoin(base_url, file_path)
        
            res = requests.post(urljoin(apibase, form_action), data=fields, files=files)
            
            assert res.status_code in range(200, 308), 'POST of file to %s resulting in status %s instead of 2XX/3XX' % (form_action, res.status_code)

            return resource_url
        
    raise Exception('Did not find a form with a file input, why is that?')


def append_print_file(print_id, file_path, file_contents, apibase, password):
    """ Upload a print.
    """

    params = {
        "print": print_id,
    }

    return upload(params, file_path, file_contents, apibase, password)


def append_scan_file(scan_id, file_path, file_contents, apibase, password):
    """ Upload a scan.
    """

    params = {
        "scan": scan_id,
    }

    return upload(params, file_path, file_contents, apibase, password)


def get_print_info(print_url):
    """
    """
    print >> sys.stderr, print_url
    res = requests.get(print_url, headers=dict(Accept='application/paperwalking+xml'))

    if res.status_code == 404:
        raise Exception("No such atlas: %s" % print_url)

    print_ = ElementTree.parse(StringIO(res.text)).getroot()
    
    print_id = print_.attrib['id']
    paper = print_.find('paper').attrib['size']
    orientation = print_.find('paper').attrib['orientation']
    layout = print_.find('paper').attrib.get('layout', 'full-page')

    north = float(print_.find('bounds').find('north').text)
    south = float(print_.find('bounds').find('south').text)
    east = float(print_.find('bounds').find('east').text)
    west = float(print_.find('bounds').find('west').text)

    print >> sys.stderr, print_id, north, west, south, east, paper, orientation, layout
    
    return print_id, north, west, south, east, paper, orientation, layout
