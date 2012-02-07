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
    
    if ($_GET["form_id"])
    {
        $default_form_id = $_GET["form_id"];
        $default_form = get_form($dbh, $default_form_id);
    } else {
        $default_form = 'none';
    }
    
    $sm = get_smarty_instance();
    $sm->assign('forms', $forms);
    $sm->assign('default_form', $default_form);
    
    header("Content-Type: text/html; charset=UTF-8");
    print $sm->fetch("make-set-area.html.tpl");
?>