<?php
   /**
    * Display page for list of all recent prints in reverse-chronological order.
    */

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    require_once 'init.php';
    require_once 'data.php';
    require_once 'lib.auth.php';
    
    $language = $_SERVER['HTTP_ACCEPT_LANGUAGE'];
      
    enforce_master_on_off_switch($language);

    /**** ... ****/
    
    session_start();
    $dbh =& get_db_connection();
    remember_user($dbh);
    
    $pagination = array('page' => $_GET['page'], 'perpage' => $_GET['perpage']);
    
    $prints = get_prints($dbh, $pagination);
    list($count, $offset, $perpage, $page) = get_pagination($pagination);
    
    foreach ($prints as $i => $print)
    {
        $user = get_user($dbh, $prints[$i]['user_id']);
        
        if ($user['name'])
        {
            $prints[$i]['user_name'] = $user['name'];
        } else {
            $prints[$i]['user_name'] = 'Anonymous';
        }
    }

    $sm = get_smarty_instance();
    $sm->assign('prints', $prints);

    $sm->assign('count', $count);
    $sm->assign('offset', $offset);
    $sm->assign('perpage', $perpage);
    $sm->assign('page', $page);
    
    header("Content-Type: text/html; charset=UTF-8");
    print $sm->fetch("prints.html.tpl");

?>
