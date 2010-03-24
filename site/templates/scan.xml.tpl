<scan id="{$scan.id|escape}" user="{$scan.user_id|escape}" href="http://{$domain}{$base_dir}{$base_href}?id={$scan.id|escape:"url"}">
    <base href="{$scan.base_url|escape}" />
    <private>{$scan.is_private|escape}</private>
    <will-edit>{$scan.will_edit|escape}</will-edit>
    <minimum-coord row="{$scan.min_row|escape}" column="{$scan.min_column|escape}" zoom="{$scan.min_zoom|escape}" />
    <maximum-coord row="{$scan.max_row|escape}" column="{$scan.max_column|escape}" zoom="{$scan.max_zoom|escape}" />
</scan>
