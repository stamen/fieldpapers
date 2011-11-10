<?php

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.dirname(__FILE__).'/../lib');

    require_once 'init.php';
    require_once 'data.php';
    require_once 'lib.compose.php';
    
    $json = json_decode(file_get_contents('php://input'), true);
    
    $dbh =& get_db_connection();

    $dbh->query('START TRANSACTION');
    
    compose_from_geojson($dbh, file_get_contents('php://input'));
    
    $dbh->query('COMMIT');

?>