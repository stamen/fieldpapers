<?php    

    require_once '../lib/lib.everything.php';
      
    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);
    
    $context = default_context(True);
    
    /**** ... ****/
    $error = '';    
    switch($_POST['action'])
    {
        case 'register':
            if (!$_POST['username']) 
            {
                //die('Please provide a user name.');
                $error = 'Please provide a user name.';
                break;
            }

            if (!$_POST['password1'])
            {
                $error = 'Please provide a password.';
                break;
            }
            
            if ($_POST['password1'] != $_POST['password2'])
            {
                $error = 'Passwords do not match. Please try again.';
                break;
            }
        
            $prev_registered_user = get_user_by_name($context->db, $_POST['username']);
            
            if($prev_registered_user)
            {
                $error = 'Username exists.';
                break;
            }
            
            // Verify that the email address has not been used in a previous registration.
            $mailsearch = "SELECT email from users WHERE email=?";
            $res_mailsearch = $context->db->query($mailsearch, $_POST['email']);
            $email_match = $res_mailsearch->fetchRow(DB_FETCHMODE_ASSOC);   
            
            if ($email_match)
            {
                $error = 'Someone has already registered with that email address.';
                break;
            }
            
            $new_user = add_user($context->db);
            
            $new_user['name'] = $_POST['username'];
            $new_user['email'] = $_POST['email'];
            $new_user['password'] = $_POST['password1'];
            
            $registered_user = set_user($context->db, $new_user);
            
            if ($registered_user === false)
            {
                $error = 'User name exists.';
                break;
            }
            
            $hash = md5(rand(0,1000));
            $q = 'UPDATE users SET hash=? WHERE name=?';
            $res = $context->db->query($q, $hash, $_POST['username']);
            
            login_user_by_id($context->db, $registered_user['id']);
            
            $to = $_POST['email'];
            $subject = 'Field Papers Verification';
            
            $url = sprintf('http://%s%s/verify.php?email=%s&hash=%s',get_domain_name(),get_base_dir(),urlencode($_POST['email']),
            urlencode($hash));
            
            
            $message = "Thanks for signing up for Field Papers!
            
            Please verify your account: {$url}
            
            ";
            
            $headers = 'From:noreply@fieldpapers.org' . "\r\n";
            mail($to, $subject, $message, $headers);
            
            // redirect
            header('Location: ' . $_POST['redirect']);
            
            break;
    }
    if(!empty($error))
    {
        $context->sm->assign('error', $error);
    } 
    header("Content-Type: text/html; charset=UTF-8");
    print $context->sm->fetch("registration.html.tpl");

?>
