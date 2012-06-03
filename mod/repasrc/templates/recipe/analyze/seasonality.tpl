{extends tplextends('repasrc/recipe_edit')}

{block name='webpage_head' append}
	{js file="/mod/repasrc/js/recipe.js"}
{/block}

{block name='recipe_title'}
	<h1>{t d='repasrc' m='Saisonnalité'}</h1>
{/block}

{block name='recipe_content'}
	{include file="repasrc/recipe/analyze/seasonality_content"}
{/block}
