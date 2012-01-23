import urllib
from BeautifulSoup import BeautifulSoup

from pprint import pprint

page = urllib.urlopen("http://fieldpapers.org/~mevans/fieldpapers/site/design/page.html")

soup = BeautifulSoup(page)

#form = soup.form -- findall form, find form, action, select input textarea, label

form = soup.form;
#print form
form_contents = soup.form.contents

# iterate over the form's attributes
form_attrs = {}
for attributes in form.attrs:
    form_attrs[attributes[0]] = attributes[1]

page_data = {'form': form_attrs, 'form_contents':[]}

# Handle the selects
selects = form.findAll(['select'])

select_attrs = {}
select_contents = []
for select in selects:
    for attributes in select.attrs:
        select_attrs[attributes[0]] = attributes[1]
    for index, child in enumerate(select.findChildren()):
        key = child.name + str(index + 1)
        
        if child.attrs:
            select_contents.append({key: {'attributes': {child.attrs[0][0]:child.attrs[0][1]}, 'value': child.contents}})
        else:
            select_contents.append({key: {'attributes': 'None', 'value': child.contents}})
        
    page_data['form_contents'].append({'select': select_attrs, 'select_contents':select_contents})

# Handle the textareas
textareas = form.findAll(['textarea'])
text_attrs = {}
for textarea in textareas:
    for attributes in textarea.attrs:
        text_attrs[attributes[0]] = attributes[1]
    page_data['form_contents'].append({'textarea': text_attrs, 'textarea_contents': 'None'})
    
# Handle the inputs
inputs = form.findAll(['input'])
input_attrs = {}
label = {}
label_attrs = {}
for input in inputs:
    #print input.findNextSibling(['label'])
    for attributes in input.attrs:
        input_attrs[attributes[0]] = attributes[1]
    for label in input.findNextSiblings(['label']):
        for attributes in label.attrs:
            label_attrs[attributes[0]] = attributes[1]
        label = {'attributes': label_attrs, 'contents': label.contents}
        
    page_data['form_contents'].append({'input': input_attrs, 'label': label})

pprint(page_data)
