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
	<div class="smallContainer">
        <p>Processing your scanned image... ({$scan.progress*100|string_format:"%d"}% complete)</p>
        <div class="progressBarCase">
            <div class="progressBar" style="width: {$scan.progress*100}%;"></div>
        </div>
    </div>
{/if}
