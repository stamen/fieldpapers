<?php
   /**
    * Individual page for a place
    */

    require_once '../lib/lib.everything.php';
      
    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);
    
    session_start();
    $dbh =& get_db_connection();
    remember_user($dbh);

    /**** ... ****/
    
    $sm = get_smarty_instance();
    if ($_GET[place_id])
    {
        $woeid = $_GET[place_id];
        $sm->assign('woeid', $woeid);
        $prints = get_prints_by_place_woeid($dbh, $woeid);
        
        $place_name = explode(',', $prints[0]['place_name']);
        $city_name = $place_name[0];
        $country_name = $prints[0]['country_name'];
        
        $sm->assign('city_name', $city_name);
        $sm->assign('country_name', $country_name);
    }
    
    if ($_GET[country_id])
    {
        $woeid = $_GET[country_id];
        $sm->assign('woeid', $woeid);
        $prints = get_prints_by_country_woeid($dbh, $woeid);
        
        $country_name = $prints[0]['country_name'];
        $sm->assign('country_name', $country_name);
    }
            
    foreach($prints as $i => $print)
    {   
        $pages = get_print_pages($dbh, $print['id']);
        $prints[$i]['number_of_pages'] = count($pages);
        
        $user = get_user($dbh, $prints[$i]['user_id']);
        
        if ($user['name'])
        {
            $prints[$i]['user_name'] = $user['name'];
        } else {
            $prints[$i]['user_name'] = 'Anonymous';
        }
    }
    
    $sm->assign('prints', $prints);
    
    $type = $_GET['type'] ? $_GET['type'] : $_SERVER['HTTP_ACCEPT'];
    $type = get_preferred_type($type);
    
    if($type == 'text/html') {
        header("Content-Type: text/html; charset=UTF-8");
        print $sm->fetch("place.html.tpl");
    
    } elseif($type == 'application/paperwalking+xml') { 
        header("Content-Type: application/paperwalking+xml; charset=UTF-8");
        header("Access-Control-Allow-Origin: *");
        print '<'.'?xml version="1.0" encoding="utf-8"?'.">\n";
        print $sm->fetch("place.xml.tpl");
    
    } else {
        header('HTTP/1.1 400');
        die("Unknown type.\n");
    }

?>
