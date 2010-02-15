<?php
   /**
    * Home page with information and print form.
    *
    * GET vars for prepositioning map form include bounding box and tile provider.
    */

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'/usr/home/migurski/pear/lib');
    require_once 'init.php';
    require_once 'data.php';
    
    list($user_id, $language) = read_userdata($_COOKIE['visitor'], $_SERVER['HTTP_ACCEPT_LANGUAGE']);
    $provider = is_null($_GET['provider']) ? 'http://tile.openstreetmap.org/{Z}/{X}/{Y}.png' : $_GET['provider'];
    $latitude = is_numeric($_GET['lat']) ? floatval($_GET['lat']) : 18.5477;
    $longitude = is_numeric($_GET['lon']) ? floatval($_GET['lon']) : -72.3376;
    $zoom = is_numeric($_GET['zoom']) ? intval($_GET['zoom']) : 14;

    /**** ... ****/
    
    $dbh =& get_db_connection();
    
    if($user_id)
        $user = get_user($dbh, $user_id);

    if($user)
        setcookie('visitor', write_userdata($user['id'], $language), time() + 86400 * 31);
    
    $prints = get_prints($dbh, 3);
    $scans = get_scans($dbh, 3);

    $sm = get_smarty_instance();
    $sm->assign('prints', $prints);
    $sm->assign('scans', $scans);
    $sm->assign('language', $language);

    $sm->assign('provider', $provider);
    $sm->assign('latitude', $latitude);
    $sm->assign('longitude', $longitude);
    $sm->assign('zoom', $zoom);
    
    $sm->assign('paper_sizes', array('Letter', 'A4', 'A3'));

    header("Content-Type: text/html; charset=UTF-8");
    print $sm->fetch("index.html.tpl");

?>
