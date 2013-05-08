<!DOCTYPE html>
<html lang="en">
<head>
<meta http-equiv="content-type" content="text/html; charset=utf-8">
<title>Atlases - fieldpapers.org</title>
<link rel="stylesheet" href="{$base_dir}/css/fieldpapers.css" type="text/css">
</head>
<body>
{include file="navigation.htmlf.tpl"}
<div class="container">
    <h1>Atlases {$title|escape}</h1>
    <h2>Atlases | <a href="{$base_dir}/snapshots.php?{$request.query|escape}">Snapshots</a></h2>
    <div id="columns"> 
    	{foreach from=$prints item="print" name="index"}
            <div class="atlasPin"> 
                <a href="{$base_dir}/atlas.php?id={$print.id}"><img src="{$print.preview_url}" alt="printed page" width="100%"></a> 
                <a href="{$base_dir}/atlas.php?id={$print.id}"><strong>{if $print.title}{$print.title|escape}{else}Untitled{/if}</strong></a> 
                    {if $print.user.name}
                        by <a href="{$base_dir}/atlases.php?user={$print.user_id}"><strong>{$print.user.name}</strong></a> 
                    {else}
                        <small>&nbsp;anonymous</small>
                    {/if} 
                    <br />
                    <small>
                    {if $print.number_of_pages == 1}
                        1 page,
                    {elseif $print.number_of_pages == 2}
                        two pages,
                    {else}
                        {$print.number_of_pages} pages
                    {/if} 
                    <a href="{$base_dir}/atlases.php?month={"Y-m"|@date:$print.created}">{$print.age|nice_relativetime|escape}</a> 
                    <br />
                    {if $print.place_name} 
                        <a href="{$base_dir}/atlases.php?place={$print.place_woeid}">{$print.place_name|nice_placename}</a>, 
                        <a href="{$base_dir}/atlases.php?place={$print.region_woeid}">{$print.region_name|nice_placename}</a>, 
                        <a href="{$base_dir}/atlases.php?place={$print.country_woeid}">{$print.country_name|nice_placename}</a> 
                    {/if} 
                    </small>
             </div>
        {/foreach} 
    </div>
    
    <div class="pagination">
      <ul>
        <li><a href="#">Prev</a></li>
        <li><a href="#">1</a></li>
        <li><a href="#">2</a></li>
        <li><a href="#">3</a></li>
        <li><a href="#">4</a></li>
        <li><a href="#">5</a></li>
        <li><a href="#">Next</a></li>
      </ul>
    </div>
	<div class="clearfloat"></div>

    {include file="footer.htmlf.tpl"} 
</div>
</body>
</html>