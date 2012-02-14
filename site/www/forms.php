<?php
   /**
    * Display page for list of all recent forms in reverse-chronological order.
    */

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    require_once 'init.php';
    require_once 'data.php';
    require_once 'lib.auth.php';
    require_once 'lib.forms.php';
    
    $language = $_SERVER['HTTP_ACCEPT_LANGUAGE'];
    
    enforce_master_on_off_switch($language);

    /**** ... ****/
    
    session_start();
    $dbh =& get_db_connection();
    remember_user($dbh);
    
    $pagination = array('page' => $_GET['page'], 'perpage' => $_GET['perpage']);
    
    $forms = get_forms($dbh, $pagination);
    
    foreach ($forms as $i => $form)
    {
        $user = get_user($dbh, $form['user_id']);
        
        if ($user['name'])
        {
            $forms[$i]['user'] = $user['name'];
        } else {
            $forms[$i]['user'] = 'Anonymous';
        }
    
    }
    
    list($count, $offset, $perpage, $page) = get_pagination($pagination);

    $sm = get_smarty_instance();
    $sm->assign('forms', $forms);

    $sm->assign('count', $count);
    $sm->assign('offset', $offset);
    $sm->assign('perpage', $perpage);
    $sm->assign('page', $page);
    
    header("Content-Type: text/html; charset=UTF-8");
    print $sm->fetch("forms.html.tpl");

?>
