<?php
   /**
    * Scan step modification page, so that polling decoders can notify the user how
    * the scan is progressing. Some steps are simple progress, others are error markers.
    *
    * Requires global site API password and a scan ID, modifies the steps table.
    */

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'/usr/home/migurski/pear/lib');
    require_once 'init.php';
    require_once 'data.php';
    
    if($_POST['password'] != API_PASSWORD)
        die_with_code(401, 'Sorry, bad password');
    
    $scan_id = $_POST['scan'] ? $_POST['scan'] : null;
    $step_number = is_numeric($_POST['step']) ? $_POST['step'] : null;

    /**** ... ****/
    
    $dbh =& get_db_connection();
    
    if($scan_id && $step_number)
    {
        switch($step_number)
        {
            case STEP_ERROR:
                if(count(get_steps($dbh, $scan_id, 31)) > 30)
                {
                    // sort of a magic number, presumably we've tried and tried and tried
                    add_step($dbh, $scan_id, STEP_FATAL_ERROR);
                    echo "Too many errors\n"; // this is magic text! TODO: remove this responsibility from decode.py
                    exit();
                }
                break;

            case STEP_BAD_QRCODE:
                if(count(get_steps($dbh, $scan_id, 21)) > 20)
                {
                    // sort of another magic number, presumably we've tried and tried and tried
                    add_step($dbh, $scan_id, STEP_FATAL_QRCODE_ERROR);
                    echo "Too many errors\n"; // this is magic text! TODO: remove this responsibility from decode.py
                    exit();
                }
                break;
        }
        
        add_step($dbh, $scan_id, $step_number);
        echo "OK\n";
        exit();
    }

    die_with_code(400, "Missing scan ID or step number\n");

?>
