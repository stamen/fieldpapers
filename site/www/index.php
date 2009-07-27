<?php

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'/usr/home/migurski/pear/lib');
    require_once 'init.php';
    require_once 'data.php';
    
    list($user_id, $language) = read_userdata($_COOKIE['visitor'], $_SERVER['HTTP_ACCEPT_LANGUAGE']);

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

    /* localized strings for the index page */
    $sm->assign('nav_title', localize('Walking papers'));
    $sm->assign('nav_home', localize('Home'));
    $sm->assign('nav_prints', localize('Prints'));
    $sm->assign('nav_scans', localize('Scans'));    
    $sm->assign('nav_upload', localize('Upload'));    
    $sm->assign('nav_zeitgeist', localize('Zeitgeist'));    
    $sm->assign('nav_about', localize('About'));    

    header("Content-Type: text/html; charset=UTF-8");
    print $sm->fetch("index.html.tpl");

?>
