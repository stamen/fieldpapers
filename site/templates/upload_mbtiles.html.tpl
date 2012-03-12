<!DOCTYPE html>
<html>
    <head>
        <title>Upload mbtiles</title>   
        <link rel="stylesheet" href="{$base_dir}/css/fieldpapers.css" type="text/css">
    </head>
    <body>
        {include file="navigation.htmlf.tpl"}
        <div class="container">
        <form enctype="multipart/form-data" action="{$base_dir}/mbtiles_uploader.php" method="POST">
            Upload your file: <input name="uploaded_mbtiles" type="file"><br>
            <input type="hidden" name="user_id" value="{$user.id}">
            <input type="submit" value="Upload">
        </form>
        {include file="footer.htmlf.tpl"}
        </div>
    </body>
</html>