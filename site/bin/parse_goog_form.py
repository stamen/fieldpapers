import sys

import urllib
from BeautifulSoup import BeautifulSoup

from pprint import pprint

#page = urllib.urlopen("https://docs.google.com/spreadsheet/viewform?formkey=dGhRRzBvOHhXQm1VMkZqZjVwVXBkOWc6MQ")
page = urllib.urlopen("https://docs.google.com/a/caerusassociates.com/spreadsheet/viewform?formkey=dEROeEVqUXhEYnc0MklqTFZMVjNVdHc6MQ")

soup = BeautifulSoup(page)

form = soup.form

# iterate over the form's attributes
form_attrs = {}
for attributes in form.attrs:
    form_attrs[attributes[0]] = attributes[1]

page_data = {'form': form_attrs, 'form_contents':[]}

# Get a list of the entry labels
labels = form.findAll(['label'], {"class": "ss-q-title"})

label_contents = []
for label in labels:
    label_contents.append({label.attrs[1][0]: label.attrs[1][1], 'contents': label.contents[0]})

# Handle the selects
selects = form.findAll(['select'])
select_attrs = {}
select_label = {}

select_contents = []
options = []

for select in selects:
    # Search for label
    for index, label in enumerate(label_contents):
        if label_contents[index]['for'] == select['id']: #multiples?
            select_label = {'for': label_contents[index]['for'], 'contents': label_contents[index]['contents']}
    for attributes in select.attrs:
        select_attrs[attributes[0]] = attributes[1]
    for child in select.findChildren('option'):                
        options.append({child.attrs[0][0]: child.attrs[0][1], 'contents': child.contents[0]})
        
    select_contents.append({'number_of_options': len(select.findChildren('option')),\
                            'label': select_label, 'options': options})  
                
    page_data['form_contents'].append({'select_attrs': select_attrs, 'select_contents': select_contents})
    
# Handle the input text boxes
texts = form.findAll(['input'], {"type": "text"})
text_attrs = {}
text_label = {}

for text in texts:
    if 'id' in text:
        print 'hi'
    
    text_name_pieces = text['name'].split('.')
    text_name_map = text_name_pieces[0] + '_' + text_name_pieces[1]
            
    for index, label in enumerate(label_contents):
        #if label_contents[index]['for'] == text['id']:
        if label_contents[index]['for'] == text_name_map:
            text_label = {'for': label_contents[index]['for'], 'contents': label_contents[index]['contents']}
    for attributes in text.attrs:
        text_attrs[attributes[0]] = attributes[1]
    page_data['form_contents'].append({'text_attrs': text_attrs, 'text_label': text_label})
    
# Handle the textareas
textareas = form.findAll(['textarea'])
textarea_attrs = {}
textarea_label = {}

for textarea in textareas:
    for index, label in enumerate(label_contents):
        if label_contents[index]['for'] == textarea['id']:
            textarea_label = {'for': label_contents[index]['for'], 'contents': label_contents[index]['contents']}
    for attributes in textarea.attrs:
        textarea_attrs[attributes[0]] = attributes[1]
    page_data['form_contents'].append({'textarea_attrs': textarea_attrs, 'textarea_label': textarea_label})

# Handle the checkboxes
checkboxes = form.findAll(['input'], {'type': 'checkbox'})

# Get your checkbox groups
checkbox_groups = []
for checkbox in checkboxes:
    if checkbox['name'] not in checkbox_groups:
        checkbox_groups.append(checkbox['name'])
#print checkbox_groups

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

#pprint(page_data)


# Handle the radio groups
radios = form.findAll(['input'], {'type': 'radio'})
radio_groups = []
radio_questions = {}

for radio in radios:
    if radio['name'] not in radio_groups:
        radio_groups.append(radio['name'])

#print len(radio_groups)

for group in radio_groups:
    radio_questions[group] = {'label': {}, 'options': []}

#radio_group_label = {}

for radio in radios:    
    for group in radio_groups:
        if radio['name'] == group:
            radio_questions[group]['options'].append({'attributes': dict(radio.attrs)})
            
            # Handle the label
            radio_name_pieces = radio['name'].split('.')
            radio_name_map = radio_name_pieces[0] + '_' + radio_name_pieces[1]
            
            for label in label_contents:
                if label['for'] == radio_name_map:
                    radio_questions[group]['label'] = label
    

page_data['form_contents'].append({'radio_groups': radio_questions})
#pprint(radio_questions)
#pprint(radio_questions[u'entry.3.group'])


"""
for group in radio_groups:
    a = form.findAll(['input'], {"type": "radio", "name": group})
""" 

#pprint(inputs)
#pprint(page_data)