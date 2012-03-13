<?php

    require_once '../lib/lib.everything.php';
    
    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);

    $context = default_context();
    
    /**** ... ****/
            
    if(($scan = get_scan($context->db, $_POST['scan_id'])) && $_POST['note'] && $_POST['lat'] && $_POST['lon'])
    {
        
        $context->db->query('START TRANSACTION');

        $note_number = 1;
        
        foreach(get_scan_notes($context->db, $scan['id']) as $note)
        {
            $note_number = max($note_number, $note['note_number'] + 1);
        }
        
        $note = add_scan_note($context->db, $scan['id'], $note_number);
        
        $note['note'] = $_POST['note'];
        $note['latitude'] = $_POST['lat'];
        $note['longitude'] = $_POST['lon'];
        $note['geometry'] = sprintf('POINT(%.6f %.6f)', $_POST['lon'], $_POST['lat']);
        
        set_scan_note($context->db, $note);
        
        $context->db->query('COMMIT');
        
        header('Location: http://'.get_domain_name().get_base_dir().'/scan.php?id='.urlencode($scan['id']));
        
    }
    
?>