<?php

    require_once '../lib/lib.everything.php';
    require_once '../lib/qrcode.php';
    
    $language = $_SERVER['HTTP_ACCEPT_LANGUAGE'];
    
    enforce_master_on_off_switch($language);
    
    $url = 'http://'.get_domain_name().get_base_dir().'/print.php?id='.urlencode($_GET['print']);
    $qrc = QRCode::getMinimumQRCode($url, QR_ERROR_CORRECT_LEVEL_Q);
    $img = $qrc->createImage(16, 0);

    header('Content-type: image/png');
    header("X-Content: {$url}");
    imagepng($img);
    imagedestroy($img);

?>