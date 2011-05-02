{if $scan.has_geojpeg == 'yes'}
    <p>
        <button id="add-box">Add BBox</button>
        <br/>
        <span id="blather"></span>
    </p>
    <p class="wide" id="notes-image">
        <img border="1" src="{$scan.base_url}/walking-paper-{$scan.id}.jpg" />
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
        </tbody>
    </table>
{else}
    <p class="wide">
        <a href="{$scan.base_url}/{$scan.uploaded_file}">
            <img border="1" src="{$scan.base_url}/large.jpg" /></a>
    </p>
{/if}
