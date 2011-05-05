<?php

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'/usr/home/migurski/pear/lib');
    require_once 'init.php';
    require_once 'data.php';
    
    $scan_id = $_GET['id'] ? $_GET['id'] : null;
    $notes = is_array($_POST['notes']) ? $_POST['notes'] : array();
    list($user_id, $language) = read_userdata($_COOKIE['visitor'], $_SERVER['HTTP_ACCEPT_LANGUAGE']);
    
    enforce_master_on_off_switch($language);

    /**** ... ****/
    
    $dbh =& get_db_connection();
    
    $user = $user_id ? get_user($dbh, $user_id) : add_user($dbh);
    $scan = get_scan($dbh, $scan_id);
    
    if($_SERVER['REQUEST_METHOD'] == 'POST')
    {
        if($scan)
        {
            $dbh->query('START TRANSACTION');
    
            set_scan_notes($dbh, $user['id'], $scan['id'], $notes);
            
            $dbh->query('COMMIT');
        }
    }
    
    if($user['id'])
        setcookie('visitor', write_userdata($user['id'], $language), time() + 86400 * 31);

?>