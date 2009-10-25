<?php

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'/usr/home/migurski/pear/lib');
    require_once 'init.php';
    require_once 'data.php';
    
    $expiration = $_POST['expiration'] ? $_POST['expiration'] : null;
    
    if(strtotime($expiration) < time())
        die_with_code(401, 'Sorry, expiration date has come and gone');
    
    $posted_signature = $_POST['signature'] ? $_POST['signature'] : null;
    $expected_signature = sign_post_details($expiration, API_PASSWORD);
    
    if($posted_signature != $expected_signature)
        die_with_code(401, 'Sorry, bad signature');
    
    header('Content-Type: text/plain');
    echo "Thanks, I have no idea what do with a file yet, but thanks.\n";
    echo "$posted_signature vs $expected_signature\n";
    print_r($_GET);
    print_r($_POST);
    print_r($_FILES);

?>