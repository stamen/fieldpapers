<?php
   /**
    * Home page with information and print form.
    *
    * GET vars for prepositioning map form include bounding box and tile provider.
    */

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    require_once 'init.php';
    require_once 'data.php';
    require_once 'lib.auth.php';
        
    $provider = is_null($_GET['provider']) ? reset(reset(get_map_providers())) : $_GET['provider'];
    $latitude = is_numeric($_GET['lat']) ? floatval($_GET['lat']) : DEFAULT_LATITUDE;
    $longitude = is_numeric($_GET['lon']) ? floatval($_GET['lon']) : DEFAULT_LONGITUDE;
    $zoom = is_numeric($_GET['zoom']) ? intval($_GET['zoom']) : DEFAULT_ZOOM;

    /**** ... ****/
    
    session_start();
    $dbh =& get_db_connection();
    remember_user($dbh);
        
    $prints = get_prints($dbh, 6);
    //print_r($prints);
    
    //$scans = get_scans($dbh, 4);

    $sm = get_smarty_instance();
    $sm->assign('scans', $scans);
    //$sm->assign('language', $language);

    $sm->assign('provider', $provider);
    $sm->assign('latitude', $latitude);
    $sm->assign('longitude', $longitude);
    $sm->assign('zoom', $zoom);
    
    $sm->assign('paper_sizes', array('Letter', 'A4', 'A3'));
    
    foreach ($prints as $key => $value) {
        //print_r($key);
        $prints[$key]['index'] = $key;
        
        $provider_list[] = $prints[$key]['provider']; 
    }
    
    //print_r($provider_list);
    
    foreach($provider_list as $value) {
            $p_list = $p_list . ',' . $value;
    }
    
    $p_list = substr($p_list,1,strlen($p_list));
    //print_r($p_list);
    
    
    
    $sm->assign('providers', $p_list);
    $sm->assign('prints', $prints);
    
    /*
    // test
    $test_prov = 'http://spaceclaw.stamen.com/toner/{Z}/{X}/{Y}.png';
    $sm->assign('test_prov', $test_prov);

    $hotspots = array(array('user' => 'Mike', 'place' => 'Null Island', 'id' => '1'), 
                      array('user' => 'George', 'place' => 'Australia', 'id' => '2'),
                      array('user' => 'Michael', 'place' => 'Palo Alto', 'id' => '3'),
                      array('user' => 'Nate', 'place' => 'Washington DC', 'id' => '4'),
                      array('user' => 'Geraldine', 'place' => 'San Francisco', 'id' => '5'),
                      array('user' => 'Shawn', 'place' => 'Panama', 'id' => '6')
                      );
                     
    $sm->assign('hotspots', $hotspots);
    //$sm->assign('sm', $sm);
    */
    
    
    header("Content-Type: text/html; charset=UTF-8");
    print $sm->fetch("index.html.tpl");

?>
