{include file="language.htmlf.tpl"}

<h1><a href="{$base_dir}/"><img src="{$base_dir}/icon.png" border="0" align="bottom" alt="" /> Walking Papers</a></h1>

<p id="navigation">
    {if $language == "de"}
        <a href="{$base_dir}/">Home</a>
        <a href="{$base_dir}/prints.php">Ausdrucke</a>
        <a href="{$base_dir}/scans.php">Scans</a>
        <a href="{$base_dir}/upload.php">Hochladen</a>
        <a href="{$base_dir}/zeitgeist.php">Statistik</a>
        <a href="{$base_dir}/about.php">Über</a>

    {elseif $language == "nl"}
        <a href="{$base_dir}/">Index</a>
        <a href="{$base_dir}/prints.php">Afdrukken</a>
        <a href="{$base_dir}/scans.php">Scans</a>
        <a href="{$base_dir}/upload.php">Upload</a>
        <a href="{$base_dir}/zeitgeist.php">Statistiek</a>
        <a href="{$base_dir}/about.php">Over</a>


  {elseif $language == "es"}
      <a href="{$base_dir}/">Portada</a>
      <a href="{$base_dir}/prints.php">Impresiones</a>
      <a href="{$base_dir}/scans.php">Scans</a>
      <a href="{$base_dir}/upload.php">Subir</a>
      <a href="{$base_dir}/zeitgeist.php">Estadísticas</a>
      <a href="{$base_dir}/about.php">Acerca de</a>

    {else}
        <a href="{$base_dir}/">Home</a>
        <a href="{$base_dir}/prints.php">Prints</a>
        <a href="{$base_dir}/scans.php">Scans</a>
        <a href="{$base_dir}/upload.php">Upload</a>
        <a href="{$base_dir}/zeitgeist.php">Zeitgeist</a>
        <a href="{$base_dir}/about.php">About</a>
    {/if}
</p>
