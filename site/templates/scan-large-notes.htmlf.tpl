{if $scan.has_geotiff == 'yes'}
    <p>
        GeoTIFF: <a href="{$scan.base_url|escape}/walking-paper-{$scan.id|escape}.tif">walking-paper-{$scan.id|escape}.tif</a>.
    </p>
{/if}

{if $scan.has_geojpeg == 'yes'}
    <p class="wide" id="notes-image">
        <img border="1" src="{$scan.base_url}/walking-paper-{$scan.id}.jpg" />
        <button id="add-note">Add Note</button>
    </p>
    <table class="wide" id="notes-rows">
        <thead>
            <tr>
                <th> </th>
                <th class="note">Note</th>
                <th>North</th>
                <th>West</th>
                <th>South</th>
                <th>East</th>
            </tr>
        </thead>
        <tbody>
            {foreach from=$notes item="note"}
                <tr>
                    <td> </td>
                    <td class="t">{$note.note|escape}</td>
                    <td class="n">{$note.north|escape}</td>
                    <td class="w">{$note.west|escape}</td>
                    <td class="s">{$note.south|escape}</td>
                    <td class="e">{$note.east|escape}</td>
                </tr>
            {/foreach}
        </tbody>
    </table>
{else}
    <p class="wide">
        <a href="{$scan.base_url}/{$scan.uploaded_file}">
            <img border="1" src="{$scan.base_url}/large.jpg" /></a>
    </p>
{/if}
