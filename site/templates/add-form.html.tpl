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

            <h1>Add a form</h1>

            <p>Field Papers can import a form that you've created elsewhere online, for example, in a site like Survey Monkey or Google Docs. All we need is a URL to the page that displays the form, and we'll do the rest.</p>
            
            <form action="{$base_href}" method="POST">
                <p>
                    URL of your form:<br />
                    <input name="form_url" type="text" size="60" />
                </p>

<!--                Optional title: <input name="form_title" type="text" size="30" /><br /> -->
                <p>
                        <input type="submit" value="Get Form" />
                </p>
            </form>
            
            {include file="footer.htmlf.tpl"}
        <!-- end .content --></div>
        
    <!-- end .container --></div>
</body>
</html>