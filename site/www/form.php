<?php
   /**
    * Individual page for the form
    */

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    require_once 'init.php';
    require_once 'data.php';
    require_once 'lib.forms.php';
    require_once 'lib.auth.php';
    
    $form_id = $_GET["id"];

    /**** ... ****/
    
    session_start();
    $dbh =& get_db_connection();
    remember_user($dbh);

    $sm = get_smarty_instance();
    
    // Get form    
    $form = get_form($dbh, $form_id);
    
    $user = get_user($dbh, $form['user_id']);
    
    if ($user['name'])
    {
        $form['user_name'] = $user['name'];
    } else {
        $form['user_name'] = 'Anonymous';
    }
    
    $sm->assign('form', $form);
    
    // Get pages
    $fields = get_form_fields($dbh, $form_id);
    $sm->assign('fields', $fields);
    
    $type = $_GET['type'] ? $_GET['type'] : $_SERVER['HTTP_ACCEPT'];
    $type = get_preferred_type($type);
    
    if($type == 'text/html') {
        header("Content-Type: text/html; charset=UTF-8");
        print $sm->fetch("form.html.tpl");
    
    } else {
        header('HTTP/1.1 400');
        die("Unknown type.\n");
    }

?>
