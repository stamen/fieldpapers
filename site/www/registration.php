<?php    

    require_once '../lib/lib.everything.php';
    
    $language = $_SERVER['HTTP_ACCEPT_LANGUAGE'];
      
    enforce_master_on_off_switch($language);
    
    /**** ... ****/
    
    session_start();
    $dbh =& get_db_connection();
    remember_user($dbh);
    
    $sm = get_smarty_instance();
           
    switch($_POST['action'])
    {
        case 'register':
            if ($_POST['password1'] != $_POST['password2'])
            {
                die('Passwords do not match. Please try again.');
            }
        
            $prev_registered_user = get_user_by_name($dbh, $_POST['username']);
            
            if($prev_registered_user)
            {
                die('Username exists.');
            }
            
            // Verify that the email address has not been used in a previous registration.
            $mailsearch = sprintf("SELECT email from users WHERE email=%s;", $dbh->quoteSmart($_POST['email']));
            $res_mailsearch = $dbh->query($mailsearch);
            $email_match = $res_mailsearch->fetchRow(DB_FETCHMODE_ASSOC);   
            
            if ($email_match)
            {
                die('Someone has already registered with that email address.');
            }
            
            $new_user = get_user($dbh, $_SESSION['user']['id']);
            
            $new_user['name'] = $_POST['username'];
            $new_user['email'] = $_POST['email'];
            $new_user['password'] = $_POST['password1'];
            
            $registered_user = set_user($dbh, $new_user);
            
            if ($registered_user === false)
            {
                die('User name exists.');
            }
            
            $hash = md5(rand(0,1000));
            $q = sprintf('UPDATE users SET hash=%s WHERE name=%s', $dbh->quoteSmart($hash), $dbh->quoteSmart($_POST['username']));
            $res = $dbh->query($q);   
            
            login_user_by_id($dbh, $registered_user['id']);
            
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
    
    header("Content-Type: text/html; charset=UTF-8");
    print $sm->fetch("registration.html.tpl");
?>