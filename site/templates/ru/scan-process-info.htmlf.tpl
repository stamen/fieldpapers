{if $step.number == $constants.STEP_FATAL_ERROR || $step.number == $constants.STEP_FATAL_QRCODE_ERROR}
    <p>
        {$step.number|step_description|escape}, giving up.
    </p>
    <p>
        Попробуйте загрузить отсканированную карту еще раз, убедившись
        что она достаточного разрешения (200+ dpi должно хватить) 
        и правильно ориентирована. Очень важен читаемый
        <a href="http://en.wikipedia.org/wiki/QR_Code">QR-код</a>.
        Если это не помогает,
        <a href="mailto:info@walking-papers.org?subject=Problem%20with%20scan%20#{$scan.id|escape}">сообщите нам</a>.
    </p>
    
    {if $step.number == $constants.STEP_FATAL_QRCODE_ERROR}
        <p>
            Вот часть вашей отсканированной карты, где мы пытались найти код:
        </p>
        <p>
            <img width="65%" border="1" src="{$scan.base_url}/qrcode.jpg" />
        </p>
    {/if}
    
{else}
    <p>
        Обработка отсканиованного изображения.
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
            {$step.number|step_description|escape}, please stand by.
            Мы попытаемся обработать вашу отсканированную карту еще раз через некоторое время.
        </p>
        
        {if $step.number == $constants.STEP_BAD_QRCODE}
            <p>
                Вот часть вашей отсканированной карты, где мы пытались найти код:
            </p>
            <p>
                <img width="65%" border="1" src="{$scan.base_url}/qrcode.jpg" />
            </p>
        {/if}
        
    {else}
        <p>
            Это может занять некоторое время, обычно несколько минут.
            Вам не нужно держать открытой эту страницу в браузере, ее можно
            <a href="{$base_dir}/scan.php?id={$scan.id|escape}">поместить в закладки</a>
             и посетить позже.
        </p>
    {/if}
{/if}
