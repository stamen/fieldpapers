<?php

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    require_once 'qrcode.php';
    require_once 'output.php';
    
    $url = 'http://'.get_domain_name().get_base_dir().'/print.php?id='.urlencode($_GET['print']);
    $qrc = QRCode::getMinimumQRCode($url, QR_ERROR_CORRECT_LEVEL_Q);
    $img = $qrc->createImage(16, 0);

    header('Content-type: image/png');
    header("X-Content: {$url}");
    imagepng($img);
    imagedestroy($img);

?>