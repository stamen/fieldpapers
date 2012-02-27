<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <title>Home - fieldpapers.org</title>    
    <link rel="stylesheet" href="{$base_dir}/css/fieldpapers.css" type="text/css" />
    <script type="text/javascript" src="{$base_dir}/modestmaps.js"></script>    
    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js"></script>
</head>
<body>         
    {include file="navigation.htmlf.tpl"}
    <div class="container">  
        <h1>Welcome to Field Papers</h1>
        
        <div class="homeThird">
            <a href="{$base_dir}/atlas-search-form.php"><img src="{$base_dir}/img/graphic-make-large.gif" alt="Hand-drawn graphic to represent making a Field Papers atlas" /></a>
            <h3><a href="{$base_dir}/atlas-search-form.php">Make yourself an Atlas.</a></h3>
            <p>Print out anywhere in the world.</p>  
        </div>
        <div class="homeThird">
            <a href="{$base_dir}/atlas-search-form.php"><img src="{$base_dir}/img/graphic-in-the-field-large.gif" alt="Hand-drawn graphic a Field Papers atlas out in the wild" /></a>
            <h3><a href="{$base_dir}/atlas-search-form.php">Take it into the field.</a></h3>
            <p>Scribble on it, draw things, make notes. </p>  
        </div>
        <div class="homeThird">
            <a href="{$base_dir}/scans.php"><img src="{$base_dir}/img/graphic-scan-atlas-large.gif" alt="Hand-drawn graphic to photographing a page in a Field Papers atlas" /></a>
            <h3><a href="{$base_dir}/scans.php">Take pictures of your notes.</a></h3>
            <p><b><a href="{$base_dir}/upload.php">Upload</a></b> pages you've photographed or scanned. Here are some <a href="{$base_dir}/scans.php">recent uploads from around the world</a>.</p>  
        </div>
        
        <div class="clearfloat"></div>
        
        
<!--        {include file="hotspots.htmlf.tpl"} -->
        
        {include file="footer.htmlf.tpl"}
    </div>
</body>
</html>