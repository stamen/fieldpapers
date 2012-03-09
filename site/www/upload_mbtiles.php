<?php
    require_once '../lib/lib.everything.php';

    session_start();
    $dbh =& get_db_connection();
    remember_user($dbh);
    
    $user = cookied_user($dbh);
        
    $sm = get_smarty_instance();
    $sm->assign('user', $user);
    
    print $sm->fetch("upload_mbtiles.html.tpl");
?>
