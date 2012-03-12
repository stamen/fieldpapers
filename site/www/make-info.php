<?php

    require_once '../lib/lib.everything.php';
    
    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);
    
    session_start();
    $dbh =& get_db_connection();
    remember_user($dbh);
    
    $forms = array();
    
    if($user = cookied_user($dbh))
        $forms = get_forms($dbh, $user['id'], get_pagination(8));
    
    /**** ... ****/
    
    $user = cookied_user($dbh);
    $user_id = $user['id'];
    
    $sm = get_smarty_instance();
    $sm->assign('atlas_data', $_POST);
    $sm->assign('forms', $forms);
    
    $type = $_GET['type'] ? $_GET['type'] : $_SERVER['HTTP_ACCEPT'];
    $type = get_preferred_type($type);
    
    if($type == 'text/html') {
        header("Content-Type: text/html; charset=UTF-8");
        print $sm->fetch("make-info.html.tpl");
    
    } else {
        header('HTTP/1.1 400');
        die("Unknown type.\n");
    }

?>