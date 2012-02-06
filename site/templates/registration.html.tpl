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
        
        <b>Register</b><br /><br />
            <form id='register_form' method='POST' action='login.php'>
                Email: <input type='text' name='email'><br />
                Username: <input type='text' name='username'><br />
                Password: <input type='password' name='password1'><br />
                Password Again: <input type='password' name='password2'><br />
                <input type='submit' id="login_button" value='Register'>
                <input type='hidden' name='action' value='register'>
                
                <input type='hidden' name='redirect' value='index.php'>
            </form>
        </body>
<html>