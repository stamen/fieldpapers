<div id="pagination">
{if $pagination.prev_link}
    <a href="{$pagination.prev_link}" class='pagination-link prev'>Previous</a>
{else}
    Previous
{/if}
{if $pagination.next_link}
    <a href="{$pagination.next_link}" class='pagination-link next'>Next</a>
{else}
    Next
{/if}
</div>
