{include file="language.htmlf.tpl"}

<h1><a href="{$base_dir}/"><img src="{$base_dir}/icon.png" border="0" align="bottom" alt="" />Walking Papers</a></h1>

<p id="navigation">
    {if $language == "de"}
        <a href="{$base_dir}/">Home</a>
        <a href="{$base_dir}/prints.php">Drucke</a>
        <a href="{$base_dir}/scans.php">Scans</a>
        <a href="{$base_dir}/upload.php">Hochladen</a>
        <a href="{$base_dir}/zeitgeist.php">Statistik</a>
        <a href="{$base_dir}/about.php">Über</a>

    {elseif $language == "nl"}
        <a href="{$base_dir}/">Home</a>
        <a href="{$base_dir}/prints.php">Prints</a>
        <a href="{$base_dir}/scans.php">Scans</a>
        <a href="{$base_dir}/upload.php">Upload</a>
        <a href="{$base_dir}/zeitgeist.php">Zeitgeist</a>
        <a href="{$base_dir}/about.php">About</a>

    {else}
        <a href="{$base_dir}/">Home</a>
        <a href="{$base_dir}/prints.php">Prints</a>
        <a href="{$base_dir}/scans.php">Scans</a>
        <a href="{$base_dir}/upload.php">Upload</a>
        <a href="{$base_dir}/zeitgeist.php">Zeitgeist</a>
        <a href="{$base_dir}/about.php">About</a>
    {/if}
</p>
