<!DOCTYPE html>
<html lang="en">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8">
    <title>Add Form - fieldpapers.org</title>    
    <link rel="stylesheet" href="{$base_dir}/css/fieldpapers.css" type="text/css">    
    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js"></script>
</head>
<body>      
    {include file="navigation.htmlf.tpl"}
    <div class="container">
        <h1>Add a form</h1>

            <p>Field Papers can import a form that you've created elsewhere online, for example, in a site like Survey Monkey or Google Docs. All we need is a URL to the page that displays the form, and we'll do the rest.</p>
            
            <form action="{$base_href}" method="POST">
                <p>
                    URL of your form:<br>
                    <input name="form_url" type="text" size="60">
                </p>

<!--                Optional title: <input name="form_title" type="text" size="30"><br> -->
                <p>
                        <input type="submit" value="Get Form">
                </p>
            </form>
            
            {include file="footer.htmlf.tpl"}
    </div>
</body>
</html>