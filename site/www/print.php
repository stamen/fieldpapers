<?php
   /**
    * Individual page for the print
    */

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    require_once 'init.php';
    require_once 'data.php';
    require_once 'lib.auth.php';
    
    $print_id = $_GET["id"];

    /**** ... ****/
    
    session_start();
    $dbh =& get_db_connection();
    remember_user($dbh);

    $sm = get_smarty_instance();
        
    $print = get_print($dbh, $print_id);
    $sm->assign('print_id', $print_id);
    
    $user_id = $print['user_id'];
    $sm->assign('user_id', $user_id);
        
    header("Content-Type: text/html; charset=UTF-8");
    print $sm->fetch("print.html.tpl");
?>
