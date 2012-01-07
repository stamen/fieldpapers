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
            $new_user = add_user($dbh);
            
            $new_user['name'] = $_POST['username'];
            $new_user['email'] = $_POST['email'];
            $new_user['password'] = $_POST['password1'];
            
            $registered_user = set_user($dbh, $new_user);
            
            if ($registered_user === false)
            {
                die('User name exists.');
            }
            
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
        
        
            break;
            
        case 'log out':
            break;
    }
       
    if (false && $_POST['username'])
    {
        // Check to see if the user exists
        /*
        $q = sprintf('SELECT id FROM users WHERE name=%s;', $dbh->quoteSmart($_POST['username'])); // Do this each time
        $res = $dbh->query($q);
        $existing_user_id = $res->fetchRow(DB_FETCHMODE_ASSOC);
        */
        
        
        
        if ($existing_user_id['id']) {
            // Check the user's password
            $correct_password = check_user_password($dbh, $existing_user_id['id'], $_POST['password']); // boolean
            
            if($correct_password) {
                $_SESSION['username'] = $_POST['username'];
                $_SESSION['user-id'] = $existing_user_id['id'];
                
                echo 'Welcome back, ' . $_POST['username'] . '!<br><br>';
                
                $user = get_user($dbh, $existing_user_id['id']);
                $user['name'] = $_POST['username'];
                $user['password'] = $_POST['password'];
                $user['email'] = $_POST['email'];
                set_user($dbh, $user);
            } else {
                $_SESSION['username'] = $_POST['username'];
                echo 'Sorry ' . $_POST['username'] . ', your password is incorrect. Please try again.<br><br>';
            }
        } else {
            // Register
            $added_user = add_user($dbh);
            
            $user = get_user($dbh, $added_user['id']);
            $user['name'] = $_POST['username'];
            $user['password'] = $_POST['password'];
            $user['email'] = $_POST['email'];
            set_user($dbh, $user);
            
            $_SESSION['username'] = $_POST['username'];
            $_SESSION['user-id'] = $added_user['id'];
            echo 'Welcome to Field Papers, ' . $_POST['username'] . '!<br><br>';
        }
    }
?>
<html>
    <head>
        <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js"></script>
        <script type="text/javascript">
        /*
            $(document).ready(function() {
                $("#login_button").click(function() {
                    $('form#user_form').attr({action:"login.php"});
                    $('form#user_form').submit();
                });
            });
            */
        </script>
    </head>
    <body>
    
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
    
    <!-- otherwise, user is logged in -->
    <form id='logout_form' method='POST' action='login.php'>
        <input type='submit' id="login_button" value='Log Out'>
        <input type='hidden' name='action' value='log out'>
    </form>
    
    </body>
</html>