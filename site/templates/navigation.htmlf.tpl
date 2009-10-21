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

  {elseif $language == "fr"}
      <a href="{$base_dir}/">Accueil</a>
      <a href="{$base_dir}/prints.php">Impressions</a>
      <a href="{$base_dir}/scans.php">Scans</a>
      <a href="{$base_dir}/upload.php">Envoyer</a>
      <a href="{$base_dir}/zeitgeist.php">Stats</a>
      <a href="{$base_dir}/about.php">À propos</a>

  {elseif $language == "ja"}
      <a href="{$base_dir}/">ホーム</a>
      <a href="{$base_dir}/prints.php">プリント</a>
      <a href="{$base_dir}/scans.php">取込データ</a>
      <a href="{$base_dir}/upload.php">アップロード</a>
      <a href="{$base_dir}/zeitgeist.php">統計</a>
      <a href="{$base_dir}/about.php">サイトについて</a>
  {elseif $language == "it"}
      <a href="{$base_dir}/">Home</a>
      <a href="{$base_dir}/prints.php">Stampe</a>
      <a href="{$base_dir}/scans.php">Scansioni</a>
      <a href="{$base_dir}/upload.php">Invio</a>
      <a href="{$base_dir}/zeitgeist.php">Statistiche</a>
      <a href="{$base_dir}/about.php">Di cosa si tratta</a>

    {else}
        <a href="{$base_dir}/">Home</a>
        <a href="{$base_dir}/prints.php">Prints</a>
        <a href="{$base_dir}/scans.php">Scans</a>
        <a href="{$base_dir}/upload.php">Upload</a>
        <a href="{$base_dir}/zeitgeist.php">Zeitgeist</a>
        <a href="{$base_dir}/about.php">About</a>
    {/if}
</p>
