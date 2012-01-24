# placeholder module for form HTML parsing.

import sys
import urllib
from BeautifulSoup import BeautifulSoup

import json

from sys import argv

def get_form_fields(url):
    """ Gets a data structure of form fields for an HTML form URL, return a dictionary.
    """
    page = urllib.urlopen(url)
    
    soup = BeautifulSoup(page)
    
    form = soup.form
        
    # Setting up data structure
    page_data = {'form': dict(form.attrs), 'form_contents':[]}
    
    # Get a list of the entry labels
    labels = form.findAll(['label'], {"class": "ss-q-title"})

    label_contents = []
    for label in labels:
        label_contents.append({label.attrs[1][0]: label.attrs[1][1], 'contents': label.contents[0]})
    
    #
    # Handle text input boxes
    #
    textboxes = form.findAll(['input'], {"type": "text"})
    
    textbox_description = {}

    for textbox in textboxes:                
        for index, label in enumerate(label_contents):
            if label_contents[index]['for'] == textbox['id']:
                textbox_description['label'] = {'contents': label_contents[index]['contents']}
                
        abbreviated_attributes = dict((k,v) for (k,v) in textbox.attrs if k == "type" or k == "name")
        # abbreviated_attributes = {k : v for k in textbox.attrs} # 2.7 and above
        
        # Merge abbreviated attributes with textbox description
        textbox_description = dict(textbox_description.items() + abbreviated_attributes.items())
        
        page_data['form_contents'].append(textbox_description)
        
    #
    # Handle the textareas
    #
    textareas = form.findAll(['textarea'])
    
    textarea_description = {}
        
    for textarea in textareas:
        for index, label in enumerate(label_contents):
            if label_contents[index]['for'] == textarea['id']:
                textarea_description['label'] = {'contents': label_contents[index]['contents']}
                
        abbreviated_attributes = dict((k,v) for (k,v) in textarea.attrs if k == "name")
        abbreviated_attributes['type'] = textarea.name
        
        textarea_description = dict(textarea_description.items() + abbreviated_attributes.items())
        
        page_data['form_contents'].append(textarea_description)
    
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
    
    return page_data
    
if __name__ == '__main__':
    #script, url = argv
    
    form_url = len(argv) == 2 and argv[1] or 'https://docs.google.com/spreadsheet/viewform?formkey=dEZyMnBpUG1pbXpMMGlHLWt3SlRzS0E6MQ'
    
    json.dump(get_form_fields(form_url), sys.stdout, indent=2)