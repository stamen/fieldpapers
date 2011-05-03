<?php

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'/usr/home/migurski/pear/lib');
    require_once 'init.php';
    require_once 'data.php';
    
    $scan_id = $_GET['id'] ? $_GET['id'] : null;
    $notes = is_array($_POST['notes']) ? $_POST['notes'] : null;
    list($user_id, $language) = read_userdata($_COOKIE['visitor'], $_SERVER['HTTP_ACCEPT_LANGUAGE']);
    
    enforce_master_on_off_switch($language);

    /**** ... ****/
    
    $dbh =& get_db_connection();
    
    $scan = get_scan($dbh, $scan_id);
    
    if($scan && $notes)
    {
        $dbh->query('START TRANSACTION');

        set_scan_notes($dbh, $user_id, $scan_id, $notes);
        
        $dbh->query('COMMIT');
    }

?>