{extends tplextends('repasrc/menu_edit')}

{block name='menu_title'}
	<h1>{t d='repasrc' m='Composer un menu'}</h1>
	<p class="lead">{t d='repasrc' m='Indiquez les informations de qualification de votre menu.'}</p>
{/block}

{block name='menu_content'}
<div class="help" code="composerunmenuformulaire"></div>
	<div id="informations_container">
		{form mod="repasrc" file="templates/menu/informations.json" defaultValues=\mod\repasrc\Menu::getInfos($menu.id)}
			<fieldset>
				<div class="control-group">
					<label class="control-label">{t d='repasrc' m="Nom du menu"}</label>
					<div class="controls">
						{$informations.label}
						<div class="help" code="creernomdumenu"></div>
					</div>
				</div>
				<div class="control-group">
					<label class="control-label">{t d='repasrc' m="Nombre de convives"}</label>
					<div class="controls">
						{$informations.eaters}
						<div class="help" code="creernombreconvives"></div>
					</div>
				</div>
				<div class="control-group">
					<label class="control-label">{t d='repasrc' m='Partager'}</label>
					<div class="controls">
						{$informations.shared}
						<div class="help" code="creerpartager"></div>
					</div>
				</div>
				<div class="control-group">
					<label class="control-label">{t d='repasrc' m="Type de menu"}</label>
					<div class="controls">
						{$informations.type}
						<div class="help" code="creertypedemenu"></div>
					</div>
				</div>
				{if $modulesList.seasonality}
					<h3 style="margin-bottom: 10px">Informations liées au module <i>saisonnalité</i></h3>
					<div class="control-group">
						<label class="control-label">{t d='repasrc' m="Date prévisionnelle de consommation"}</label>
						<div class="controls">
							{$informations.consumptiondate}
						</div>
						<div class="help" code="creerdateprevisionnelledeconsommationmenu"></div>
					</div>
				{/if}
				{if $modulesList.price}
					<h3 style="margin-bottom: 10px">Informations liées au module <i>prix</i></h3>
					<div class="control-group">
						<label class="control-label">{t d='repasrc' m="Prix du menu par personne"}</label>
						<div class="controls">
							{$informations.price}
							{$informations.vat}
						</div>
					</div>
				{/if}
				<div class="form-actions">
						{$informations.action}
						{$informations.submit}
						{$informations.cancel}
				</div>
				<input type="hidden" name="menuId" value="{$menu.id}" />
			</fieldset>
			{/form}
		</div>

{/block}
