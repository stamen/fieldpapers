<?php

    require_once '../lib/lib.everything.php';
      
    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);
    
    $context = default_context(True);
    
    /**** ... ****/
    
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
    
    $context->sm->assign('language', $language);
    
    header("Content-Type: text/html; charset=UTF-8");
    print $sm->fetch("language.html.tpl");

?>
