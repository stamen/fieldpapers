<?php

    require_once '../../lib/lib.everything.php';

    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);

    session_start();
    $dbh =& get_db_connection();
    remember_user($dbh);
    
    /**** ... ****/
    
    $sm = get_smarty_instance();
    $sm->assign('app_id', GEOPLANET_APPID);
    
    header("Content-Type: text/html; charset=UTF-8");
    print $sm->fetch("search.html.tpl");
    
?>