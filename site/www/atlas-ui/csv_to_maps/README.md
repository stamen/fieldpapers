#Viewing Data from a CSV File

* Create a target folder for your CSV files. We called our target folder
"uploaded_data."

* Upload your CSV file with the form found on upload_csv.html. You can find a 
test file in the fixtures folder. If you choose a different CSV, be mindful of its schema
and formatting; our test file will give you some guidance.

* Uploading a file will trigger the uploader.php script. Make sure to check your PHP installation 
to see the file-size limit for uploads. The uploader.php script will also convert your CSV data to JSON; 
a new JSON file will be created and placed in the uploaded_data folder.

* If the upload has succeeded, you will be taken to incidents.html, which will display
the incident data from your CSV file on several maps.