<scan id="{$scan.id|escape}" user="{$scan.user_id|escape}" href="http://{$domain}{$base_dir}{$base_href}?id={$scan.id|escape:"url"}">
    <provider href="{$scan.base_url|escape}/{literal}{Z}/{X}/{Y}{/literal}.jpg" />
    <large href="{$scan.base_url|escape}/large.jpg" />
    <qrcode href="{$scan.base_url|escape}/qrcode.jpg" />
    <private>{$scan.is_private|escape}</private>
    <will-edit>{$scan.will_edit|escape}</will-edit>
    <minimum-coord row="{$scan.min_row|escape}" column="{$scan.min_column|escape}" zoom="{$scan.min_zoom|escape}" />
    <maximum-coord row="{$scan.max_row|escape}" column="{$scan.max_column|escape}" zoom="{$scan.max_zoom|escape}" />
    {include file="print.xml.tpl"}
</scan>
