<html>
    <head>
        <title>Upload mbtiles</title>
        
        <link rel="stylesheet" href="/~mevans/fieldpapers/site/www/style.css" type="text/css" />
        <link rel="stylesheet" href="/~mevans/fieldpapers/site/www/index.css" type="text/css" />
        <script type="text/javascript" src="../atlas-ui/modest_maps/modestmaps.min.js"></script>
        <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js"></script>
    </head>
    <body>
        {include file="header.htmlf.tpl"}
        {include file="navigation.htmlf.tpl"}
        
        <form enctype="multipart/form-data" action="uploader.php" method="POST">
        Upload your file: <input name="uploaded_mbtiles" type="file" /><br />
        <input type="submit" value="Upload" />
    </form>
    </body>
</html>