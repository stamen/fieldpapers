<?php

    require_once '../lib/lib.everything.php';
    
    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);

    $context = default_context(True);

    /**** ... ****/
    
    $pagination = array('page' => $_GET['page'], 'perpage' => $_GET['perpage']);
    
    $forms = get_forms($context->db, null, $pagination);
    
    foreach ($forms as $i => $form)
    {
        $user = get_user($context->db, $form['user_id']);
        
        if ($user['name'])
        {
            $forms[$i]['user'] = $user['name'];
        } else {
            $forms[$i]['user'] = 'Anonymous';
        }
    
    }
    
    list($count, $offset, $perpage, $page) = get_pagination($pagination);

    $context->sm->assign('forms', $forms);

    $context->sm->assign('count', $count);
    $context->sm->assign('offset', $offset);
    $context->sm->assign('perpage', $perpage);
    $context->sm->assign('page', $page);
    
    header("Content-Type: text/html; charset=UTF-8");
    print $context->sm->fetch("forms.html.tpl");

?>
