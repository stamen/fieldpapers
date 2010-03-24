<?php
   /**
    * Display page for a single print with a given ID.
    */

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'/usr/home/migurski/pear/lib');
    require_once 'init.php';
    require_once 'data.php';
    
    $print_id = $_GET['id'] ? $_GET['id'] : null;
    list($user_id, $language) = read_userdata($_COOKIE['visitor'], $_SERVER['HTTP_ACCEPT_LANGUAGE']);

    /**** ... ****/
    
    $dbh =& get_db_connection();
    
    if($user_id)
        $user = get_user($dbh, $user_id);

    if($user)
        setcookie('visitor', write_userdata($user['id'], $language), time() + 86400 * 31);
    
    $print = get_print($dbh, $print_id);
    
    $sm = get_smarty_instance();
    $sm->assign('print', $print);
    $sm->assign('language', $language);
    
    header(sprintf('X-Print-ID: %s', $print['id']));
    header(sprintf('X-Print-User-ID: %s', $print['user_id']));
    header(sprintf('X-Print-Paper: %s %s', $print['paper_size'], $print['orientation']));
    header(sprintf('X-Print-Provider: %s', $print['provider']));
    header(sprintf('X-Print-PDF-URL: %s', $print['pdf_url']));
    header(sprintf('X-Print-Preview-URL: %s', $print['preview_url']));
    header(sprintf('X-Print-Bounds: %.6f %.6f %.6f %.6f', $print['south'], $print['west'], $print['north'], $print['east']));
    header(sprintf('X-Print-Center: %.6f %.6f %d', $print['latitude'], $print['longitude'], $print['zoom']));
    header(sprintf('X-Print-Country: %s (woeid %d)', $print['country_name'], $print['country_woeid']));
    header(sprintf('X-Print-Region: %s (woeid %d)', $print['region_name'], $print['region_woeid']));
    header(sprintf('X-Print-Place: %s (woeid %d)', $print['place_name'], $print['place_woeid']));
    
    $type = $_GET['type'] ? $_GET['type'] : $_SERVER['HTTP_ACCEPT'];
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
        die("Unknown type: {$_SERVER['HTTP_ACCEPT']}\n");
    }

?>
