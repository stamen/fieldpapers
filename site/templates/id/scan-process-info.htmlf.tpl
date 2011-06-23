{if $scan.last_step == $constants.STEP_FATAL_ERROR || $scan.last_step == $constants.STEP_FATAL_QRCODE_ERROR}
    <p>
        {$scan.last_step|step_description|escape}, giving up.
    </p>
    <p>
        Anda mungkin dapat mencoba kembali untung mengunggah scan WalkingPapers anda, pastikan anda mengunggahnya dalam resolusi tinggi yang layak (200+ dpi untuk satu halaman penuh adalah normal) dan sisi yang benar.  <a href="http://en.wikipedia.org/wiki/QR_Code">QR code</a> yang terbaca sangat penting.
        Jika penjelasan iini tidak dapat membantu anda,
        <a href="mailto:info@walking-papers.org?subject=Problem%20with%20scan%20#{$scan.id|escape}">beritahu kami.</a>.
    </p>
    
    {if $scan.last_step == $constants.STEP_FATAL_QRCODE_ERROR}
        <p>
           Ini adalah bagian dari hasil scan anda dimana kami mencoba untuk mencari sebuah kode:
        </p>
        <p>
            <img width="65%" border="1" src="{$scan.base_url}/qrcode.jpg" />
        </p>
        
        {* TODO: duplicate this file to languages other than English *}
        {include file="en/scan-process-qrcode.htmlf.tpl"}
    {/if}
    
{else}
    <p>
        Sedang memproses gambar yang telah anda scan.
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
            {$scan.last_step|step_description|escape}, mohon tunggu.
            Kami akan mencoba untuk melakukan proses scan ulang dalam waktu yang singkat.
        </p>
        
        {if $scan.last_step == $constants.STEP_BAD_QRCODE}
            <p>
               Ini adalah bagian dari hasil scan anda dimana kami mencoba untuk mencari sebuah kode:
            </p>
            <p>
                <img width="65%" border="1" src="{$scan.base_url}/qrcode.jpg" />
            </p>
        {/if}
        
    {else}
        <p>
            Proses ini akan memakan sedikit waktu, pada umumnya dalam beberapa menit. Anda tidak harus selalu membuka jendela browser ini, anda dapat  You don’t need to keep this browser window open—you can
            <a href="{$base_dir}/scan.php?id={$scan.id|escape}">tandai (bookmark) halaman ini</a>
            dan kembali lagi nanti.
        </p>
    {/if}
{/if}
