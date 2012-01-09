<?php    
    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.dirname(__FILE__).'/../lib');
    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'/usr/home/migurski/pear/lib');
    require_once 'init.php';
    require_once 'data.php';
    require_once 'lib.auth.php';
    
    session_start();
    
    $_SESSION['login-attempts'] += 1;
    
    $dbh =& get_db_connection();
    
    switch($_POST['action'])
    {
        case 'register':
            if ($_POST['password1'] != $_POST['password2'])
            {
                die('Passwords do not match. Please try again.');
            }
        
            $registered_user = get_user_by_name($dbh, $_POST['username']);
            
            if($registered_user)
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
            
            $new_user = add_user($dbh);
            
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
            
            $_SESSION['user'] = $registered_user;
            $_SESSION['logged-in'] = true;
            
            $to = $_POST['email'];
            $subject = 'Field Papers Verification';
            $message = 'Thanks for signing up for Field Papers!
            
            Please verify your account: 
            
            http://fieldpapers.org/~mevans/fieldpapers/site/www/verify.php?email='.$_POST['email'].'&hash='.$hash.'
            
            ';
            
            $headers = 'From:noreply@fieldpapers.org' . "\r\n";
            mail($to, $subject, $message, $headers);
            
            break;
        
        case 'log in':
            $registered_user = get_user_by_name($dbh, $_POST['username']);
            
            if (!$registered_user)
            {
                die('You are not registered.');
            }
            
            if (!check_user_password($dbh, $registered_user['id'], $_POST['password']))
            {
                die('That\'s not the correct password!');
            }
        
            $_SESSION['user'] = $registered_user;
            $_SESSION['logged-in'] = true;
        
            break;
            
        case 'log out':
        
            $_SESSION['user'] = false;
            $_SESSION['logged-in'] = false;
            
            break;
    }
?>
<html>
    <head>
        <title>Welcome</title>
    <body>
    
    <? if($_SESSION['logged-in']) { echo $_POST['username'] . ' is logged in.';?>
    
        <!-- otherwise, user is logged in -->
        <form id='logout_form' method='POST' action='login.php'>
            <input type='submit' id="login_button" value='Log Out'>
            <input type='hidden' name='action' value='log out'>
        </form>
    
    <? } else { ?>
    
        <!-- if the user is not logged in -->
        <form id='login_form' method='POST' action='login.php'>
            Username: <input type='text' name='username'><br />
            Password: <input type='password' name='password'><br />
            <input type='submit' id="login_button" value='Log In'>
            <input type='hidden' name='action' value='log in'>
        </form>
    
        <form id='register_form' method='POST' action='login.php'>
            Email: <input type='text' name='email'><br />
            Username: <input type='text' name='username'><br />
            Password: <input type='password' name='password1'><br />
            Password Again: <input type='password' name='password2'><br />
            <input type='submit' id="login_button" value='Register'>
            <input type='hidden' name='action' value='register'>
        </form>
    
    <? } ?>
    
    <pre>
        <?php print_r($_SESSION); ?>
    </pre>
    </body>
</html>