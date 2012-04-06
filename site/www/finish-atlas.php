<?php

    require_once '../lib/lib.everything.php';
    
    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);
    enforce_api_password($_POST['password']);
    
    $context = default_context();
    
    /**** ... ****/
    
    $print_id = $_GET['id'] ? $_GET['id'] : null;
    
    $print = get_print($context->db, $print_id);
    
    if(!$print)
    {
        die_with_code(400, "I don't know that print");
    }
    
    if($_SERVER['REQUEST_METHOD'] == 'POST')
    {
        $context->db->query('START TRANSACTION');
        
        foreach($_POST['pages'] as $page_number => $_page)
        {
            $page = get_print_page($context->db, $print['id'], $page_number);
            
            if(!$page)
            {
                die_with_code(400, "I don't know that page");
            }
        
            $page['preview_url'] = $_page['preview_url'];
            set_print_page($context->db, $page);
        }

        $print['pdf_url'] = $_POST['pdf_url'];
        $print['preview_url'] = $_POST['preview_url'];
        set_print($context->db, $print);

        finish_print($context->db, $print['id']);

        $context->db->query('COMMIT');
    }
    
    header('HTTP/1.1 200');
    echo "OK\n";

?>
