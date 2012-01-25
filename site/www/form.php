<?php
    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    require_once '../lib/init.php';
    require_once '../lib/data.php';
    require_once '../lib/lib.forms.php';
    require_once '../lib/lib.auth.php';

/*

displays a form if finished
displays waiting page if not
give a form id, until the form exists*/

    echo $_GET["id"];

    //$dbh =& get_db_connection();
    

?>