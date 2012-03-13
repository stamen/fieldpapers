<?php
   /**
    * Individual page for a user
    */

    require_once '../lib/lib.everything.php';
    
    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);
    
    $context = default_context();

    /**** ... ****/
    
    $user_id = $_GET["id"];
    
    $user = get_user($context->db, $user_id);
    
    $context->sm->assign('user_id', $user_id);
    
    if ($user['name'])
    {
        $context->sm->assign('user_name', $user['name']);
    } else {
        $context->sm->assign('user_name', 'Anonymous');
    }
    
    if ($user['email'])
    {
        $context->sm->assign('user_email', $user['email']);
    }
    
    // Get prints by id
    $prints = get_prints($context->db, array('user' => $user['id']));
    
    foreach($prints as $i => $print)
    {   
        $pages = get_print_pages($context->db, $print['id']);
        $prints[$i]['number_of_pages'] = count($pages);
        
        if ($print['place_name'])
        {
            $place_name = explode(',', $print['place_name']);
        
            $prints[$i]['city_name'] = $place_name[0];
        } else {
            $prints[$i]['city_name'] = 'Unknown City';
        }
    }
    
    $context->sm->assign('prints', $prints);
    
    if($context->type == 'text/html') {
        header("Content-Type: text/html; charset=UTF-8");
        print $context->sm->fetch("person.html.tpl");
    
    } elseif($context->type == 'application/paperwalking+xml') { 
        header("Content-Type: application/paperwalking+xml; charset=UTF-8");
        header("Access-Control-Allow-Origin: *");
        print '<'.'?xml version="1.0" encoding="utf-8"?'.">\n";
        print $context->sm->fetch("person.xml.tpl");
    
    } else {
        header('HTTP/1.1 400');
        die("Unknown type.\n");
    }

?>
