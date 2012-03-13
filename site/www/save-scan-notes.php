<?php

    require_once '../lib/lib.everything.php';
    
    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);

    $context = default_context();
        
    /**** ... ****/
    
    $scan_id = $_GET['scan_id'];
    
    foreach($_POST['marker'] as $key => $marker)
    {    
        if($key < 0)
        {                 
            if(($scan = get_scan($context->db, $marker['scan_id'])) && $marker['note'] && $marker['lat'] && $marker['lon'])
            {
                $context->db->query('START TRANSACTION');
                
                $note_number = 1;
                
                foreach(get_scan_notes($context->db, $scan['id']) as $note)
                {
                    $note_number = max($note_number, $note['note_number'] + 1);
                }
                
                $note = add_scan_note($context->db, $scan['id'], $note_number);
                
                $note['note'] = $marker['note'];
                $note['latitude'] = $marker['lat'];
                $note['longitude'] = $marker['lon'];
                $note['geometry'] = sprintf('POINT(%.6f %.6f)', $marker['lon'], $marker['lat']);
                
                set_scan_note($context->db, $note);
                
                $context->db->query('COMMIT');
            }
            
        }
        
        if($key > 0)
        {   
            if($marker['removed'] == 1)
            {
                remove_scan_note($context->db, $marker['scan_id'], $marker['note_number']);
                continue;
            }
            
            if(($scan = get_scan($context->db, $marker['scan_id'])) && $marker['note'] && $marker['lat'] && $marker['lon'])
            {
                $context->db->query('START TRANSACTION');
                
                $note['scan_id'] = $marker['scan_id'];                
                $note['note_number'] = $marker['note_number'];
                $note['note'] = $marker['note'];
                $note['latitude'] = $marker['lat'];
                $note['longitude'] = $marker['lon'];
                $note['geometry'] = sprintf('POINT(%.6f %.6f)', $marker['lon'], $marker['lat']);
                                
                set_scan_note($context->db, $note);
                
                $context->db->query('COMMIT');
                
            }
        }
    }
    
    header('Location: http://'.get_domain_name().get_base_dir().'/scan.php?id='.urlencode($scan_id));
    
?>