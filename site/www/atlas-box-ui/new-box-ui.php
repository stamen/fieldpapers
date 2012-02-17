<?php

    require_once '../../lib/lib.everything.php';

    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);

    session_start();
    $dbh =& get_db_connection();
    remember_user($dbh);
    
    /**** ... ****/
        
    $sm = get_smarty_instance();
    $sm->assign('forms', $forms);
    $sm->assign('default_form', $default_form);
    
    header("Content-Type: text/html; charset=UTF-8");
    print $sm->fetch("new-box-ui.html.tpl");
?>