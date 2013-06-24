<?php    

    require_once '../lib/lib.everything.php';
      
    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);
    
    $context = default_context(True);

    /**** ... ****/
    $error = '';
    switch($_POST['action'])
    {
        case 'log in':
            $registered_user = get_user_by_name($context->db, $_POST['username']); 
            if (!$registered_user)
            {
                $error = 'You are not registered.';
            }
            if(empty($error)){
                if (!check_user_password($context->db, $registered_user['id'], $_POST['password']))
                {
                    $error ='That\'s not the correct password!';
                }
                if(empty($error))
                {
                    login_user_by_name($context->db, $registered_user['name']); 
                    header('Location: ' . $_POST['redirect']);
                }
            } 
            break;
            
        case 'log out':
            logout_user();
            
            header('Location: ' . $_POST['redirect']);
            
            break;
    }
    
    if(is_logged_in())
    {
        $context->sm->assign('logged_in', true);
        $context->sm->assign('username', $_SESSION['user']['name']);
    }
    
    if(!empty($error))
    {
        $context->sm->assign('error', $error);
    }

    header("Content-Type: text/html; charset=UTF-8");
    print $context->sm->fetch("login.html.tpl");
?>
