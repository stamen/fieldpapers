<?php

    require_once '../lib/lib.everything.php';

    $context = default_context(True);
    
    print $context->sm->fetch("upload_mbtiles.html.tpl");

?>
