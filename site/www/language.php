<?php
   /**
    * Language setting view and change endpoint.
    *
    * Accepts POST var with replacement language setting that modifies a cookie
    * and redirects the visitor, or simply displays the current lanaguage settings.
    */

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    require_once 'init.php';
    require_once 'data.php';
    require_once 'lib.auth.php';
        
    $language = $_SERVER['HTTP_ACCEPT_LANGUAGE'];
      
    enforce_master_on_off_switch($language);
    
    session_start();
    $dbh =& get_db_connection();
    remember_user($dbh);
    
    if($_POST['language'])
    {
        // change to some other language
        $language = in_array($_POST['language'], array('en', 'de', 'nl', 'es', 'fr', 'ja', 'it', 'tr', 'ru', 'sv', 'id'))
            ? $_POST['language']
            : $language;
    
        // redirect to some other page
        $location = $_POST['referer']
            ? $_POST['referer']
            : $_SERVER['HTTP_REFERER'];

        header("Location: {$location}");
    }
    
    $sm = get_smarty_instance();
    $sm->assign('language', $language);
    
    header("Content-Type: text/html; charset=UTF-8");
    print $sm->fetch("language.html.tpl");

?>
