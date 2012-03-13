<?php

    require_once '../lib/lib.everything.php';
    
    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);
    
    $context = default_context();

    /**** ... ****/
    
    $prints = get_prints($context->db, null, 6);
    
    // Get user names
    foreach ($prints as $i => $print)
    {
        $user = get_user($context->db, $prints[$i]['user_id']);
        
        if ($user['name'])
        {
            $prints[$i]['user_name'] = $user['name'];
        } else {
            $prints[$i]['user_name'] = 'Anonymous';
        }
    }
    
    $context->sm->assign('prints', $prints);
    
    header("Content-Type: text/html; charset=UTF-8");
    print $context->sm->fetch("index.html.tpl");

?>