{if $scan.failed}
    <p>
        Giving up.
    </p>
    <p>
        You might try uploading your scan again, making sure that
        it’s at a reasonably high resolution (200+ dpi for a full
        sheet of paper is normal) and right-side up. A legible 
        <a href="http://en.wikipedia.org/wiki/QR_Code">QR code</a> is critical.
        If this doesn’t help,
        <a href="mailto:info@walking-papers.org?subject=Problem%20with%20scan%20#{$scan.id|escape}">let us know</a>.
    </p>
    
{else}
    <p>
        Processing your scanned image.
    </p>

    <p>
        This may take a little while, generally a few minutes.
        You don’t need to keep this browser window open—you can
        <a href="{$base_dir}/scan.php?id={$scan.id|escape}">bookmark this page</a>
        and come back later.
    </p>
{/if}
