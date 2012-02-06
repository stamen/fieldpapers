<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

{include file="navigation.htmlf.tpl"}

<html lang="en">
    <head>
        <meta http-equiv="content-type" content="text/html; charset=utf-8" />
        <title>Login - fieldpapers.org</title>    
        <link rel="stylesheet" href="{$base_dir}/css/fieldpapers.css" type="text/css" />
    </head>
        <body>
            {if $logged_in}
                <h1>{$username} is logged in.</h1>
                <form id='logout_form' method='POST' action='login.php'>
                    <input type='submit' id="login_button" value='Log Out'>
                    <input type='hidden' name='action' value='log out'>
                    
                    <input type='hidden' name='redirect' value='{$base_dir}/login.php'>
                </form>
            {else}
            <form id='login_form' method='post' action='{$base_dir}/login.php'>
                <table>
                    <tbody>
                        <tr>
                            <td style="padding: 0 0 3px 4px; font-size: 1em">
                                <b>Username</b>
                            </td>
                            <td style="padding: 0 0 3px 4px; font-size: 1em">
                                <b>Password</b>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <input type='text' name='username' size="20"/>
                            </td>
                            <td>
                                <input type='password' name='password' size="20"/>
                            </td>
                            <td>
                                <input type='submit' id="login_button" value='Log In'/>
                            </td>
                        </tr>
                    </tbody>
                </table>
                <input type='hidden' name='action' value='log in'/>
                <!--<input type='hidden' name='redirect' value='{$smarty.server.PHP_SELF}' />-->
                <input type='hidden' name='redirect' value='{$base_dir}/index.php' />
            </form>
            {/if}
        </body>
</html>