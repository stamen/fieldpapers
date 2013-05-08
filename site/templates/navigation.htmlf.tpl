<div class="navbar" id="nav">
    <div class="logo">
        <a href="{$base_dir}/"><img src="{$base_dir}/img/logo-header.png" height="58" width=200"></a>
    </div>
    <ul>
        <li>
            <a href="{$base_dir}/make-step1-search.php">
                <span class="section">MAKE</span><br>
                <!--<span class="desc">is <span style="background-color:yellow;">temporarily unavailable</span></span>-->
                <span class="desc">an atlas to print</span>
            </a>
        </li>
        <li>
            <a href="{$base_dir}/upload.php">
                <span class="section">UPLOAD</span><br>
                <span class="desc">pages you've marked</span>
            </a>
        </li>
        <li>
            <a href="{$base_dir}/atlases.php">
                <span class="section">WATCH</span><br>
                <span class="desc">recent activity</span>
            </a>
        </li>
        {if $request.authenticated}
        	<li>
                <span class="section"><a href="{$base_dir}/atlases.php?user={$request.user.id}">{$request.user.name}</a></span><br>
                <form id='logout_form' name='logout_form' method='POST' action='{$base_dir}/login.php'>
                    <a href="#" onClick="document.logout_form.submit();"><span class="desc">log out</span></a>
                    <input type='hidden' name='action' value='log out'>
                    <!--<input type='hidden' name='redirect' value={$smarty.server.PHP_SELF}>-->
                    <input type='hidden' name='redirect' value="{$base_dir}/">
                </form>
            </li>
        {else}
            <li>
                <span class="section"><a href="{$base_dir}/login.php">LOG IN</a></span><br>
                <span class="desc">or <a href="{$base_dir}/registration.php">create an account</a></span>
            </li>
        {/if}
    </ul>
</div>

<!-- If Error -->
<div id="error" class="container">
    <strong><em>Drat!</em></strong> We have a problem.<br />
    <span class="explanation">[Problem message/Error report]</div>
</div>
            
