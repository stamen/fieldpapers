<?php
    require_once '../lib/lib.everything.php';

    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);

    session_start();
    $dbh =& get_db_connection();
    remember_user($dbh);
    
    /**** ... ****/
    
    $user = cookied_user($dbh);
    
    $sm = get_smarty_instance();
    
    if($_GET['error'] == 'no_response')
    {
        $sm->assign('error', $_GET['error']);
    }
    
    $user_mbtiles = get_mbtiles_by_user_id($dbh, $user['id']);
    
    if ($user_mbtiles)
    {
        $sm->assign('user_mbtiles', $user_mbtiles);
    }
    
    header("Content-Type: text/html; charset=UTF-8");
    print $sm->fetch("atlas-search-form.html.tpl");
    
?>