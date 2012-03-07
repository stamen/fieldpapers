<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <title>Set Layout - fieldpapers.org</title>    
    <link rel="stylesheet" href="{$base_dir}/css/fieldpapers.css" type="text/css" />
    <style type="text/css">
        {literal}
            .subnav {
               display: inline-block;
               padding-left: 10px;
               padding-top: 10px;
               margin-left: 0px;
               border-top: 2px solid #000;
               width: 75px;
               text-align: left;
               
               color: #CCC;
               font-size: 12px;
            }
            
            .subnav.layout {
               color: #000;
            }
        {/literal}
    </style>
</head>
<body>      
    {include file="navigation.htmlf.tpl"}
    <div style="width: 100%; text-align: center;">
        <span class="subnav area">
            <span id="area">
                <span>1.</span><br />
                <span><b>AREA</b></span>
            </span>
        </span>
        <span class="subnav info">
            <span>
                <span>2.</span><br />
                <span><b>INFO</b></span>
            </span>
        </span>
        <span class="subnav layout">
            <span>
                <span>3.</span><br />
                <span><b>LAYOUT</b></span>
            </span>
        </span>
    </div>
    <div class="container">
    <form id="compose_print" action="{$base_dir}/compose-print.php" method="POST">    
        <span style="font-size: 22px;">Choose a Layout</span>
        
        <div style="margin-top: 20px">
        <div class="homeThird">
            <img src="{$base_dir}/img/image-make-maps-only.png" alt="Make Maps Only" />
            <div style="text-align: left; margin-left: 90px;">
                <input style="margin-right: 10px" type="radio" name="layout" value="full-page" />
                Maps Only
                <br /><span style="font-size: .8em; color: #666; margin-left: 30px;">one per page</span>
            </div>
        </div>
        <div class="homeThird">
            <img src="{$base_dir}/img/image-make-map-notes.png" alt="Maps and Notes on Their Own Page" />
            <div style="text-align: left; margin-left: 90px;">
            <input style="margin-right: 10px" type="radio" name="layout" value="half-page" />
            Maps + Notes
            <br /><span style="font-size: .8em; color: #666; margin-left: 30px;">on their own pages</span>
            </div>
        </div>
        <div class="homeThird">
            <img src="{$base_dir}/img/image-make-maps-notes-2up.png" alt="Maps and Notes on the Same Page" />
            <div style="text-align: left; margin-left: 90px;">
                <input style="margin-right: 10px" type="radio" name="layout" value="full-page" />
                Maps + Notes
                <br /><span style="font-size: .8em; color: #666; margin-left: 30px;">on same page</span>
            </div>
        </div>
        <div class="clearfloat"></div>
        <div style="float: right; margin-top: 60px;">
            <input type="submit" value="Finished!" />
        </div>
    </form>
    </div>
            {include file="footer.htmlf.tpl"}
    </div>
</body>
</html>