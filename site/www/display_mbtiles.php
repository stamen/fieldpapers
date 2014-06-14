<?php    

    require_once '../lib/lib.everything.php';

    $context = default_context(True);
    
    $filename = $_GET['filename'] ? $_GET['filename'] : null;
    $id = $_GET['id'] ? $_GET['id'] : null;
    
    $mbtiles_data = get_mbtiles_by_id($context->db, $id);
    
    $context->sm->assign('filename', $filename);
    $context->sm->assign('mbtiles_data', $mbtiles_data);
    
    print $context->sm->fetch("display_mbtiles.html.tpl");
    
?>
