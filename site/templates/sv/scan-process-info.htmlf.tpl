{if $step.number == $constants.STEP_FATAL_ERROR || $step.number == $constants.STEP_FATAL_QRCODE_ERROR}
    <p>
        {$step.number|step_description|escape}, ger upp.
    </p>
    <p>
        Du kan försöka med att ladda upp din inskanning igen, se till att den
        är i en tillräckligt hög upplösning (200+ dpi för en helsida är inte 
        ovanligt) och med rätsidan uppåt. En fullt läsbar 
        <a href="http://en.wikipedia.org/wiki/QR_Code">QR-kod</a> är ett krav.
        Om det fortfarande inte fungerar, så
        <a href="mailto:info@walking-papers.org?subject=Problem%20with%20scan%20#{$scan.id|escape}">hör av dig</a>.
    </p>
    
    {if $step.number == $constants.STEP_FATAL_QRCODE_ERROR}
        <p>
            Vi försökte läsa av QR-koden här:
        </p>
        <p>
            <img width="65%" border="1" src="{$scan.base_url}/qrcode.jpg" />
        </p>
        
        {* TODO: duplicate this file to languages other than English *}
        {include file="en/scan-process-qrcode.htmlf.tpl"}
    {/if}
    
{else}
    <p>
        Bearbetar din skannade bild.
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
            {$step.number|step_description|escape}, var vänligen vänta.
            Vi kommer att försöka bearbeta din inskanning igen inom kort.
        </p>
        
        {if $step.number == $constants.STEP_BAD_QRCODE}
            <p>
                Vi försökte läsa av QR-koden här:
            </p>
            <p>
                <img width="65%" border="1" src="{$scan.base_url}/qrcode.jpg" />
            </p>
        {/if}
        
    {else}
        <p>
            Detta kan ta en liten stund, normalt några få minuter.
            Du behöver inte behålla denna sida öppen - du kan
            <a href="{$base_dir}/scan.php?id={$scan.id|escape}">lägga till ett 
            bokmärke</a> och komma tillbaka vid ett senare tillfälle.
        </p>
    {/if}
{/if}
