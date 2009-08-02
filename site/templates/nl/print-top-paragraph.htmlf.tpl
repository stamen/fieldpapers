<p>
    Afdruk samenstellen voor het gebied rond coördinaten: 
    {if $print.place_woeid}
        <a id="print-location" href="http://www.openstreetmap.org/?lat={$print.latitude|escape}&amp;lon={$print.longitude|escape}&amp;zoom=15&amp;layers=B000FTF">
            {$print.latitude|nice_degree:"lat"|escape},{$print.longitude|nice_degree:"lon"|escape}</a>
        <br />
        {$print.place_name|escape}
 
    {else}
        <a id="print-location" href="http://www.openstreetmap.org/?lat={$print.latitude|escape}&amp;lon={$print.longitude|escape}&amp;zoom=15&amp;layers=B000FTF">
            {$print.latitude|nice_degree:"lat"|escape},{$print.longitude|nice_degree:"lon"|escape}</a>
    {/if}
    <br />
    Aangevraagd: {$print.age|nice_relativetime|escape}.
    <span class="date-created" style="display: none;">{$print.created|escape}</span>
</p>
 
<p>
    <a href="{$print.pdf_url|escape}">
        <img src="{$base_dir}/tiny-doc.png" border="0" align="bottom"/>
        Gebied downloaden als PDF om zelf te printen</a>
</p>
 
<p>
    <a href="{$print.pdf_url|escape}">Download het gebied</a> direct als PDF zodat je naar buiten kunt en je aantekeningen kunt maken. Voeg details toe zoals bedrijven, parken, scholen, gebouwen, voet- en wandelpaden en andere zaken die jij interessant vindt om in kaart te brengen. Wanneer je klaar bent kun je een <a href="{$base_dir}/upload.php">scan uploaden</a> van jou afdruk met aantekeningen zodat deze direct in OpenStreetMap kunnen worden verwerkt.
</p>