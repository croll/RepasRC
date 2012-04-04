{extends tplextends('repasrc/recipe_edit')}

{block name='webpage_head' append}
	{js file="/mod/repasrc/js/recipe.js"}
	{js file="/mod/repasrc/js/map.js"}
	<script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false"></script>
{/block}

{block name='recipe_title'}
	<h1>{t d='repasrc' m='Module transport'}</h1>
{/block}

{block name='recipe_content'}
	<div class="alert alert-info">
		<a class="close" data-dismiss="alert">×</a>
		Visualisez les informations sur la carte.
	</div> 

	<div id="map_canvas" style="display: block;width: 870px;height:450px">
	</div>
{/block}
