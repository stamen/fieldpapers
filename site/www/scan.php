<?php
   /**
    * Display page for a single scan with a given ID.
    */

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'/usr/home/migurski/pear/lib');
    require_once 'init.php';
    require_once 'data.php';
    
    $scan_id = $_GET['id'] ? $_GET['id'] : null;
    list($user_id, $language) = read_userdata($_COOKIE['visitor'], $_SERVER['HTTP_ACCEPT_LANGUAGE']);

    /**** ... ****/
    
    $dbh =& get_db_connection();
    
    if($user_id)
        $user = get_user($dbh, $user_id);

    if($user)
        setcookie('visitor', write_userdata($user['id'], $language), time() + 86400 * 31);
    
    $scan = get_scan($dbh, $scan_id);
    
    if($_SERVER['REQUEST_METHOD'] == 'POST')
    {
        if($scan)
        {
            $scan = array('id' => $scan_id,
                          'print_id' => $_POST['print_id'],
                          'last_step' => $_POST['last_step'],
                          'user_name' => $_POST['user_name'],
                          'min_row' => $_POST['min_row'],
                          'min_column' => $_POST['min_column'],
                          'min_zoom' => $_POST['min_zoom'],
                          'max_row' => $_POST['max_row'],
                          'max_column' => $_POST['max_column'],
                          'max_zoom' => $_POST['max_zoom'],
                          'description' => $_POST['description'],
                          'is_private' => $_POST['is_private'],
                          'will_edit' => $_POST['will_edit']);
            
            $dbh->query('START TRANSACTION');
            $scan = set_scan($dbh, $scan);
            $dbh->query('COMMIT');
        }
    }
    
    if($scan)
    {
        $step = get_step($dbh, $scan['id']);
        $print = get_print($dbh, $scan['print_id']);
    }

    $sm = get_smarty_instance();
    $sm->assign('scan', $scan);
    $sm->assign('step', $step);
    $sm->assign('print', $print);
    $sm->assign('language', $language);
    
    header(sprintf('X-Scan-ID: %s', $scan['id']));
    header(sprintf('X-Scan-User-ID: %s', $scan['user_id']));
    header(sprintf('X-Scan-Last-Step: %s', $scan['last_step']));
    header(sprintf('X-Scan-Is-Private: %s', $scan['is_private']));
    header(sprintf('X-Scan-Will-Edit: %s', $scan['will_edit']));
    header(sprintf('X-Scan-Minimum-Coord: %.3f %.3f %d', $scan['min_row'], $scan['min_column'], $scan['min_zoom']));
    header(sprintf('X-Scan-Maximum-Coord: %.3f %.3f %d', $scan['max_row'], $scan['max_column'], $scan['max_zoom']));
    header(sprintf('X-Scan-Base-URL: %s', $scan['base_url']));

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
        print $sm->fetch("scan.html.tpl");
    
    } elseif($type == 'application/xml') { 
        header("Content-Type: application/xml; charset=UTF-8");
        print '<'.'?xml version="1.0" encoding="utf-8"?'.">\n";
        print $sm->fetch("scan.xml.tpl");
    
    } else {
        header('HTTP/1.1 400');
        die("Unknown type: {$_SERVER['HTTP_ACCEPT']}\n");
    }

?>
