<?php
   /**
    * Individual page for the print
    */

    require_once '../lib/lib.everything.php';
    
    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);
    
    session_start();
    $dbh =& get_db_connection();
    remember_user($dbh);
    
    /**** ... ****/
    
    $sm = get_smarty_instance();
    
    $print_args = array(
        'date' => empty($_GET['date']) ? null : $_GET['date']
        );
    
    $prints = get_prints($dbh, $print_args);
    
    foreach($prints as $i => $print)
    {   
        $pages = get_print_pages($dbh, $print['id']);
        $user = get_user($dbh, $prints[$i]['user_id']);
        
        $prints[$i]['number_of_pages'] = count($pages);
        $prints[$i]['user_name'] = $user['name'] ? $user['name'] : 'Anonymous';
        $prints[$i]['city_name'] = $print['place_name'] ? $print['place_name'] : 'Unknown City';
    }
    
    $sm->assign('prints', $prints);
    
    $type = $_GET['type'] ? $_GET['type'] : $_SERVER['HTTP_ACCEPT'];
    $type = get_preferred_type($type);
    
    if($type == 'text/html') {
        header("Content-Type: text/html; charset=UTF-8");
        print $sm->fetch("atlases.html.tpl");
    
    } else {
        header('HTTP/1.1 400');
        die("Unknown type.\n");
    }

?>