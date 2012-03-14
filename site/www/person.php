<?php
   /**
    * Individual page for a user
    */

    require_once '../lib/lib.everything.php';
    
    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);
    
    $context = default_context();

    /**** ... ****/
    
    if(empty($_GET['id']) && $context->user)
    {
        // redirect to the calling-user's page
        die(print_r($context->user, 1));
    }
    
    if($user = get_user($context->db, $_GET['id']))
    {
        $context->sm->assign('user', $user);
    }
    
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
