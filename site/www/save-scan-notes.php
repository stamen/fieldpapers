<?php

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'/usr/home/migurski/pear/lib');
    require_once 'init.php';
    require_once 'data.php';
    require_once 'lib.auth.php';
    require_once 'lib.scans.php';
    
    enforce_master_on_off_switch($language);

    session_start();
    $dbh =& get_db_connection();
    remember_user($dbh);
    
    $user = cookied_user($dbh);
    $user_id = $user['id'];
    
    /**** ... ****/
    
    //header('content-type: text/plain');
    //print_r($_POST);
    
    // Set Scan ID for redirect
    //$first_element = array_shift(array_keys($_POST['marker']));
    //$scan_id = $_POST['marker'][$first_element]['scan_id'];
    
    $scan_id = $_GET['scan_id'];
    
        
    foreach($_POST['marker'] as $key => $marker)
    {    
        if($key < 0)
        {                 
            if(($scan = get_scan($dbh, $marker['scan_id'])) && $marker['note'] && $marker['lat'] && $marker['lon'])
            {
                $dbh->query('START TRANSACTION');
                
                $note_number = 1;
                
                foreach(get_scan_notes($dbh, $scan['id']) as $note)
                {
                    $note_number = max($note_number, $note['note_number'] + 1);
                }
                
                $note = add_scan_note($dbh, $scan['id'], $note_number);
                
                $note['note'] = $marker['note'];
                $note['latitude'] = $marker['lat'];
                $note['longitude'] = $marker['lon'];
                $note['geometry'] = sprintf('POINT(%.6f %.6f)', $marker['lon'], $marker['lat']);
                
                set_scan_note($dbh, $note);
                
                $dbh->query('COMMIT');
            }
            
        }
        
        if($key > 0)
        {   
            if($marker['removed'] == 1)
            {
                remove_scan_note($dbh, $marker['scan_id'], $marker['note_number']);
                continue;
            }
            
            if(($scan = get_scan($dbh, $marker['scan_id'])) && $marker['note'] && $marker['lat'] && $marker['lon'])
            {
                $dbh->query('START TRANSACTION');
                
                $note['scan_id'] = $marker['scan_id'];                
                $note['note_number'] = $marker['note_number'];
                $note['note'] = $marker['note'];
                $note['latitude'] = $marker['lat'];
                $note['longitude'] = $marker['lon'];
                $note['geometry'] = sprintf('POINT(%.6f %.6f)', $marker['lon'], $marker['lat']);
                                
                set_scan_note($dbh, $note);
                
                $dbh->query('COMMIT');
                
            }
        }
    }
    
    header('Location: http://'.get_domain_name().get_base_dir().'/scan.php?id='.urlencode($scan_id));
    
?>