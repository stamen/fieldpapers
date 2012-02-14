<?php
    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    require_once 'init.php';
    require_once 'data.php';
    require_once 'lib.auth.php';
    
    enforce_master_on_off_switch( $_SERVER['HTTP_ACCEPT_LANGUAGE']);
    
    session_start();
    $dbh =& get_db_connection();
    remember_user($dbh);

    /**** ... ****/
    
    $scan_id = $_GET['id'] ? $_GET['id'] : null;
    
    $scan = get_scan($dbh, $scan_id);
    
    if(!$scan)
    {
        die_with_code(400, "I don't know that scan");
    }
    
    if($_SERVER['REQUEST_METHOD'] == 'POST')
    {
        enforce_api_password($_POST['password']);
        
        $dbh->query('START TRANSACTION');
        
        add_log($dbh, "Failing scan {$scan['id']}");

        fail_scan($dbh, $scan['id'], 1);

        $dbh->query('COMMIT');
    }
    
    header('HTTP/1.1 200');
    echo "OK\n";

?>
