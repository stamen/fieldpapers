<?php

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.dirname(__FILE__).'/../lib');
    require_once 'init.php';
    require_once 'data.php';

    $json = json_decode(file_get_contents('php://input'), true);
    print_r($json);

?>