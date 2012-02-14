<html>
    <head>
        <title>Upload mbtiles</title>   
        <link rel="stylesheet" href="{$base_dir}/css/fieldpapers.css" type="text/css" />
    </head>
    <body>
        {include file="header.htmlf.tpl"}
        {include file="navigation.htmlf.tpl"}
        
        <form enctype="multipart/form-data" action="{$base_dir}/mbtiles_uploader.php" method="POST">
        Upload your file: <input name="uploaded_mbtiles" type="file" /><br />
        <input type="submit" value="Upload" />
    </form>
    </body>
</html>