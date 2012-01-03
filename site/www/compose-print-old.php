<?php

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.dirname(__FILE__).'/../lib');

    require_once 'init.php';
    require_once 'data.php';
    require_once 'lib.compose.php';
    
    if($_SERVER['REQUEST_METHOD'] == 'POST')
    {
        $dbh =& get_db_connection();
        $dbh->query('START TRANSACTION');
        
        $print = compose_from_fields($dbh, $_POST);
        
        $dbh->query('COMMIT');
        
        $print_url = 'http://'.get_domain_name().get_base_dir().'/print.php?id='.urlencode($print['id']);
        header("Location: {$print_url}");
    }
    
?>