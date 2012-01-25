<?php
    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    require_once '../lib/init.php';
    require_once '../lib/data.php';
    require_once '../lib/lib.forms.php';
    require_once '../lib/lib.auth.php';

     /*asks to post a new form
    creates a new message in the messages table -- data.php -- with addmessage*/
    
    
    session_start();
    $dbh =& get_db_connection();
    remember_user($dbh);
    
    $user = cookied_user($dbh);
    $user_id = $user['id'];
    
    if ($_POST["url_form"])
    {
        $added_form = add_form($dbh, $user_id);
        
        $message = array('action' => 'import form',
                         'url' => $_POST["url_form"],
                         'form_id' => $added_form['id']);
            
        add_message($dbh, json_encode($message));
        
        $form_url = 'http://'.get_domain_name().get_base_dir().'/form.php?id='.urlencode($added_form['id']);
        header("Location: {$form_url}");
        
        exit();
    }
?>