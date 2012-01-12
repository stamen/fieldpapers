    {if $request.session.logged_in}
        <p>Signed in as <b>{$request.session.user.name}</b></p>
        
        <form id='logout_form' method='POST' action='login.php'>
            <input type='submit' id="login_button" value='Log Out'>
            <input type='hidden' name='action' value='log out'>
            <input type='hidden' name='redirect' value={$smarty.server.PHP_SELF}>
        </form>
    {else}
        <form id='login_form' method='POST' action='login.php'>
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
                            <input type='text' name='username' size="20">
                        </td>
                        <td>
                            <input type='password' name='password' size="20">
                        </td>
                        <td>
                            <input type='submit' id="login_button" value='Log In'>
                        </td>
                    </tr>
                </tbody>
            </table>
            <input type='hidden' name='action' value='log in'>
            <input type='hidden' name='redirect' value={$smarty.server.PHP_SELF} >
        </form>
        <p style="padding-left: 10px">
            <a style="text-decoration:none" href="{$base_dir}/registration.php">Register</a>
        </p>
    {/if}