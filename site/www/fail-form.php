<?php
    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    require_once 'init.php';
    require_once 'data.php';
    require_once 'lib.auth.php';
    
    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);
    enforce_api_password($_POST['password']);
    
    session_start();
    $dbh =& get_db_connection();
    remember_user($dbh);
    
    /**** ... ****/
    
    $form_id = $_GET['id'] ? $_GET['id'] : null;
    
    $form = get_form($dbh, $form_id);
    
    if(!$form)
    {
        die_with_code(400, "I don't know that form");
    }
    
    if($_SERVER['REQUEST_METHOD'] == 'POST')
    {
        $dbh->query('START TRANSACTION');
        
        add_log($dbh, "Failing form {$form['id']}");

        fail_form($dbh, $form['id'], 1);

        $dbh->query('COMMIT');
    }
    
    header('HTTP/1.1 200');
    echo "OK\n";

?>
