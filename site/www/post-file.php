<?php
   /**
    * File upload form, for sites configured to use local file storage instead of S3.
    *
    * POST vars include expiration time and signature for pre-signed posts.
    */

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'/usr/home/migurski/pear/lib');
    require_once 'init.php';
    require_once 'data.php';
    require_once 'Net/URL.php';
    
    $dirname = $_POST['dirname'] ? $_POST['dirname'] : null;
    $redirect = preg_match('#^http://#', $_POST['redirect']) ? $_POST['redirect'] : null;
    $expiration = $_POST['expiration'] ? $_POST['expiration'] : null;
    $file = is_array($_FILES['file']) ? $_FILES['file'] : null;
    
    if(strtotime($expiration) < time())
        die_with_code(401, "Sorry, expiration date $expiration has come and gone - ".date('r', strtotime($expiration)));
    
    $posted_signature = $_POST['signature'] ? $_POST['signature'] : null;
    $expected_signature = sign_post_details($dirname, $expiration, API_PASSWORD);
    
    if($posted_signature != $expected_signature)
        die_with_code(401, 'Sorry, bad signature');
    
    if(is_array($file) && is_uploaded_file($file['tmp_name']))
    {
        $object_id = rtrim($dirname, '/').'/'.ltrim($file['name'], '/');
        $content_bytes = file_get_contents($file['tmp_name']);
    
        $url = post_file_local($object_id, $content_bytes);
    }

    if($redirect)
    {
        $redirect = new Net_URL($redirect);
        $redirect->addQueryString('url', $url);
        $redirect = $redirect->getURL();
    }
    
    if($redirect)
        header("Location: {$redirect}");

    header('Content-Type: text/plain');
    echo "Thanks, I think I handled your file, so thanks.\n";

?>