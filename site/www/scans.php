<?php
   /**
    * Display page for list of all recent scans in reverse-chronological order.
    */

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
    
    $pagination = array('page' => $_GET['page'], 'perpage' => $_GET['perpage']);
    
    $scans = get_scans($dbh, $pagination, false);
    list($count, $offset, $perpage, $page) = get_pagination($pagination);

    $sm = get_smarty_instance();
    $sm->assign('scans', $scans);
    $sm->assign('language', $language);

    $sm->assign('count', $count);
    $sm->assign('offset', $offset);
    $sm->assign('perpage', $perpage);
    $sm->assign('page', $page);
    
    header("Content-Type: text/html; charset=UTF-8");
    print $sm->fetch("scans.html.tpl");

?>
