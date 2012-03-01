<?php
   /**
    * Display page for list of all recent scans in reverse-chronological order.
    */

    require_once '../lib/lib.everything.php';
    
    enforce_master_on_off_switch( $_SERVER['HTTP_ACCEPT_LANGUAGE']);
    
    session_start();
    $dbh =& get_db_connection();
    remember_user($dbh);

    /**** ... ****/    
    
    $pagination = array('page' => $_GET['page'], 'perpage' => $_GET['perpage']);
    
    $scans = get_scans($dbh, $pagination, false);
    $prints = array();
    
    foreach($scans as $i => $scan)
    {
        if(is_null($scan['print_latitude'])) {
            $prints[$i] = false;
        
        } else {
            $prints[$i] = get_print($dbh, $scan['print_id']);
        }
        
        $user = get_user($dbh, $scans[$i]['user_id']);
        
        if ($user['name'])
        {
            $scans[$i]['user_name'] = $user['name'];
        } else {
            $scans[$i]['user_name'] = 'Anonymous';
        }
        
        if(preg_match('#^(\w+)/(\d+)$#', $scans[$i]['print_id'], $matches))
        {
            $print_id = $matches[1];
            $page_number = $matches[2];
            
            $scans[$i]['print_base_id'] = $print_id;
            $scans[$i]['page_number'] = $page_number;
        }
    }

    $type = $_GET['type'] ? $_GET['type'] : $_SERVER['HTTP_ACCEPT'];
    $type = get_preferred_type($type, array('text/html', 'application/json'));
    
    list($count, $offset, $perpage, $page) = get_pagination($pagination);

    $link_next = get_base_dir().sprintf('/scans.php?perpage=%d&page=%d', $perpage, $page + 1);
    $link_prev = ($page <= 1) ? null : get_base_dir().sprintf('/scans.php?perpage=%d&page=%d', $perpage, $page - 1);
    $link_start = get_base_dir().sprintf('/scans.php?perpage=%d', $perpage);
    
    if($_GET['type'])
    {
        $link_next .= '&type='.urlencode($_GET['type']);
        $link_start .= '&type='.urlencode($_GET['type']);
        
        if($link_prev)
            $link_prev .= '&type='.urlencode($_GET['type']);
    }

    if($type == 'text/html') {
        $sm = get_smarty_instance();
        $sm->assign('scans', $scans);
    
        $sm->assign('link_next', $link_next);
        $sm->assign('link_prev', $link_prev);
        $sm->assign('link_start', $link_start);
        
        header("Content-Type: text/html; charset=UTF-8");
        print $sm->fetch("scans.html.tpl");
    
    } elseif($type == 'application/json') { 
       /*
        * Convert to GeoJSON using prints information.
        */
        $scans_prints = array_map(null, $scans, $prints);

        $features = array();
        $leftover = array();
        
        foreach($scans_prints as $i => $scan_print)
        {
            list($scan, $print) = $scan_print;
            
            if($print) {
                $features[] = modify_scan_for_geojson($scan, $print);

            } else {
                $leftover[] = modify_scan_for_json($scan);
            }
        }
        
        $links = array(
            'next' => $link_next,
            'prev' => $link_prev,
            'start' => $link_start
          );
        
        $type = 'FeatureCollection';
        $response = compact('type', 'features', 'leftover', 'links');

        header("Content-Type: application/json; charset=UTF-8");
        header("Access-Control-Allow-Origin: *");
        echo json_encode($response)."\n";
    
    } else {
        header('HTTP/1.1 406');
        die("Unknown content-type.\n");
    }

?>
