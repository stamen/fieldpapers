<div id="pagination">
{if $pagination.next_link}
    <a href="{$pagination.next_link}" class='pagination-link older'>Older</a>
{else}
    <span class='pagination-link older disabled'>Older</span>
{/if}

{if $pagination.prev_link}
    <a href="{$pagination.prev_link}" class='pagination-link newer'>Newer</a>
{else}
    <span class='pagination-link newer disabled'>Newer</span>
{/if}
</div>
