<?php
   /**
    * Display page for a single scan with a given ID.
    */

    require_once '../lib/lib.everything.php';
    
    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);
    
    $context = default_context();

    /**** ... ****/
            
    $scan_id = $_GET['id'] ? $_GET['id'] : null;
    
    $scan = get_scan($context->db, $scan_id);
    
    if($_SERVER['REQUEST_METHOD'] == 'POST')
    {
        if($scan)
        {
            $scan = array('id' => $scan_id,
                          'print_id' => $_POST['print_id'],
                          'user_name' => $_POST['user_name'],
                          'min_row' => $_POST['min_row'],
                          'min_column' => $_POST['min_column'],
                          'min_zoom' => $_POST['min_zoom'],
                          'max_row' => $_POST['max_row'],
                          'max_column' => $_POST['max_column'],
                          'max_zoom' => $_POST['max_zoom'],
                          'description' => $_POST['description'],
                          'is_private' => $_POST['is_private'],
                          'will_edit' => $_POST['will_edit']);
            
            $context->db->query('START TRANSACTION');
            $scan = set_scan($context->db, $scan);
            $context->db->query('COMMIT');
        }
    }
    
    if($scan)
    {
        $print = get_print($context->db, $scan['print_id']);
        $notes = get_scan_notes($context->db, array('page' => 1, 'perpage' => 242), $scan['id']);
    }

    $context->sm->assign('scan', $scan);
    $context->sm->assign('step', $step);
    $context->sm->assign('print', $print);
    $context->sm->assign('notes', $notes);
    $context->sm->assign('language', $language);
    
    scan_headers($scan);
    print_headers($print);
    
    header("Content-Type: text/html; charset=UTF-8");
    print $context->sm->fetch("scan-large.html.tpl");

?>
