<?php
    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    require_once 'init.php';
    require_once 'data.php';
    require_once 'lib.auth.php';
    
    session_start();
    $dbh =& get_db_connection();
    
    $user_id = $_SESSION['user']['id'];
    
    $scan_id = $_GET['id'];
    
    $notes = $_POST['notes'];
    
    if ($user_id && $scan_id && $notes)
    {
        set_simple_scan_notes($dbh, $user_id, $scan_id, $notes);
    } else {
        die('Unable to add a note for this scan.');
    }
    
    $scan_url = 'http://'.get_domain_name().get_base_dir().'/scan.php?id='.urlencode($scan_id);
    header("Location: $scan_url");
    
?>