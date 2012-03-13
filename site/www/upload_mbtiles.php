<?php

    require_once '../lib/lib.everything.php';

    $context = default_context();
    
    $context->sm->assign('user', $context->user);
    
    print $context->sm->fetch("upload_mbtiles.html.tpl");
?>
