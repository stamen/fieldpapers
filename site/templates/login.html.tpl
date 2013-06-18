<!DOCTYPE html>
<html lang="en">
    <head>
        <meta http-equiv="content-type" content="text/html; charset=utf-8">
        <title>Log In - fieldpapers.org</title>    
        <link rel="stylesheet" href="{$base_dir}/css/fieldpapers.css" type="text/css">
    </head>
    <body>
        {include file="navigation.htmlf.tpl"}
        <div class="smallContainer">
            {if $logged_in}
                <h1>{$username} is logged in.</h1>
                <form id='logout_form' method='POST' action='login.php'>
                    <input type='submit' id="login_button" value='Log Out'>
                    <input type='hidden' name='action' value='log out'>
                    
                    <input type='hidden' name='redirect' value='{$base_dir}/login.php'>
                </form>
            {else}
            <form id='login_form' method='post' action='{$base_dir}/login.php'>
                <h1>Log In</h1>
                    <p>
                        Username<br>
                        <input type='text' name='username' size="30">
                    </p>
                    <p>
                        Password<br>
                        <input type='password' name='password' size="30">
                    </p>
                
                <p><input type='submit' id="login_button" value='Log In'></p>
                
                <p>
                    <input type='hidden' name='action' value='log in'>
                    <!--<input type='hidden' name='redirect' value='{$smarty.server.PHP_SELF}'>-->
                    <input type='hidden' name='redirect' value='{$base_dir}/index.php'>
                </p>
                <p>Or, <a href="registration.php">create an account</a>.</p>
            </form>
            {/if}
        </div>
        <div class="container">
            {include file="footer.htmlf.tpl"}
        </div> 
    </body>
</html>