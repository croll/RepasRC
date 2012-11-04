{extends tplextends('repasrc/layout')}

{block name='webpage_head' append}
	{js file="/mod/repasrc/js/menu.js"}
	<script language="javascript">
		var menuId = {if isset($menu.id)}{$menu.id}{else}null{/if};
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
		{block name='menu_title'}
		{/block}
	</div>

	<div class="menu_container">

		<div class="span3">
			{block name='menu_sidebar'}
			<div class="well" style="padding: 8px 0;">
				<ul class="nav nav-list">
					{if empty($menu.id) || (\mod\user\Main::userBelongsToGroup('admin') || \mod\repasrc\RC::isMenuOwner({$menu.id}))}
						<li class="nav-header">{t d='repasrc' m='Menu'}</li>
						<li{if ($section == 'modules')} class="active"{/if}><a href="/menu/edition/modules/{$menu.id}"><i class="icon-th"></i>{t d='repasrc' m='Choix des modules'}</a></li>
						<li{if ($section == 'informations')} class="active"{/if}><a href="/menu/edition/informations/{$menu.id}"><i class="icon-info-sign"></i>{t d='repasrc' m='Informations'}</a>
					{/if}
					{if isset($menu.id)}
						{if \mod\user\Main::userBelongsToGroup('admin') || \mod\repasrc\RC::isMenuOwner({$menu.id})}
							<li{if ($section == 'recettes')} class="active"{/if}><a href="/menu/edition/recettes/{$menu.id}"><i class="icon-leaf"></i>{t d='repasrc' m='Recettes'}</a></li>
							<li{if ($section == 'commentaires')} class="active"{/if}><a href="/menu/edition/commentaires/{$menu.id}"><i class="icon-pencil"></i>{t d='repasrc' m='Commentaires'}</a></li>
						{/if}
						<li class="nav-header">{t d='repasrc' m='Analyse'}</li>
						{if \mod\repasrc\Menu::hasRecipe($menu.id)}
							<li{if ($section == 'resume')} class="active"{/if}><a href="/menu/analyse/resume/{$menu.id}"><i class="icon-align-left"></i>{t d='repasrc' m='Empreinte Foncière'}</a></li>
							{if (isset($modulesList) && $modulesList.seasonality == 1)}<li{if ($section == 'saisonnalite')} class="active"{/if}><a href="/menu/analyse/saisonnalite/{$menu.id}"><i class="icon-leaf"></i>{t d='repasrc' m='Saisonnalité'}</a></li>{/if}
							{if (isset($modulesList) && $modulesList.transport == 1)}<li{if ($section == 'transport')} class="active"{/if}><a href="/menu/analyse/transport/{$menu.id}"><i class="icon-road"></i>{t d='repasrc' m='Transport'}</a></li>{/if}
							{if (isset($modulesList) && $modulesList.production == 1)}<li{if ($section == 'mode')} class="active"{/if}><a href="/menu/analyse/mode/{$menu.id}"><i class="icon-map-marker"></i>{t d='repasrc' m='Production / conservation'}</a></li>{/if}
							{if (isset($modulesList) && $modulesList.price == 1)}<li{if ($section == 'prix')} class="active"{/if}><a href="/menu/analyse/prix/{$menu.id}"><i class="icon-barcode"></i>{t d='repasrc' m='Prix'}</a></li>{/if}
							<li{if ($section == 'comparer')} class="active"{/if}><a href="/menu/liste/add/{$menu.id}"><i class="icon-retweet"></i>{t d='repasrc' m='Comparer'}</a></li>
						{else}
							<div style="font-size: 11px">Le menu ne comporte aucune recette.</div>
						{/if}
					{/if}
				</ul>
			</div>
			{/block}
		</div>

		<div class="span11">
			<div class="menu_content">
				{block name='menu_content'}
				{/block}
			</div>
		</div>

		<div class="span2">
			{block name='menu_sidebar_right'}
			{/block}
		</div>

		<div class="clearfix"></div>
	</div>

{/block}
