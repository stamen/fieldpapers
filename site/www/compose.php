<?php
   /**
    * New print composition endpoint.
    *
    * POST vars include bounding box, print orientation, and tile provider.
    *
    * Redirects to print.php?id=* on successful composition.
    */

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.dirname(__FILE__).'/../lib');
    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'/usr/home/migurski/pear/lib');
    require_once 'init.php';
    require_once 'data.php';
    require_once 'composition.php';
    
    /*
    header('Content-Type: text/plain');
    print_r($_POST);
    die();
    */
    
    list($user_id, $language) = read_userdata($_COOKIE['visitor'], $_SERVER['HTTP_ACCEPT_LANGUAGE']);

    $north = is_numeric($_POST['north']) ? floatval($_POST['north']) : null;
    $south = is_numeric($_POST['south']) ? floatval($_POST['south']) : null;
    $east = is_numeric($_POST['east']) ? floatval($_POST['east']) : null;
    $west = is_numeric($_POST['west']) ? floatval($_POST['west']) : null;
    $zoom = is_numeric($_POST['zoom']) ? intval($_POST['zoom']) : null;
    $paper = $_POST['paper'] ? $_POST['paper'] : null;
    $provider = $_POST['provider'] ? $_POST['provider'] : null;
    
    switch(strtolower($_POST['grid']))
    {
        case 'utm':
        case 'mgrs':
            $provider .= sprintf(",http://osm.stamen.com/gridtile/tilecache.cgi/1.0/%s/{Z}/{X}/{Y}.png", strtolower($_POST['grid']));
    }
    
    $dbh =& get_db_connection();
    
    $user = $user_id ? get_user($dbh, $user_id) : add_user($dbh);

    if($user)
        setcookie('visitor', write_userdata($user['id'], $language), time() + 86400 * 31);

    if($zoom && $north && $south && $east && $west)
    {
        $dbh->query('START TRANSACTION');
        
        $print = add_print($dbh, $user['id']);
        
        $print['north'] = $north;
        $print['south'] = $south;
        $print['east'] = $east;
        $print['west'] = $west;
        $print['zoom'] = $zoom;
        $print['paper'] = $paper;
        $print['provider'] = $provider;
        
        list($print['country_name'], $print['country_woeid'],
             $print['region_name'], $print['region_woeid'],
             $print['place_name'], $print['place_woeid'])
         = latlon_placeinfo(($north + $south) / 2, ($west + $east) / 2, $zoom - 1);

        $print = compose_map($print);

        set_print($dbh, $print);
        
        $dbh->query('COMMIT');
        
        $print_url = 'http://'.get_domain_name().get_base_dir().'/print.php?id='.urlencode($print['id']);
        header("Location: {$print_url}");
    }
    
    /**** ... ****/
    
    
    $sm = get_smarty_instance();
    $sm->assign('url', $url);
    $sm->assign('width', $width);
    $sm->assign('height', $height);
    $sm->assign('language', $language);
    
    header("Content-Type: text/html; charset=UTF-8");
    print $sm->fetch("compose.html.tpl");

    print_r($map_headers);
    print_r($code_headers);

?>
