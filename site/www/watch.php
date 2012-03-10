<?php
   /**
    * Display page for list of all recent prints in reverse-chronological order.
    */

    require_once '../lib/lib.everything.php';
      
    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);
    
    session_start();
    $dbh =& get_db_connection();
    remember_user($dbh);

    /**** ... ****/
        
    $pagination = array('page' => $_GET['page'], 'perpage' => $_GET['perpage']);
    
    $prints = get_prints($dbh, null, $pagination);
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
        
        if ($print['place_name'])
        {
            $place_name = explode(',', $print['place_name']);
        
            $prints[$i]['city_name'] = $place_name[0];
        } else {
            $prints[$i]['city_name'] = 'Unknown City';
        }
        
        $pages = get_print_pages($dbh, $print['id']);
        $prints[$i]['page_count'] = count($pages);
    }
    
    $sm = get_smarty_instance();
    $sm->assign('prints', $prints);

    $sm->assign('count', $count);
    $sm->assign('offset', $offset);
    $sm->assign('perpage', $perpage);
    $sm->assign('page', $page);
    
    header("Content-Type: text/html; charset=UTF-8");
    print $sm->fetch("watch.html.tpl");

?>
