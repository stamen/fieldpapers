<!DOCTYPE html>
<html lang="en">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8">
    <title>Atlases - fieldpapers.org</title>    
    <link rel="stylesheet" href="{$base_dir}/css/fieldpapers.css" type="text/css">
    
<style>
/* pinterest style columns */
#columns {
    -moz-column-count: 3;
    -moz-column-gap: 10px;
    -moz-column-fill: auto;
    -webkit-column-count: 3;
    -webkit-column-gap: 10px;
    -webkit-column-fill: auto;
    column-count: 3;
    column-gap: 15px;
    column-fill: auto;
}	

.atlasPin { 
	-moz-column-break-inside: avoid; 
	-webkit-column-break-inside: avoid; 
	column-break-inside: avoid; 
	display: inline-block; 
	margin: 0 2px 15px; 
	padding: 15px; 
	border: 2px solid #FAFAFA; 
	box-shadow: 0 1px 2px rgba(34, 25, 25, 0.4); 
	background: #FEFEFE; 
	background-image: linear-gradient(45deg, #FFF, #F9F9F9); 
}

</style>    
    
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

                <a href="{$base_dir}/atlas.php?id={$print.id}">{if $print.title}{$print.title|escape}{else}Untitled{/if}</a>

                {if $print.user.name}
                    by <a href="{$base_dir}/atlases.php?user={$print.user_id}">{$print.user.name}</a>
                {else}
                    anon
                {/if}
				
                <br />
                
                {if $print.place_name}
                    <a href="{$base_dir}/atlases.php?place={$print.place_woeid}">{$print.place_name|nice_placename}</a>, 
                    <a href="{$base_dir}/atlases.php?place={$print.region_woeid}">{$print.region_name|nice_placename}</a>, 
                    <a href="{$base_dir}/atlases.php?place={$print.country_woeid}">{$print.country_name|nice_placename}</a>
                {/if}

                <br />
                
                {if $print.number_of_pages == 1}
                    1 page,
                {elseif $print.number_of_pages == 2}
                    two pages,
                {else}
                    {$print.number_of_pages} pages,
                {/if}
				<a href="{$base_dir}/atlases.php?month={"Y-m"|@date:$print.created}">{$print.age|nice_relativetime|escape}</a>
            </div>
        {/foreach}
        </div>
        
{include file="footer.htmlf.tpl"}

</div>
</body>
</html>