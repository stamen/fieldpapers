{if $step.number == $constants.STEP_FATAL_ERROR || $step.number == $constants.STEP_FATAL_QRCODE_ERROR}
    <p>
        {$step.number|step_description|escape}, giving up.
    </p>
    <p>
        Puoi provare ad inviare la tua scansione un'altra volta, assicurandoti
        che sia ad una risoluzione ragionevolmente elevata (200+ dpi per un
        normale foglio di carta é normale) e che il lato destro sia in alto. Un
        <a href="http://en.wikipedia.org/wiki/QR_Code">QR code</a> leggibile é
        fondamentale. Se dopo tutto questo ancora qualcosa non va,
        <a href="mailto:info@walking-papers.org?subject=Problem%20with%20scan%20#{$scan.id|escape}">faccelo sapere</a>.
    </p>
    
    {if $step.number == $constants.STEP_FATAL_QRCODE_ERROR}
        <p>
            Questa é la parte della tua scansione dove proviamo a trovare un codice :
        </p>
        <p>
            <img width="65%" border="1" src="{$scan.base_url}/qrcode.jpg" />
        </p>
    {/if}
    
{else}
    <p>
        {if $language == "de"}
            Das gescannte Bild wird vearbeitet.
        {elseif $language == "nl"}
            De gescande afbeelding wordt verwerkt.
        {elseif $language == "es"}
            Procesando tu imagen escaneada.
        {elseif $language == "fr"}
            Traitement de votre image scannée.
        {elseif $language == "fr"}
            Elaborazione della tua immagine scannerizzata.
        {else}
            Processing your scanned image.
        {/if}
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
            {$step.number|step_description|escape}, per favore attendi un attimo.
            A breve stiamo per provare ad elaborare un'altra volta la tua scansione.
        </p>
        
        {if $step.number == $constants.STEP_BAD_QRCODE}
            <p>
                Questa é la parte della tua scansione dove abbiamo provato a cercare un codice:
            </p>
            <p>
                <img width="65%" border="1" src="{$scan.base_url}/qrcode.jpg" />
            </p>
        {/if}
        
    {else}
        <p>
            Questo potrebbe impiegare un po' di tempo, di solito un paio di minuti.
            Non devi necessariamente tenere questa finestra del tuo browser aperta,
            puoi <a href="{$base_dir}/scan.php?id={$scan.id|escape}">salvare come
            bookmark questa pagina</a> e tornare piú tardi.
        </p>
    {/if}
{/if}
