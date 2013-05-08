<div class="navbar" id="nav">
    <div class="logo">
        <a href="{$base_dir}/"><img src="{$base_dir}/img/logo-header.png" height="58" width=200"></a>
    </div>
    <ul>
        <li>
            <a href="{$base_dir}/make-step1-search.php">
                <div class="section">MAKE</div>
                <!--<div class="desc">is <div style="background-color:yellow;">temporarily unavailable</span></div>-->
                <div class="desc">an atlas to print</div>
            </a>
        </li>
        <li>
            <a href="{$base_dir}/upload.php">
                <div class="section">UPLOAD</div>
                <div class="desc">pages you've marked</div>
            </a>
        </li>
        <li>
            <a href="{$base_dir}/atlases.php">
                <div class="section">WATCH</div>
                <div class="desc">recent activity</div>
            </a>
        </li>
        {if $request.authenticated}
        	<li>
                <div class="section"><a href="{$base_dir}/atlases.php?user={$request.user.id}">{$request.user.name}</a></div>
                <form id='logout_form' name='logout_form' method='POST' action='{$base_dir}/login.php'>
                    <a href="#" onClick="document.logout_form.submit();"><div class="desc">log out</div></a>
                    <input type='hidden' name='action' value='log out'>
                    <!--<input type='hidden' name='redirect' value={$smarty.server.PHP_SELF}>-->
                    <input type='hidden' name='redirect' value="{$base_dir}/">
                </form>
            </li>
        {else}
            <li>
                <div class="section"><a href="{$base_dir}/login.php">LOG IN</a></div>
                <div class="desc">or <a href="{$base_dir}/registration.php">create an account</a></div>
            </li>
        {/if}
    </ul>
</div>

<!-- If Error -->
<!--
<div id="error" class="container">
    <strong><em>Drat!</em></strong> We have a problem.<br />
    <span class="explanation">[Problem message/Error report]</div>
</div>
-->        
