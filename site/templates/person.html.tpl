<!DOCTYPE html>
<html lang="en">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8">
    <title>{$user.name} - fieldpapers.org</title>    
    <link rel="stylesheet" href="{$base_dir}/css/fieldpapers.css" type="text/css">    
</head>
<body>
    {include file="navigation.htmlf.tpl"}
    <div class="container">
        <h1>{$user.name}</h1>
        
        <ol>
            <li><a href="{$base_dir}/atlases.php?user={$user.id}">Atlases</a></li>
            <li><a href="{$base_dir}/uploads.php?user={$user.id}">Uploads</a></li>
            <li>Notes (<a href="{$base_dir}/notes.php?user={$user.id}&amp;type=json">GeoJSON</a>)</li>
        </ol>
        
        {include file="footer.htmlf.tpl"}
    </div>
</body>
</html>