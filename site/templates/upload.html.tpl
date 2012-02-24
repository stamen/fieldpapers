<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <title>Upload Scan - fieldpapers.org</title>
    <link rel="stylesheet" href="{$base_dir}/css/fieldpapers.css" type="text/css" />
    <meta http-equiv="refresh" content="30" />
</head>
<body>
    {include file="navigation.htmlf.tpl"}
    <div class="container">
        {include file="en/upload-instructions.htmlf.tpl"}
        
        {if $s3post}
            <form action="http://{$s3post.bucket|escape}.s3.amazonaws.com/" method="post" enctype="multipart/form-data">
                <input name="AWSAccessKeyId" type="hidden" value="{$s3post.access|escape}" />
                <input name="acl" type="hidden" value="{$s3post.acl|escape}" />
                <input name="key" type="hidden" value="{$s3post.key|escape}" />
                <input name="redirect" type="hidden" value="{$s3post.redirect|escape}" />
            
                <input name="policy" type="hidden" value="{$s3post.policy|escape}" />
                <input name="signature" type="hidden" value="{$s3post.signature|escape}" />
                
                <input name="file" type="file" />
                
                <br/><br/><br/>
                <input class="mac-button" type="submit" value="Upload" style='width: 80px; 
                        font-size: 100%; margin-top: 40px; display: block;'/>
            </form>
    
        {elseif $localpost}
            <form action="{$base_dir}/post-file.php" method="post" enctype="multipart/form-data">
                <input name="dirname" type="hidden" value="{$localpost.dirname|escape}" />
                <input name="redirect" type="hidden" value="{$localpost.redirect|escape}" />
            
                <input name="expiration" type="hidden" value="{$localpost.expiration|escape}" />
                <input name="signature" type="hidden" value="{$localpost.signature|escape}" />
                
                <input name="file" type="file" />
                
                <input class="mac-button" type="submit" value="Upload" style='width: 80px; 
                        font-size: 100%; margin-top: 40px; display: block;'/>
            </form>
        {/if}
        
        <p style='margin-top: 50px;'>
            Rules
            <ul type="circle">
                <li>Make sure the scan/photo/image is at least 200dpi.</li>
                <li>Make sure you're uploading a JPG, PNG, TIF, or GIF. (PDFs won't work.)</li>
                <li>Don't upload things that aren't Field Papers maps, please.</li>
            </ul>
        </p>
    
        {include file="footer.htmlf.tpl"}
    </div>
</body>
</html>
