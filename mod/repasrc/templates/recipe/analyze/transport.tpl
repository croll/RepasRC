{extends tplextends('repasrc/recipe_edit')}

{block name='webpage_head' append}
	{js file="/mod/repasrc/js/recipe.js"}
	{js file="/mod/repasrc/js/transport.js"}
	<script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false"></script>
{/block}

{block name='recipe_title'}
	<h1>{t d='repasrc' m='Transport'}</h1>
{/block}

{block name='recipe_content'}
	{include file="repasrc/recipe/analyze/transport_content"}
{/block}
