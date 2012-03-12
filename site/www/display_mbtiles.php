<?php    
    require_once '../lib/lib.everything.php';

    session_start();
    $dbh =& get_db_connection();
    remember_user($dbh);
    
    $filename = $_GET['filename'] ? $_GET['filename'] : null;
    $id = $_GET['id'] ? $_GET['id'] : null;
    
    $mbtiles_data = get_mbtiles_by_id(&$dbh, $id);
    
    $sm = get_smarty_instance();
    $sm->assign('filename', $filename);
    $sm->assign('mbtiles_data', $mbtiles_data);
    
    print $sm->fetch("display_mbtiles.html.tpl");
    
?>