<form class="language" action="{$base_dir}/language.php" method="post">
    <p>
        Language:
        <input type="hidden" name="referer" value="{* http://{$domain|escape} *}{$request.uri|escape}"/>
        <button type="submit" class="{if $language == "en"}selected{/if}" name="language" value="en">English</button>
        <button type="submit" class="{if $language == "de"}selected{/if}" name="language" value="de">Deutsch</button>
        <button type="submit" class="{if $language == "nl"}selected{/if}" name="language" value="nl">Nederlands</button>
        <button type="submit" class="{if $language == "es"}selected{/if}" name="language" value="es">Español</button>
        <button type="submit" class="{if $language == "fr"}selected{/if}" name="language" value="fr">Français</button>
    <button type="submit" class="{if $language == "ja"}selected{/if}" name="language" value="ja">日本語</button>
    <button type="submit" class="{if $language == "it"}selected{/if}" name="language" value="it">Italiano</button>
        
        {if $language == "de"}
            (<a href="{$base_dir}/language.php"><abbr title="Lokalisierung">l10n</abbr></a>)
        {elseif $language == "nl"}
            {* nl: WRITE ME *}
            (<a href="{$base_dir}/language.php"><abbr title="Localization">l10n</abbr></a>)
        {elseif $language == "es"}
            (<a href="{$base_dir}/language.php"><abbr title="Localización">l10n</abbr></a>)
        {elseif $language == "fr"}
            (<a href="{$base_dir}/language.php"><abbr title="Traduction">l10n</abbr></a>)
        {elseif $language == "ja"}
            (<a href="{$base_dir}/language.php"><abbr title="地域化">l10n</abbr></a>)
        {elseif $language == "it"}
            (<a href="{$base_dir}/language.php"><abbr title="Localization">l10n</abbr></a>)
        {else}
            (<a href="{$base_dir}/language.php"><abbr title="Localization">l10n</abbr></a>)
        {/if}
    </p>
</form>
