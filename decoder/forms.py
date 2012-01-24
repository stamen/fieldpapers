# placeholder module for form HTML parsing.

import urllib
from BeautifulSoup import BeautifulSoup

import json

from sys import argv

def get_form_fields(url):
    """ Gets a data structure of form fields for an HTML form URL
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
    
    ###
    #Handle text input boxes
    ###
    textboxes = form.findAll(['input'], {"type": "text"})

    for textbox in textboxes:                
        for index, label in enumerate(label_contents):
            if label_contents[index]['for'] == textbox['id']:
                textbox_label = {'for': label_contents[index]['for'], 'contents': label_contents[index]['contents']}
        page_data['form_contents'].append({'text_attrs': dict(textbox.attrs), 'text_label': textbox_label})  
    
    ####
    #Handle groups of checkboxes
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
    
    form_data = json.dumps(page_data, sort_keys=True,indent=4)
    
    #print form_data
    
    return form_data
    
if __name__ == '__main__':
    #script, url = argv

    url = 'https://docs.google.com/spreadsheet/viewform?formkey=dEZyMnBpUG1pbXpMMGlHLWt3SlRzS0E6MQ';
    
    get_form_fields(url)