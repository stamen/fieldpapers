<?php

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'/usr/home/migurski/pear/lib');
    require_once 'init.php';
    require_once 'data.php';
    
    $base_url = 'http://'.get_domain_name().get_base_dir();
    $url = strpos($_GET['url'], $base_url) === 0 ? $_GET['url'] : null;
    
    $req = new HTTP_Request($url);
    $req->sendRequest();
    
    $base_url = new Net_URL($base_url);
    $preview_href = $req->getResponseHeader('x-scan-preview-url');
    
    if(strpos($preview_href, 'http://') === 0) {
        $preview_url = new Net_URL($preview_href);
    
    } elseif(strpos($preview_href, '/') === 0) {
        $preview_url = new Net_URL('http://'.$base_url->host.$preview_href);
    
    } else {
        $preview_url = new Net_URL('http://'.$base_url->host.dirname($base_url->path).'/'.$preview_href);
    }
    
    header('Content-Type: text/json');

    echo json_encode(array('version' => '1.0',
                           'provider_name' => 'Walking Papers',
                           'provider_url' => 'http://'.get_domain_name(),
                           'type' => 'photo',
                           'url' => $preview_url->getURL()));

?>
