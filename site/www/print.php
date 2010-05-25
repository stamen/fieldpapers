<?php
   /**
    * Display page for a single print with a given ID.
    *
    * When this page receives a POST request, it's probably from compose.py
    * (check the API_PASSWORD) with new information on print components for
    * building into a new PDF.
    */

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'/usr/home/migurski/pear/lib');
    require_once 'init.php';
    require_once 'data.php';
    require_once 'composition.php';
    
    $print_id = $_GET['id'] ? $_GET['id'] : null;
    list($user_id, $language) = read_userdata($_COOKIE['visitor'], $_SERVER['HTTP_ACCEPT_LANGUAGE']);

    /**** ... ****/
    
    $dbh =& get_db_connection();
    
    if($user_id)
        $user = get_user($dbh, $user_id);

    if($user)
        setcookie('visitor', write_userdata($user['id'], $language), time() + 86400 * 31);
    
    $print = get_print($dbh, $print_id);
    
    if($print && $_SERVER['REQUEST_METHOD'] == 'POST')
    {
        if($_POST['password'] != API_PASSWORD)
            die_with_code(401, 'Sorry, bad password');
        
        // we accept a subset of print properties here
        foreach(array('north', 'south', 'east', 'west', 'zoom', 'paper', 'preview_url', 'last_step') as $field)
            if(isset($_POST[$field]))
                $print[$field] = $_POST[$field];
        
        if($_POST['last_step'] == STEP_FINISHED)
        {
            $print_url = get_post_baseurl("prints/{$print['id']}/").'print.jpg';
            $print_jpg = file_get_contents($print_url);
            $print = compose_map($print, $print_jpg);
        }
        
        $dbh->query('START TRANSACTION');
        $print = set_print($dbh, $print);
        $dbh->query('COMMIT');
    }
    
    $sm = get_smarty_instance();
    $sm->assign('print', $print);
    $sm->assign('language', $language);
    
    print_headers($print);

    $type = $_GET['type'] ? $_GET['type'] : 'html'; //$_SERVER['HTTP_ACCEPT'];
    $type = get_preferred_type($type);
    
    if($type == 'text/html') {
        header("Content-Type: text/html; charset=UTF-8");
        print $sm->fetch("print.html.tpl");
    
    } elseif($type == 'application/xml') { 
        header("Content-Type: application/xml; charset=UTF-8");
        print '<'.'?xml version="1.0" encoding="utf-8"?'.">\n";
        print $sm->fetch("print.xml.tpl");
    
    } else {
        header('HTTP/1.1 400');
        die("Unknown type.\n");
    }

?>
