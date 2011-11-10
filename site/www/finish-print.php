<?php
   /**
    * Display page for a single print with a given ID.
    *
    * When this page receives a POST request, it's probably from compose.py
    * (check the API_PASSWORD) with new information on print components for
    * building into a new PDF.
    */

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    require_once 'init.php';
    require_once 'data.php';

    $print_id = $_GET['id'] ? $_GET['id'] : null;
    
    list($user_id, $language) = read_userdata($_COOKIE['visitor'], $_SERVER['HTTP_ACCEPT_LANGUAGE']);
    
    enforce_master_on_off_switch($language);

    /**** ... ****/
    
    $dbh =& get_db_connection();
    
    if($user_id)
        $user = get_user($dbh, $user_id);

    if($user)
        setcookie('visitor', write_userdata($user['id'], $language), time() + 86400 * 31);
    
    $print = get_print($dbh, $print_id);
    
    if(!$print)
    {
        die_with_code(400, "I don't know that print");
    }
    
    if($_SERVER['REQUEST_METHOD'] == 'POST')
    {
        if($_POST['password'] != API_PASSWORD)
            die_with_code(401, 'Sorry, bad password');
        
        $dbh->query('START TRANSACTION');
        
        foreach($_POST['pages'] as $page_number => $_page)
        {
            $page = get_print_page($dbh, $print['id'], $page_number);
            
            if(!$page)
            {
                die_with_code(400, "I don't know that page");
            }
        
            $page['preview_url'] = $_page['preview_url'];
            set_print_page($dbh, $page);
        }

        $print['pdf_url'] = $_POST['pdf_url'];
        $print['preview_url'] = $_POST['preview_url'];
        set_print($dbh, $print);

        finish_print($dbh, $print['id']);

        $dbh->query('COMMIT');
    }
    
    header('HTTP/1.1 200');
    echo "OK\n";

?>
