<?php
   /**
    * Display page for a single scan with a given ID.
    */

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'/usr/home/migurski/pear/lib');
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
    
    if($scan)
    {
        $print = get_print($dbh, $scan['print_id']);
    }

    $sm = get_smarty_instance();
    $sm->assign('scan', $scan);
    $sm->assign('step', $step);
    $sm->assign('print', $print);
    $sm->assign('language', $language);
    
    scan_headers($scan);
    print_headers($print);
    
    $type = $_GET['type'] ? $_GET['type'] : $_SERVER['HTTP_ACCEPT'];
    $type = get_preferred_type($type);
    
    if($type == 'text/html') {
        header("Content-Type: text/html; charset=UTF-8");
        print $sm->fetch("scan.html.tpl");
    
    } elseif($type == 'application/paperwalking+xml') { 
        header("Content-Type: application/paperwalking+xml; charset=UTF-8");
        header("Access-Control-Allow-Origin: *");
        print '<'.'?xml version="1.0" encoding="utf-8"?'.">\n";
        print $sm->fetch("scan.xml.tpl");
    
    } elseif($type == 'application/json') { 
        $scan = modify_scan_for_json($scan);
        
        unset($print['age']);

        $print['north'] = floatval($print['north']);
        $print['south'] = floatval($print['south']);
        $print['east'] = floatval($print['east']);
        $print['west'] = floatval($print['west']);
        $print['zoom'] = intval($print['zoom']);
        $print['latitude'] = floatval($print['latitude']);
        $print['longitude'] = floatval($print['longitude']);
        $print['created'] = intval($print['created']);
        
        $scan['print'] = $print;
        
        header("Content-Type: application/json; charset=UTF-8");
        header("Access-Control-Allow-Origin: *");
        echo json_encode($scan)."\n";
    
    } else {
        header('HTTP/1.1 400');
        die("Unknown type.\n");
    }

?>
