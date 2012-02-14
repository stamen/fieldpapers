<?php
   /**
    * Display page for list of all recent forms in reverse-chronological order.
    */

    require_once '../lib/lib.everything.php';
    
    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);

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
