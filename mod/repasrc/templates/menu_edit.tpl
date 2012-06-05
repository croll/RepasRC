{extends tplextends('repasrc/layout')}

{block name='webpage_head' append}
	{js file="/mod/repasrc/js/recipe.js"}
	<script language="javascript">
		var recipeId = {if isset($recipe.id)}{$recipe.id}{else}null{/if};
		var modulesList = {if isset($modulesList)}{$modulesList|json_encode}{else}null{/if};
	</script>
	<style type="text/css">
		.modal-box {
			width: 750px!important;
			max-width: 800px;
		}
		.modal-body, .modal-content {
			min-height: 490px;
		}
	</style>
{/block}

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
					{if empty($recipe.id) || (\mod\user\Main::userBelongsToGroup('admin') || \mod\repasrc\RC::isRecipeOwner({$recipe.id}))}
						<li class="nav-header">{t d='repasrc' m='Recette'}</li>
						<li{if ($section == 'modules')} class="active"{/if}><a href="/recette/edition/modules/{$recipe.id}"><i class="icon-th"></i>{t d='repasrc' m='Choix des modules'}</a></li>
						<li{if ($section == 'informations')} class="active"{/if}><a href="/recette/edition/informations/{$recipe.id}"><i class="icon-info-sign"></i>{t d='repasrc' m='Informations'}</a>
					{/if}
					{if isset($recipe.id)}
						{if \mod\user\Main::userBelongsToGroup('admin') || \mod\repasrc\RC::isRecipeOwner({$recipe.id})}
							<li{if ($section == 'aliments')} class="active"{/if}><a href="/recette/edition/aliments/{$recipe.id}"><i class="icon-leaf"></i>{t d='repasrc' m='Aliments'}</a></li>
							<li{if ($section == 'commentaires')} class="active"{/if}><a href="/recette/edition/commentaires/{$recipe.id}"><i class="icon-pencil"></i>{t d='repasrc' m='Commentaires'}</a></li>
						{/if}
						<li class="nav-header">{t d='repasrc' m='Analyse'}</li>
						{if \mod\repasrc\Recipe::hasFoodstuff($recipe.id)}
							<li{if ($section == 'resume')} class="active"{/if}><a href="/recette/analyse/resume/{$recipe.id}"><i class="icon-align-left"></i>{t d='repasrc' m='Résumé'}</a></li>
							{if (isset($modulesList) && $modulesList.seasonality == 1)}<li{if ($section == 'saisonnalite')} class="active"{/if}><a href="/recette/analyse/saisonnalite/{$recipe.id}"><i class="icon-leaf"></i>{t d='repasrc' m='Saisonnalité'}</a></li>{/if}
							{if (isset($modulesList) && $modulesList.transport == 1)}<li{if ($section == 'transport')} class="active"{/if}><a href="/recette/analyse/transport/{$recipe.id}"><i class="icon-road"></i>{t d='repasrc' m='Transport'}</a></li>{/if}
							{if (isset($modulesList) && $modulesList.prodcons == 1)}<li{if ($section == 'mode')} class="active"{/if}><a href="/recette/analyse/mode/{$recipe.id}"><i class="icon-map-marker"></i>{t d='repasrc' m='Production / conservation'}</a></li>{/if}
							{if (isset($modulesList) && $modulesList.price == 1)}<li{if ($section == 'prix')} class="active"{/if}><a href="/recette/analyse/prix/{$recipe.id}"><i class="icon-barcode"></i>{t d='repasrc' m='Prix'}</a></li>{/if}
							<li{if ($section == 'comparer')} class="active"{/if}><a href="/recette/liste/add/{$recipe.id}"><i class="icon-retweet"></i>{t d='repasrc' m='Comparer'}</a></li>
						{else}
							<div style="font-size: 11px">La recette ne comporte aucun aliment.</div>
						{/if}
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
