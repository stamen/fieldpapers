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
    
    enforce_master_on_off_switch($language);

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
            if($_POST['action'] == 'override QR code' && $scan['last_step'] == STEP_FATAL_QRCODE_ERROR)
            {
                add_log($dbh, "Thinking of maybe putting scan {$scan_id} back on the market");
                
                $decoding = json_decode($scan['decoding_json'], true);
                
                if(is_null($decoding) || PEAR::isError($decoding))
                {
                    add_log($dbh, "Failed to parse decoding_json for scan {$scan_id}: {$scan['decoding_json']}");
                    die_with_code(400, "Failed to parse extras as JSON\n");
                }

                $dbh->query('START TRANSACTION');
        
                $added = add_step($dbh, $scan_id, 1);
                
                if($added)
                {
                    $message = array('action' => 'decode',
                                     'scan_id' => $scan_id,
                                     'image_url' => $decoding['image_url'],
                                     'qrcode_contents' => $_POST['qrcode_contents'],
                                     'markers' => $decoding['markers']);
                    
                    add_message($dbh, json_encode($message));
                }
                
                $dbh->query('COMMIT');

            } else {
                $scan = array('id' => $scan_id,
                              'print_id' => $_POST['print_id'],
                              'last_step' => $_POST['last_step'],
                              'user_name' => $_POST['user_name'],
                              'uploaded_file' => $_POST['uploaded_file'],
                              'min_row' => $_POST['min_row'],
                              'min_column' => $_POST['min_column'],
                              'min_zoom' => $_POST['min_zoom'],
                              'max_row' => $_POST['max_row'],
                              'max_column' => $_POST['max_column'],
                              'max_zoom' => $_POST['max_zoom'],
                              'description' => $_POST['description'],
                              'is_private' => $_POST['is_private'],
                              'will_edit' => $_POST['will_edit'],
                              'has_geotiff' => $_POST['has_geotiff'],
                              'has_stickers' => $_POST['has_stickers']);
                
                add_log($dbh, "Posting additional details to scan {$print['id']}");
        
                $dbh->query('START TRANSACTION');
                $scan = set_scan($dbh, $scan);
                $dbh->query('COMMIT');
            }
        }
    }
    
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
        
        unset($print['last_step']);
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
