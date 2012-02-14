<?php
   /**
    * Home page
    *
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

    $sm = get_smarty_instance();
    
    $prints = get_prints($dbh, 6);
    
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