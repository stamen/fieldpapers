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
    
    header('content-type: text/plain');
    print_r($_POST);
    
    
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
            if(($scan = get_scan($dbh, $marker['scan_id'])) && $marker['note'] && $marker['lat'] && $marker['lon'])
            {
                $dbh->query('START TRANSACTION');
                
                $note['scan_id'] = $marker['scan_id'];                
                $note['note_number'] = $marker['note_number'];
                $note['note'] = $marker['note'];
                $note['latitude'] = $marker['lat'];
                $note['longitude'] = $marker['lon'];
                $note['geometry'] = sprintf('POINT(%.6f %.6f)', $marker['lon'], $marker['lat']);
                
                
                print_r($note);
                set_scan_note($dbh, $note);
                
                $dbh->query('COMMIT');
                
            }
        }
        
        header('Location: http://'.get_domain_name().get_base_dir().'/scan.php?id='.urlencode($scan['id']));
    }
    
?>