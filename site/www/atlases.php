<?php

    require_once '../lib/lib.everything.php';
    
    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);
    
    $context = default_context();

    /**** ... ****/
    
    $print_args = array(
        'date' => preg_match('#^\d{4}-\d\d-\d\d$#', $_GET['date']) ? $_GET['date'] : null,
        'month' => preg_match('#^\d{4}-\d\d$#', $_GET['month']) ? $_GET['month'] : null,
        'place' => is_numeric($_GET['place']) ? $_GET['place'] : null,
        'user' => preg_match('/^\w+$/', $_GET['user']) ? $_GET['user'] : null
        );
    
    $prints = get_prints($context->db, $print_args, 50);
    
    foreach($prints as $i => $print)
    {   
        $pages = get_print_pages($context->db, $print['id']);
        $user = get_user($context->db, $prints[$i]['user_id']);
        
        $prints[$i]['number_of_pages'] = count($pages);
        $prints[$i]['user_name'] = $user['name'] ? $user['name'] : 'Anonymous';
        $prints[$i]['city_name'] = $print['place_name'] ? $print['place_name'] : 'Unknown City';
    }
    
    $context->sm->assign('prints', $prints);
    
    if($context->type == 'text/html') {
        header("Content-Type: text/html; charset=UTF-8");
        print $context->sm->fetch("atlases.html.tpl");
    
    } else {
        header('HTTP/1.1 400');
        die("Unknown type.\n");
    }

?>