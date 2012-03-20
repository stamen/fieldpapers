<?php

    require_once '../lib/lib.everything.php';
    
    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);

    $context = default_context();
        
    /**** ... ****/
    
    $scan_id = $_GET['scan_id'];
        
    $key = $_POST['marker_number'];
    $marker = $_POST;
    
    $json_response = array('status' => 200,
                           'marker_number' => null,
                           'message' => ''
                           ); 
    
    if($key < 0)
    {                 
        if(($scan = get_scan($context->db, $scan_id)) && $marker['note'] && $marker['lat'] && $marker['lon'])
        {
            $context->db->query('START TRANSACTION');
            
            $note_number = 1;
            
            foreach(get_scan_notes($context->db, array('scan' => $scan['id'])) as $note)
            {
                $note_number = max($note_number, $note['note_number'] + 1);
            }
            
            $note = add_scan_note($context->db, $scan['id'], $note_number);
            
            $note['note'] = $marker['note'];
            $note['latitude'] = $marker['lat'];
            $note['longitude'] = $marker['lon'];
            
            if ($marker['type'] && $marker['type'] == 'POLYGON')
            {
                $note['geometry'] = $marker['geometry'];
            } else {
                $note['geometry'] = sprintf('POINT(%.6f %.6f)', $marker['lon'], $marker['lat']);
            }
            
            $note['user_id'] = $context->user['id'];
            $note['marker_number'] = $note_number;
            
            set_scan_note($context->db, $note);
            
            $context->db->query('COMMIT');
            
            $json_response['status'] = 201;
            //$json_response['marker_number'] = $note_number;
            $json_response['note_data'] = $note;
            $json_response['message'] = 'New marker note created.';
        } else {
            if (!$scan)
            {
                $json_response['message'] = sprintf('No such scan: "%s"', $scan_id);
                $json_response['status'] = 500;
            } else {
                $json_response['message'] = sprintf('Provide a latitude and longitude');
                $json_response['status'] = 500;
            }
        }
        
    }
    
    if($key > 0)
    {   
        if($marker['removed'] == 1)
        {
            remove_scan_note($context->db, $scan_id, $marker['marker_number']);
            
            $json_response['status'] = 200;
            $json_response['marker_number'] = $note['note_number'];
            $json_response['message'] = 'Saved marker note deleted.';
        } else {
            $json_response['message'] = sprintf('This is either not a marker to remove or it does not have the correct value.');
            $json_response['status'] = 400;
        }
        
        if(($scan = get_scan($context->db, $scan_id)) && $marker['note'] && $marker['lat'] && $marker['lon'])
        {
            $context->db->query('START TRANSACTION');
            
            $note['scan_id'] = $scan_id;                
            $note['note_number'] = $marker['marker_number'];
            $note['note'] = $marker['note'];
            $note['latitude'] = $marker['lat'];
            $note['longitude'] = $marker['lon'];
            
            if ($marker['type'] && $marker['type'] == 'POLYGON')
            {
                $note['geometry'] = $marker['geometry'];
            } else {
                $note['geometry'] = sprintf('POINT(%.6f %.6f)', $marker['lon'], $marker['lat']);
            }
            
            $note['user_id'] = $context->user['id'];
                            
            set_scan_note($context->db, $note);
            
            $context->db->query('COMMIT');
            
            $json_response['status'] = 200;
            $json_response['marker_number'] = $note['note_number'];
            $json_response['message'] = 'Saved marker note edited.';
            $json_response['note_data'] = $note;
        } else {
            if (!$scan)
            {
                $json_response['message'] = sprintf('No such scan: "%s"', $scan_id);
                $json_response['status'] = 500;
            } else {
                $json_response['message'] = sprintf('Provide a latitude and longitude');
                $json_response['note_data'] = $note;
                $json_response['status'] = 500;
            }
        }
    }
    
    header('Content-Type: application/json');
    print(json_encode($json_response));
    
?>