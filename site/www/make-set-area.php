<?php
    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    require_once 'init.php';
    require_once 'data.php';
    require_once 'lib.auth.php';
    require_once 'lib.forms.php';

    session_start();
    $dbh =& get_db_connection();
    remember_user($dbh);
        
    $forms = get_forms($dbh);
    
    $sm = get_smarty_instance();
    $sm->assign('forms', $forms);
    
    header("Content-Type: text/html; charset=UTF-8");
    print $sm->fetch("make-set-area.html.tpl");
?>