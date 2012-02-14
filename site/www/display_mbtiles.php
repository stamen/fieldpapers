<?php    
    require_once '../lib/lib.everything.php';

    session_start();
    $dbh =& get_db_connection();
    remember_user($dbh);
    
    $filename = $_GET['filename'];
        
    $sm = get_smarty_instance();
    $sm->assign('filename', $filename);
    print $sm->fetch("mbtiles.html.tpl");
?>