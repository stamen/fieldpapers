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

    enforce_master_on_off_switch();

    if($_POST['password'] != API_PASSWORD)
        die_with_code(401, 'Sorry, bad password');
    
    $scan_id = $_POST['scan'] ? $_POST['scan'] : null;
    $step_number = is_numeric($_POST['step']) ? $_POST['step'] : null;
    $_extras = $_POST['extras'] ? $_POST['extras'] : null;

    /**** ... ****/
    
    $dbh =& get_db_connection();
    
    if($scan_id && $step_number)
    {
        $steps_so_far = count(get_steps($dbh, $scan_id, 31));
        
        if($steps_so_far > 30)
        {
            $next_step = ($step_number == STEP_BAD_QRCODE)
                ? STEP_FATAL_QRCODE_ERROR
                : STEP_FATAL_ERROR;
            
            add_log($dbh, "Giving up on scan {$scan_id} at step {$next_step} because it has had {$steps_so_far} steps so far");

            // sort of another magic number, presumably we've tried and tried and tried
            add_step($dbh, $scan_id, $next_step);
            echo "Too many errors\n"; // this is magic text! TODO: remove this responsibility from decode.py

        } else {
            if($step_number == STEP_BAD_QRCODE)
            {
                $step_number = STEP_FATAL_QRCODE_ERROR;
            
                add_log($dbh, "Adding step {$step_number} to scan {$scan_id}");
                add_step($dbh, $scan_id, $step_number);
                
                add_log($dbh, "Adding decoding extras to scan {$scan_id}");

                $extras = json_decode($_extras, true);
            
                if(is_null($extras) || PEAR::isError($extras))
                {
                    add_log($dbh, "Failed to parse extras for scan {$scan_id}: {$_extras}");
                    die_with_code(400, "Failed to parse extras as JSON\n");
                }
                
                $scan = array('id' => $scan_id, 'decoding_json' => $_extras);
                $scan = set_scan($dbh, $scan);
                
                if(!$scan)
                {
                    add_log($dbh, "Failed to add extras to scan {$scan_id}");
                    die_with_code(400, "Failed to add extras\n");
                }

            } else {
                add_log($dbh, "Adding step {$step_number} to scan {$scan_id}");
                add_step($dbh, $scan_id, $step_number);
            }
            
            echo "OK\n";
        }
        
        exit();
    }

    die_with_code(400, "Missing scan ID or step number\n");

?>
