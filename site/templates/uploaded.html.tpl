<!DOCTYPE html>
<html lang="en">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8">
    <title>Uploaded Scan (Field Papers)</title>
    <link rel="stylesheet" href="{$base_dir}/css/fieldpapers.css" type="text/css">
    <style type="text/css" title="text/css">
    /* <![CDATA[{literal} */
    
        form label
        {
            font-weight: bold;
        }
    
    /* {/literal}]]> */
    </style>
</head>
<body>
    {include file="navigation.htmlf.tpl"}
    <div class="container">
    
        <div class="smallContainer">    
        
            <h2>File Received!</h2>
            <!--
            <p>
                You’ve just uploaded a scanned map, and you’re about to add
                a few bits of information about it before you proceed to trace it.
            </p>
            -->
            <form action="{$base_dir}/snapshot.php?id={$scan.id|escape}" method="post" enctype="multipart/form-data">
                <!--
                {*
                <p>
                    private?
                    <input type="checkbox" value="yes" name="is_private" {if $scan.is_private == 'yes'}checked="checked"{/if}>
                </p>
                *}
            
                <p>
                    <label>
                        Do you plan to edit this yourself?
        
                        <select name="will_edit">
                            <option label="{$label}" value="yes" {if $scan.will_edit == 'yes'}selected="selected"{/if}>Yes</option>
                            <option label="{$label}" value="no"  {if $scan.will_edit == 'no'}selected="selected"{/if}>No</option>
                        </select>
                    </label>
                    <br>
                    You don’t have to do your own OpenStreetMap editing. Saying “no”
                    will let other visitors know about scans they can help with.
                </p>
            
                <p>
                    <label for="description">Describe your additions.</label>
                    <br>
                        Did you add businesses, fix footpaths, mark traffic lights, outline parks,
                        place mailboxes? Write a few words about the changes to this area.
                    <br>
                    <textarea name="description" rows="10" cols="40">{$scan.description|escape}</textarea>
                </p>
                -->
                <p>
                    <input class="mac-button" type="submit" value="Next">
                </p>
            </form>
        </div>
        
{include file="footer.htmlf.tpl"}

	</div>
</body>
</html>