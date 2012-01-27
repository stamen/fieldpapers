<?php
    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    require_once '../../../lib/init.php';
    require_once '../../../lib/data.php';
    require_once '../../../lib/lib.auth.php';

    session_start();
    $dbh =& get_db_connection();
    remember_user($dbh);
        
    $sm = get_smarty_instance();
    header("Content-Type: text/html; charset=UTF-8");
    print $sm->fetch("make-set-area.html.tpl");
?>