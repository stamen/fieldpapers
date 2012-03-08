<?php

    require_once '../lib/lib.everything.php';
    
    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);
    
    session_start();
    $dbh =& get_db_connection();
    remember_user($dbh);
    
    /**** ... ****/
    
    $user = cookied_user($dbh);
    $user_id = $user['id'];
    
    if ($_POST)
    {
        foreach($_POST as $key => $value)
        {
            $_SESSION['atlas_data'][$key] = $value;
        }
    }
            
    if($_POST['form_url'])
    {
        if(empty($_POST['form_url']))
        {
            header('HTTP/1.1 400');
            die("Empty or missing form_url.\n");
        }
    
        $added_form = add_form($dbh, $user_id);
        $added_form['form_url'] = $_POST['form_url'];
        
        if(!empty($_POST['form_title']))
        {
            $added_form['title'] = $_POST['form_title'];
        }

        set_form($dbh, $added_form);
        $_SESSION['atlas_data']['form_id'] = $added_form['id'];
        
        $message = array('action' => 'import form',
                         'url' => $_POST['form_url'],
                         'form_id' => $added_form['id']);
            
        add_message($dbh, json_encode($message));
                
        $layout_url = 'http://'.get_domain_name().get_base_dir().'/set-layout.php?id='.urlencode($added_form['id']);
        header("Location: {$layout_url}");
        
        exit();
    }

    $sm = get_smarty_instance();
    
    $type = $_GET['type'] ? $_GET['type'] : $_SERVER['HTTP_ACCEPT'];
    $type = get_preferred_type($type);
    
    if($type == 'text/html') {
        header("Content-Type: text/html; charset=UTF-8");
        print $sm->fetch("make-info.html.tpl");
    
    } else {
        header('HTTP/1.1 400');
        die("Unknown type.\n");
    }

?>