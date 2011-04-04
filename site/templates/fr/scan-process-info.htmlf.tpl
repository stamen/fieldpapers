{if $step.number == $constants.STEP_FATAL_ERROR || $step.number == $constants.STEP_FATAL_QRCODE_ERROR}
    <p>
        {$step.number|step_description|escape}, giving up.
    </p>
    <p>
        Vous devriez essayer d'envoyer à nouveau votre scan, en vous assurant qu'il est à une résolution assez grande 
        (plus de 200 dpi pour une feuille entière) et le côté droit vers le haut. 
        Un <a href="http://en.wikipedia.org/wiki/QR_Code">QR code</a> bien lisible est nécessaire.
        Si ça ne fonctionne toujours pas, <a href="mailto:info@walking-papers.org?subject=Problem%20with%20scan%20#{$scan.id|escape}">prévenez-nous</a>.
    </p>
    
    {if $step.number == $constants.STEP_FATAL_QRCODE_ERROR}
        <p>
            Voici la partie de votre scan où nous avons tenté de trouver un code :
        </p>
        <p>
            <img width="65%" border="1" src="{$scan.base_url}/qrcode.jpg" />
        </p>
        
        {* TODO: duplicate this file to languages other than English *}
        {include file="en/scan-process-qrcode.htmlf.tpl"}
    {/if}
    
{else}
    <p>
        Traitement de votre image scannée.
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
            {$step.number|step_description|escape}, merci de patienter.
            Nous allons essayer de traiter votre scan à nouveau dans peu de temps.
        </p>
        
        {if $step.number == $constants.STEP_BAD_QRCODE}
            <p>
                Voici la partie de votre scan où nous avons tenté de trouver un code :
            </p>
            <p>
                <img width="65%" border="1" src="{$scan.base_url}/qrcode.jpg" />
            </p>
        {/if}
        
    {else}
        <p>
            Ça peut prendre un peu de temps, en général quelques minutes.
            Vous n'êtes pas obligé de laisser la fenêtre de votre navigateur ouverte.
            Vous pouvez ajouter <a href="{$base_dir}/scan.php?id={$scan.id|escape}">cette page</a>
            à vos favoris, et revenir plus tard.
        </p>
    {/if}
{/if}
