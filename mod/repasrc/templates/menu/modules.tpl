{extends tplextends('repasrc/menu_edit')}

{block name='menu_title'}
	<h1>{t d='repasrc' m='Sélectionner les modules'}</h1>
	<p class="lead">{t d='repasrc' m='Saisonnalité, transport, prix ... Ils vous permettront d\'analyser votre menu selon différents facteurs.'}</p>
{/block}

{block name='menu_content'}
<div class="help" code="composerunmenu"></div>	
<div id="modules_container">
		<ul class="nav nav-tabs nav-stacked">
			<li id="seasonality" class="row select{if (isset($modulesList) && isset($modulesList.seasonality) && $modulesList.seasonality == 1)} checked{/if}">
				<div class="title"><h3>{t d='repasrc' m='Module saisonnalité'}</h3></div>
				<div class="help" code="composerunmenumodulesaisonnalite"></div>	
			</li>
			<li id="production"  class="row select{if (isset($modulesList) && isset($modulesList.production) && $modulesList.production == 1)} checked{/if}">
				<div class="title"><h3>{t d='repasrc' m='Module Production'}</h3></div>
				<div class="help" code="composerunmenumoduleproduction"></div>	
			</li>
			<li id="transport" class="row select{if (isset($modulesList) && isset($modulesList.transport) && $modulesList.transport == 1)} checked{/if}">
				<div class="title"><h3>{t d='repasrc' m='Module transport'}</h3></div>
				<div class="help" code="composerunmenumoduletransport"></div>	
			</li>
			<li id="price" class="row select{if (isset($modulesList) && isset($modulesList.price) && $modulesList.price == 1)} checked{/if}">
				<div class="title"><h3>{t d='repasrc' m='Module prix'}</h3></div>
				<div class="help" code="composerunmenumoduletransport"></div>	
			</li>
		</ul>
			<form id="modules_form" name="modules_form"  action="/menu/edition/informations" method="post">
				<div class="form-actions">
					<input type="submit" class="btn btn-primary special" id="submit" value="Valider le choix de modules" />
					<input type="button" class="btn" id="cancel" value="Annuler la création du menu" />
				</div>
				<input type="hidden" id="modules" name="modules" value="" />
				{if isset($menu) && isset($menu.id)}
					<input type="hidden" name="menuId" value="{$menu.id}" />
				{/if}
			</form>
	</div>
{/block}
