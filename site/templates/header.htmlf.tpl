 {if $request.session.logged_in}
        <p style='display: inline;'>
            Signed in as <b>{$request.session.user.name}</b>
            
            <form id='logout_form' name='logout_form' method='POST' action='{$base_dir}/login.php' style='display: inline;'>
                <!--<input type='submit' id="login_button" value='Log Out'>-->
                <a href="#" onClick="document.logout_form.submit();">Log out</a>
                <input type='hidden' name='action' value='log out'>
                <input type='hidden' name='redirect' value={$smarty.server.PHP_SELF}>
            </form>
        </p>
    {else}
        <p style="padding-left: 10px">
            <span><a style="text-decoration:none" href="{$base_dir}/login.php">Log in</a> or 
            <a style="text-decoration:none" href="{$base_dir}/registration.php">Register</a>
        </p>
    {/if}