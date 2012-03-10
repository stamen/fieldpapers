<?php
   /**
    * Home page
    *
    */

    require_once '../lib/lib.everything.php';
    
    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);
    
    session_start();
    $dbh =& get_db_connection();
    remember_user($dbh);

    /**** ... ****/
    
    $sm = get_smarty_instance();
    
    $prints = get_prints($dbh, null, 6);
    
    // Get user names
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
    
    $sm->assign('prints', $prints);
    
    header("Content-Type: text/html; charset=UTF-8");
    print $sm->fetch("index.html.tpl");

?>