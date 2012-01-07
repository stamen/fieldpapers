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
        
            $new_user = add_user($dbh);
            
            $new_user['name'] = $_POST['username'];
            $new_user['email'] = $_POST['email'];
            $new_user['password'] = $_POST['password1'];
            
            $registered_user = set_user($dbh, $new_user);
            
            if ($registered_user === false)
            {
                die('User name exists.');
            }
            
            $_SESSION['user'] = $registered_user;
            $_SESSION['logged-in'] = true;
            
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
    
    <? if($_SESSION['logged-in']) { ?>
    
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