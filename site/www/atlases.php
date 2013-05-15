<?php

    require_once '../lib/lib.everything.php';
    
    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);
    
    $context = default_context(True);

    /**** ... ****/
    
    $print_args = array(
        'date' => preg_match('#^\d{4}-\d\d-\d\d$#', $_GET['date']) ? $_GET['date'] : null,
        'month' => preg_match('#^\d{4}-\d\d$#', $_GET['month']) ? $_GET['month'] : null,
        'place' => is_numeric($_GET['place']) ? $_GET['place'] : null,
        'user' => preg_match('/^\w+$/', $_GET['user']) ? $_GET['user'] : null
        );
    
    $title = get_args_title($context->db, $print_args);
    $prints = get_prints($context->db, $print_args, 50);
    $users = array();

    foreach($prints as $i => $print)
    {   
        $user_id = $print['user_id'];
        
        if($users[$user_id] == null && $user_id != null)
            $users[$user_id] = get_user($context->db, $user_id);
        
        $pages = get_print_pages($context->db, $print['id']);
        
        $prints[$i]['number_of_pages'] = count($pages);
        $prints[$i]['user'] = $users[$user_id];
    }
    
    $context->sm->assign('title', $title);
    $context->sm->assign('prints', $prints);
    
    if($context->type == 'text/html') {
        header("Content-Type: text/html; charset=UTF-8");
        print $context->sm->fetch("atlases.html.tpl");
    
    } else {
        header('HTTP/1.1 400');
        die("Unknown type.\n");
    }

?>
