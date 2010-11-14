{assign var="cols" value=4}
{assign var="cells" value=$scans|@count}
{assign var="rows" value=$cells/$cols|@ceil}

<table class="scans">
    {foreach from=1|@range:$rows item="row" name="rows"}
        <tr class="preview">
            {foreach from=1|@range:$cols item="col" name="cols"}
                {assign var="index" value=$smarty.foreach.rows.index*$cols+$smarty.foreach.cols.index}
                {assign var="scan" value=$scans.$index}

                <td>
                    {if $scan}
                        <a href="{$base_dir}/scan.php?id={$scan.id|escape}">
                            <img border="1" src="{$scan.base_url}/preview.jpg" /></a>
                    {/if}
                </td>
            {/foreach}
        </tr>

        <tr class="info">
            {foreach from=1|@range:$cols item="col" name="cols"}
                {assign var="index" value=$smarty.foreach.rows.index*$cols+$smarty.foreach.cols.index}
                {assign var="scan" value=$scans.$index}

                <td>
                    {if $scan}
                        {if $scan.print_place_woeid}
                            <a href="{$base_dir}/scan.php?id={$scan.id|escape}">
                                <b id="scan-{$scan.id|escape}">{$scan.age|nice_relativetime|escape}
                                    {if $scan.will_edit == 'no'}✻{/if}</b>
                                <br />
                                {$scan.print_place_name|escape}</a>
        
                        {else}
                            <a href="{$base_dir}/scan.php?id={$scan.id|escape}">
                                <b id="scan-{$scan.id|escape}">{$scan.age|nice_relativetime|escape}
                                    {if $scan.will_edit == 'no'}✻{/if}</b></a>
            
                            <script type="text/javascript" language="javascript1.2" defer="defer">
                            // <![CDATA[
                            
                                var onPlaces_{$scan.id|escape} = new Function('res', "appendPlacename(res, document.getElementById('scan-{$scan.id|escape}'))");
                                getPlacename({$scan.print_latitude|escape}, {$scan.print_longitude|escape}, '{$constants.FLICKR_KEY|escape}', 'onPlaces_{$scan.id|escape}');
                        
                            // ]]>
                            </script>
                        {/if}
        
                        {if $scan.description}
                            <br />
                            {$scan.description|escape}
                        {/if}
                    {/if}
                </td>
            {/foreach}
        </tr>
    {/foreach}
</table>
