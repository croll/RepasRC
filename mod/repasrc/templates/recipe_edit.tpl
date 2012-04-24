{extends tplextends('repasrc/layout')}

{block name='repasrc_content'}
	<div class="page-header">
		{block name='recipe_title'}
		{/block}
	</div>

	<div class="recipe_container">

		<div class="span2">
			{block name='recipe_sidebar'}
			<div class="well" style="padding: 8px 0;">
				<ul class="nav nav-list">
					<li class="nav-header">{t d='repasrc' m='Recette'}</li>
					<li{if ($section == 'modules')} class="active"{/if}><a href="/recette/edition/modules/{$recipeId}"><i class="icon-th"></i>{t d='repasrc' m='Choix des modules'}</a></li>
					<li{if ($section == 'informations')} class="active"{/if}><a href="/recette/edition/informations/{$recipeId}"><i class="icon-info-sign"></i>{t d='repasrc' m='Informations'}</a>
					{if isset($recipeId)}
						<li{if ($section == 'aliments')} class="active"{/if}><a href="/recette/edition/aliments/{$recipeId}"><i class="icon-leaf"></i>{t d='repasrc' m='Aliments'}</a></li>
						<li class="nav-header">{t d='repasrc' m='Analyse'}</li>
						<li{if ($section == 'resultats')} class="active"{/if}><a href="/recette/analyse/resultats/{$recipeId}"><i class="icon-align-left"></i>{t d='repasrc' m='Résultats'}</a></li>
						{if (isset($smarty.session.recipe.modules) && $smarty.session.recipe.modules.seasonality == 1)}<li{if ($section == 'saisonnalite')} class="active"{/if}><a href="/recette/analyse/saisonnalite/{$recipeId}"><i class="icon-leaf"></i>{t d='repasrc' m='Saisonnalité'}</a></li>{/if}
						{if (isset($smarty.session.recipe.modules) && $smarty.session.recipe.modules.transport == 1)}<li{if ($section == 'transport')} class="active"{/if}><a href="/recette/analyse/transport/{$recipeId}"><i class="icon-road"></i>{t d='repasrc' m='Transport'}</a></li>{/if}
						{if (isset($smarty.session.recipe.modules) && $smarty.session.recipe.modules.prodcons == 1)}<li{if ($section == 'mode')} class="active"{/if}><a href="/recette/analyse/mode/{$recipeId}"><i class="icon-map-marker"></i>{t d='repasrc' m='Production / conservation'}</a></li>{/if}
						{if (isset($smarty.session.recipe.modules) && $smarty.session.recipe.modules.price == 1)}<li{if ($section == 'prix')} class="active"{/if}><a href="/recette/analyse/prix/{$recipeId}"><i class="icon-barcode"></i>{t d='repasrc' m='Prix'}</a></li>{/if}
						<li{if ($section == 'comparer')} class="active"{/if}><a href="/recette/analyse/comparer/{$recipeId}"><i class="icon-retweet"></i>{t d='repasrc' m='Comparer'}</a></li>
					{/if}
				</ul>
			</div>
			{/block}
		</div>

		<div class="span9">
			<div class="recipe_content">
				{block name='recipe_content'}
				{/block}
			</div>
		</div>

		<div class="span2">
			{block name='recipe_sidebar_right'}
			{/block}
		</div>

		<div class="clearfix"></div>
	</div>

{/block}
