{if $scan.last_step == $constants.STEP_FATAL_ERROR || $scan.last_step == $constants.STEP_FATAL_QRCODE_ERROR}
    <p>
        {$scan.last_step|step_description|escape}, giving up.
    </p>
    <p>
        あなたは、スキャナーしなおしてアップロードしようとすると思います。
        それが十分に高解像度であるか(すべてのシートに対して200DPI以上ですか）
        また、右が上になっているか、意識してください。最も重要な点は、
        <a href="http://en.wikipedia.org/wiki/QR_Code">QR code</a>が読めることです。
        もし、このアドバイスを守ってもうまくいかない場合は、
        <a href="mailto:info@walking-papers.org?subject=Problem%20with%20scan%20#{$scan.id|escape}">私たちにお知らせください</a>.
    </p>
    
    {if $scan.last_step == $constants.STEP_FATAL_QRCODE_ERROR}
        <p>
            Here’s the part of your scan where we tried to find a code:
        </p>
        <p>
            <img width="65%" border="1" src="{$scan.base_url}/qrcode.jpg" />
        </p>
        
        {* TODO: duplicate this file to languages other than English *}
        {include file="en/scan-process-qrcode.htmlf.tpl"}
    {/if}
    
{else}
    <p>
        Processing your scanned image.
    </p>

    <ol class="steps">
        <li class="{if $scan.last_step == 0}on{/if}">{0|step_description|escape}</li>
        <li class="{if $scan.last_step == 1}on{/if}">{1|step_description|escape}</li>
        <li class="{if $scan.last_step == 2}on{/if}">{2|step_description|escape}</li>
        <li class="{if $scan.last_step == 3}on{/if}">{3|step_description|escape}</li>
        <li class="{if $scan.last_step == 4}on{/if}">{4|step_description|escape}</li>
        <li class="{if $scan.last_step == 5}on{/if}">{5|step_description|escape}</li>
        <li class="{if $scan.last_step == 6}on{/if}">{6|step_description|escape}</li>
    </ol>

    {if $scan.last_step >= 7}
        <p>
            {$scan.last_step|step_description|escape}, please stand by.
            We will try to process your scan again shortly.
        </p>
        
        {if $scan.last_step == $constants.STEP_BAD_QRCODE}
            <p>
                Here’s the part of your scan where we tried to find a code:
            </p>
            <p>
                <img width="65%" border="1" src="{$scan.base_url}/qrcode.jpg" />
            </p>
        {/if}
        
    {else}
        <p>
            This may take a little while, generally a few minutes.
            You don’t need to keep this browser window open—you can
            <a href="{$base_dir}/scan.php?id={$scan.id|escape}">bookmark this page</a>
            and come back later.
        </p>
    {/if}
{/if}
