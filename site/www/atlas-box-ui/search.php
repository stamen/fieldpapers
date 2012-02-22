<?php

    require_once '../../lib/lib.everything.php';

    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);

    session_start();
    $dbh =& get_db_connection();
    remember_user($dbh);
    
    /**** ... ****/
    
    //print_r(GEOPLANET_APPID);
    $sm = get_smarty_instance();
    $sm->assign('app_id', GEOPLANET_APPID);
    
    header("Content-Type: text/html; charset=UTF-8");
    print $sm->fetch("search.html.tpl");
    
    //$mbtiles_url = 'http://'.get_domain_name().get_base_dir().'/display_mbtiles.php?filename='.urlencode($slug);
    //header("Location: http://fieldpapers.org/~mevans/fieldpapers/site/www/atlas-box-ui/new-box-ui.php");
?>