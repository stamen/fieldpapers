<?php
   /**
    * 
    */

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    require_once 'init.php';
    require_once 'data.php';
    require_once 'lib.auth.php';

    $scan_id = $_GET['id'] ? $_GET['id'] : null;
    
    list($user_id, $language) = read_userdata($_COOKIE['visitor'], $_SERVER['HTTP_ACCEPT_LANGUAGE']);
    
    enforce_master_on_off_switch($language);

    /**** ... ****/
    
    $dbh =& get_db_connection();
    
    if($user_id)
        $user = get_user($dbh, $user_id);

    if($user)
        setcookie('visitor', write_userdata($user['id'], $language), time() + 86400 * 31);
    
    $scan = get_scan($dbh, $scan_id);
    
    if(!$scan)
    {
        die_with_code(400, "I don't know that scan");
    }
    
    if($_SERVER['REQUEST_METHOD'] == 'POST')
    {
        if($_POST['password'] != API_PASSWORD)
            die_with_code(401, 'Sorry, bad password');
        
        $dbh->query('START TRANSACTION');
        
        add_log($dbh, "Failing scan {$scan['id']}");

        fail_scan($dbh, $scan['id'], 1);

        $dbh->query('COMMIT');
    }
    
    header('HTTP/1.1 200');
    echo "OK\n";

?>
