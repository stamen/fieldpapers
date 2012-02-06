<?php

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    require_once 'init.php';
    require_once 'data.php';
    require_once 'lib.auth.php';

    enforce_master_on_off_switch($language);
    enforce_api_password($_POST['password']);

    /**** ... ****/
    
    $dbh =& get_db_connection();

    $scan_id = $_GET['id'] ? $_GET['id'] : null;
    $scan = get_scan($dbh, $scan_id);
    
    if(!$scan)
    {
        die_with_code(400, "I don't know that scan");
    }
    
    if($progress = $_POST['progress'])
    {
        $dbh->query('START TRANSACTION');
        
        $scan['progress'] = $progress;
        set_scan($dbh, $scan);

        $dbh->query('COMMIT');
    }
    
    header('HTTP/1.1 200');
    echo "OK\n";

?>
