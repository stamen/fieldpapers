# placeholder module for form HTML parsing.

import sys
from urllib import urlopen
from urlparse import urljoin
import json

from BeautifulSoup import BeautifulSoup
from apiutils import finish_form, fail_form

def fields_as_text(form_fields):
    """
    """
    labels = [field['label'] for field in form_fields]
    text = '\n\n\n\n'.join(labels)
    
    return text

def get_form_fields(url):
    """ Gets a data structure of form fields for an HTML form URL, return a dictionary.
    """
    page = urlopen(url)
    soup = BeautifulSoup(page)
    form = soup.form

    # Setting up data structure
    form_data = dict(fields=[])
    form_attr = dict(form.attrs)

    form_data['title'] = soup.h1 and soup.h1.text or soup.title.text
    form_data['action'] = urljoin(url, form_attr['action'])
    form_data['method'] = form_attr['method']
    
    # Get a list of the entry labels
    labels = form.findAll(['label'], {"class": "ss-q-title"})

    label_contents = []
    for label in labels:
        label_contents.append({label.attrs[1][0]: label.attrs[1][1], 'contents': label.contents[0]})
    
    #print label_contents
    
    #
    # Handle text input boxes
    #
    textboxes = form.findAll(['input'], {"type": "text"})
    
    #textbox_description = {}

    for textbox in textboxes: 
        textbox_description = {}               
        for index, label in enumerate(label_contents):
            if label_contents[index]['for'] == textbox['id']:
                #print label_contents[index]['contents'].strip()
                textbox_description['label'] = label_contents[index]['contents'].strip()
                break
                
        abbreviated_attributes = dict((k,v) for (k,v) in textbox.attrs if k == "type" or k == "name")
        # abbreviated_attributes = {k : v for k in textbox.attrs} # 2.7 and above
        
        # Merge abbreviated attributes with textbox description
        textbox_description = dict(textbox_description.items() + abbreviated_attributes.items())
        
        form_data['fields'].append(textbox_description)
    
    #
    # Handle the textareas
    #
    textareas = form.findAll(['textarea'])
        
    for textarea in textareas:
        textarea_description = {}
        for index, label in enumerate(label_contents):
            if label_contents[index]['for'] == textarea['id']:
                textarea_description['label'] = label_contents[index]['contents'].strip()
                break
                
        abbreviated_attributes = dict((k,v) for (k,v) in textarea.attrs if k == "name")
        abbreviated_attributes['type'] = textarea.name
        
        textarea_description = dict(textarea_description.items() + abbreviated_attributes.items())
        
        form_data['fields'].append(textarea_description)
    
    """
    Ignore groups of checkboxes for now
    
    ####
    # Handle groups of checkboxes
    ####
    
    checkboxes = form.findAll(['input'], {'type': 'checkbox'})

    # Get your checkbox groups
    checkbox_groups = []
    for checkbox in checkboxes:
        if checkbox['name'] not in checkbox_groups:
            checkbox_groups.append(checkbox['name'])

    checkbox_questions = {}

    for group in checkbox_groups:
        checkbox_questions[group] = {'label': {}, 'options': []}
    
    for checkbox in checkboxes:
        for group in checkbox_groups:
            if checkbox['name'] == group:
                checkbox_questions[group]['options'].append({'attributes': dict(checkbox.attrs)})
        
            # Handle the label
            checkbox_name_pieces = checkbox['name'].split('.')
            checkbox_name_map = checkbox_name_pieces[0] + '_' + checkbox_name_pieces[1]
        
            for label in label_contents:
                if label['for'] == checkbox_name_map:
                    checkbox_questions[group]['label'] = label
    page_data['form_contents'].append({'checkbox_groups': checkbox_questions})
    """
    
    return form_data
    
def main(apibase, password, form_id, url, fields_callback=None):
    """
    """
    try:
        form_data = get_form_fields(url)
    
    except Exception, e:
        print >> sys.stderr, 'Failed because:', e
        fail_form(apibase, password, form_id)

    else:
        if fields_callback:
            fields_callback(form_data)
    
        finish_form(apibase, password, form_id, form_data['action'], form_data['method'], form_data['title'], form_data['fields'])
    
if __name__ == '__main__':
    form_url = len(sys.argv) == 2 and sys.argv[1] or 'https://docs.google.com/spreadsheet/viewform?formkey=dFZsNVprWDY3REM3MnpjbW9rTGkzQUE6MQ'
    
    #get_form_fields(form_url)
    json.dump(get_form_fields(form_url), sys.stdout, indent=2)
