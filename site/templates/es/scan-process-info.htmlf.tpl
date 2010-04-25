{if $step.number == $constants.STEP_FATAL_ERROR || $step.number == $constants.STEP_FATAL_QRCODE_ERROR}
    <p>
        {$step.number|step_description|escape}, giving up.
    </p>
    <p>
        Puedes intentar subir tu scan de nuevo, asegurándote de que está a una
        resolución razonablemente algta (más de 200 ppp para una hoja entera de
        papel es lo normal) y con el lado derecho hacia arriba. Es imprescindible
        que el <a href="http://en.wikipedia.org/wiki/QR_Code">QR Code</a> sea
        legible. Si con todo esto no funciona,
        <a href="mailto:info@walking-papers.org?subject=Problem%20with%20scan%20#{$scan.id|escape}">haznoslo saber</a>.
    </p>
    
    {if $step.number == $constants.STEP_FATAL_QRCODE_ERROR}
        <p>
            Esta es la parte de tu scan en la que hemos tratado de encontrar un código:
        </p>
        <p>
            <img width="65%" border="1" src="{$scan.base_url}/qrcode.jpg" />
        </p>
    {/if}
    
{else}
    <p>
        Procesando tu imagen escaneada.
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
            {$step.number|step_description|escape}, por favor, aguarda.
            Intentaremos procesar tu scan en breve.
        </p>
        
        {if $step.number == $constants.STEP_BAD_QRCODE}
            <p>
                Esta es la parte de tu scan en la que hemos tratado de encontrar un código:
            </p>
            <p>
                <img width="65%" border="1" src="{$scan.base_url}/qrcode.jpg" />
            </p>
        {/if}
        
    {else}
        <p>
            Esto puede llevar un rato, generalmente unos pocos minutos.
            No hace falta que mantengas abierta esta ventana del navegador, puedes 
            <a href="{$base_dir}/scan.php?id={$scan.id|escape}">añadir esta página a tus favoritos</a> para volver más tarde.
        </p>
    {/if}
{/if}
