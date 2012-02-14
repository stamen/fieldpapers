<?php

    require_once '../lib/lib.everything.php';
    
    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);

    session_start();
    $dbh =& get_db_connection();
    remember_user($dbh);
    
    /**** ... ****/
            
    if(($scan = get_scan($dbh, $_POST['scan_id'])) && $_POST['note'] && $_POST['lat'] && $_POST['lon'])
    {
        
        $dbh->query('START TRANSACTION');

        $note_number = 1;
        
        foreach(get_scan_notes($dbh, $scan['id']) as $note)
        {
            $note_number = max($note_number, $note['note_number'] + 1);
        }
        
        $note = add_scan_note($dbh, $scan['id'], $note_number);
        
        $note['note'] = $_POST['note'];
        $note['latitude'] = $_POST['lat'];
        $note['longitude'] = $_POST['lon'];
        $note['geometry'] = sprintf('POINT(%.6f %.6f)', $_POST['lon'], $_POST['lat']);
        
        set_scan_note($dbh, $note);
        
        $dbh->query('COMMIT');
        
        header('Location: http://'.get_domain_name().get_base_dir().'/scan.php?id='.urlencode($scan['id']));
        
    }
    
?>