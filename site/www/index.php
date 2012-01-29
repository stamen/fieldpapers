<?php
   /**
    * Home page
    *
    */

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    require_once 'init.php';
    require_once 'data.php';
    require_once 'lib.auth.php';

    /**** ... ****/
    
    session_start();
    $dbh =& get_db_connection();
    remember_user($dbh);

    $sm = get_smarty_instance();
    $prints = get_prints($dbh, 6);
    
    $sm->assign('providers', $p_list);
    $sm->assign('prints', $prints);
    
    header("Content-Type: text/html; charset=UTF-8");
    print $sm->fetch("index.html.tpl");

?>