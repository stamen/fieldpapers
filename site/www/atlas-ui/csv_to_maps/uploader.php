<?php
    //Upload data e.g., CSV to the server.
    
    $target_data_folder = "../uploaded_data/";
    
    $target_csv_data_path = $target_data_folder . basename($_FILES['uploaded_data']['name']);
        
    if(move_uploaded_file($_FILES['uploaded_data']['tmp_name'], $target_csv_data_path)){
        echo basename($_FILES['uploaded_data']['name']) . " has been successfully uploaded";
    } else {
        echo "Upload of " . basename($_FILES['uploaded_data']['name']) . " was unsuccessful.";
    }
    
    //Start CSV to JSON handling here
    $file_name = explode('.',basename($_FILES['uploaded_data']['name']));
    $json_path = $target_data_folder . $file_name[0] . ".json";
    
    $data = fopen($target_csv_data_path,'r') or die("Unable to open file");
    $json_output = fopen($json_path,'w') or die ("Unable to open file");
            
    fputs($json_output,"{\n\t\"incidents\" : [\n");
    
    $csv_columns = fgetcsv($data);
    
    $need_comma = False;
    
    while($csv_line = fgetcsv($data)){
        if($need_comma == True){
            fputs($json_output,"},\n");
        }
        
        fputs($json_output,"\t{\n\t");
        for($i=0; $i < count($csv_line); $i++){
            if($i < count($csv_line) - 1){
                //assuming in order of csv_colums = csv_lines
                fputs($json_output,"\t" . json_encode($csv_columns[$i]) . " : " . json_encode($csv_line[$i]) . ",\n\t");
            } else {
                fputs($json_output,"\t" . json_encode($csv_columns[$i]) . " : " . json_encode($csv_line[$i]) . "\n\t");
            }
        }
        
        $need_comma = True;
    }
    
    fputs($json_output,"}\n");
    fputs($json_output,"\t]\n}");
            
    fclose($data) or die("Unable to close file.");
    fclose($json_output) or die("Unable to close file.");     
    
    header('Location: incidents.html');
    exit();
?>