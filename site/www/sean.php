<?php

    require_once '../lib/lib.everything.php';

    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);

    $context = default_context(True);

    /**** ... ****/

    if($_POST['ttitle']){
        $q = 'INSERT INTO uni_test (`title`) VALUES ("'.$_POST['ttitle'].'")';
        $context->db->query($q);


    }

    header("Content-Type: text/html; charset=UTF-8");
    print $context->sm->fetch("sean.html.tpl");

?>
