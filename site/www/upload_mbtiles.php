<?php
    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    require_once 'init.php';
    require_once 'data.php';
    require_once 'lib.auth.php';

    session_start();
    $dbh =& get_db_connection();
    remember_user($dbh);
        
    $sm = get_smarty_instance();
    print $sm->fetch("upload_mbtiles.html.tpl");
?>
