<?php
   /**
    * Old location of zeitgeist.
    */

    require_once '../lib/lib.everything.php';
    
    $language = $_SERVER['HTTP_ACCEPT_LANGUAGE'];

    enforce_master_on_off_switch($language);

    /**** ... ****/
    session_start();
    $dbh =& get_db_connection();
    remember_user($dbh);
    
    $sm = get_smarty_instance();
    $sm->assign('language', $language);
    
    header("Content-Type: text/html; charset=UTF-8");
    print $sm->fetch("errata.html.tpl");

?>
