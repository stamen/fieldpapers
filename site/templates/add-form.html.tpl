<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <title>Add Form - fieldpapers.org</title>    
    <link rel="stylesheet" href="{$base_dir}/css/fieldpapers.css" type="text/css" />    
    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js"></script>
</head>
<body>
    <div class="container">
        <div class="content">
            {include file="header.htmlf.tpl"}
            
            {include file="navigation.htmlf.tpl"}
            
            <form action="{$base_href}" method="POST">
                Paste in the URL of your HTML form: <input name="form_url" type="text" size="30" /><br />
                Optional title: <input name="form_title" type="text" size="30" /><br />
                <input type="submit" value="Submit" />
            </form>
            
            {include file="footer.htmlf.tpl"}
        <!-- end .content --></div>
        
    <!-- end .container --></div>
</body>
</html>