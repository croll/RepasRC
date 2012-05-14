{extends tplextends('repasrc/recipe_edit')}

{block name='webpage_head' append}
	{js file="/mod/repasrc/js/recipe.js"}
{/block}

{block name='recipe_title'}
	<h1>{t d='repasrc' m='Composer une recette'}</h1>
	<p class="lead">{t d='repasrc' m='Sélectionnez les aliments composants votre recette et définissez leur grammage.'}</p>
{/block}

{block name='recipe_content'}
	{include file="repasrc/recipe/analyze/seasonality_content"}
{/block}
