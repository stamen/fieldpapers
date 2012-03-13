<?php

    require_once '../lib/lib.everything.php';

    $context = default_context();
    
    print $context->sm->fetch("upload_mbtiles.html.tpl");

?>
