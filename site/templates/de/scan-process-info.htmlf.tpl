{if $step.number == $constants.STEP_FATAL_ERROR || $step.number == $constants.STEP_FATAL_QRCODE_ERROR}
    <p>
        {$step.number|step_description|escape}, giving up.
    </p>
    <p>
        Versuche deinen Scan nocheinmal hochzuladen, achte auf eine
        angemessen hohe Auflösung (200+ dpi sind für ein ganzes Papier
        normal) und auf die richtige Seite. Ein leserlicher
        <a href="http://de.wikipedia.org/wiki/QR_Code">QR code</a> ist wichtig.
        Falls das nicht hilft, kannst du uns 
        <a href="mailto:info@walking-papers.org?subject=Problem%20with%20scan%20#{$scan.id|escape}">kontaktieren</a>.
    </p>
    
    {if $step.number == $constants.STEP_FATAL_QRCODE_ERROR}
        <p>
            Dies ist der Teil deines Scans, in dem wir versuchten einen Code zu finden:
        </p>
        <p>
            <img width="65%" border="1" src="{$scan.base_url}/qrcode.jpg" />
        </p>
    {/if}
    
{else}
    <p>
        Das gescannte Bild wird vearbeitet.
    </p>

    <ol class="steps">
        <li class="{if $step.number == 0}on{/if}">{0|step_description|escape}</li>
        <li class="{if $step.number == 1}on{/if}">{1|step_description|escape}</li>
        <li class="{if $step.number == 2}on{/if}">{2|step_description|escape}</li>
        <li class="{if $step.number == 3}on{/if}">{3|step_description|escape}</li>
        <li class="{if $step.number == 4}on{/if}">{4|step_description|escape}</li>
        <li class="{if $step.number == 5}on{/if}">{5|step_description|escape}</li>
        <li class="{if $step.number == 6}on{/if}">{6|step_description|escape}</li>
    </ol>

    {if $step.number >= 7}
        <p>
            {$step.number|step_description|escape}, bitte warten.
            Wir versuchen deinen Scan bald zu verarbeiten.
        </p>
        
        {if $step.number == $constants.STEP_BAD_QRCODE}
            <p>
                Dies ist der Teil deines Scans, in dem wir versuchten einen Code zu finden:
            </p>
            <p>
                <img width="65%" border="1" src="{$scan.base_url}/qrcode.jpg" />
            </p>
        {/if}
        
    {else}
        <p>
            Dies kann einige Minuten dauern.
            Du musst das Browserfenster nicht geöffnet halten.
            Setze ein Lesezeichen für diese <a href="{$base_dir}/scan.php?id={$scan.id|escape}">Seite</a>
            und schaue später nocheinmal vorbei.
        </p>
    {/if}
{/if}
