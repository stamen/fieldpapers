<?php
   /**
    * Basic, functionless about page.
    */

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    require_once 'init.php';
    require_once 'data.php';
    require_once 'lib.auth.php';
    
    $language = $_SERVER['HTTP_ACCEPT_LANGUAGE'];
    
    enforce_master_on_off_switch($language);

    /**** ... ****/
    
    session_start();
    $dbh =& get_db_connection();
    remember_user($dbh);
        
    $sm = get_smarty_instance();
    $sm->assign('language', $language);
    
    header("Content-Type: text/html; charset=UTF-8");
    print $sm->fetch("about.html.tpl");

?>
