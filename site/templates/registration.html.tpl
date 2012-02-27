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
        <div class="smallContainer">
            <h1>Create a Field Papers Account</h1>
                <form id='register_form' method='POST' action='login.php' style="margin-left: 10px;">
					<p>
                    	Your Email Address<br />
                        <input type='text' name='email' size='30' />
					</p>
                    <p>                       
                        Choose a Username<br />
<input type='text' name='username'>
					</p>
					<p>
                        Choose a Password<br />
						<input type='password' name='password1'>
                    </p>
					<p style="padding-left: 20px;">                        Type your Password Again<br />
						<input type='password' name='password2'>
                    </p>
                    
                    <p>
                    	<input type='submit' id="login_button" value='Register'>
                    </p>
                    
                    <input type='hidden' name='action' value='register'>
                    <input type='hidden' name='redirect' value='index.php'>
                </form>
        </div>
        {include file="footer.htmlf.tpl"}        
    </body>
</html>