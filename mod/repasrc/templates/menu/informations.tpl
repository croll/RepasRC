{extends tplextends('repasrc/menu_edit')}

{block name='menu_title'}
	<h1>{t d='repasrc' m='Composer un menu'}</h1>
	<p class="lead">{t d='repasrc' m='Indiquez les informations de qualification de votre menu.'}</p>
{/block}

{block name='menu_content'}

	<div id="informations_container">
		<div class="alert alert-info">
			<a class="close" data-dismiss="alert">×</a>
			Veuillez remplir le formulaire suivant pour renseigner les informations essentielles pour qualifier votre menu.
		</div> 
		{form mod="repasrc" file="templates/menu/informations.json" defaultValues=\mod\repasrc\Menu::getInfos($menu.id)}
			<fieldset>
				<div class="control-group">
					<label class="control-label">{t d='repasrc' m="Nom du menu"}</label>
					<div class="controls">
						{$informations.label}
					</div>
				</div>
				<div class="control-group">
					<label class="control-label">{t d='repasrc' m="Nombre de convives"}</label>
					<div class="controls">
						{$informations.eaters}
						<p class="help-block">{t d='repasrc' m="Nombre de personnes prévues pour la menu."}</p>	
					</div>
				</div>
				<div class="control-group">
					<label class="control-label">{t d='repasrc' m='Partager'}</label>
					<div class="controls">
						{$informations.shared}
						<p class="help-block">{t d='repasrc' m="Un menu partagé sera visible par les autres utilisateurs du calculateur. Ils pourront comparer leur menu avec le votre et créer un menu en s'inspirant de cette dernière."}</p>	
					</div>
				</div>
				<div class="control-group">
					<label class="control-label">{t d='repasrc' m="Type de menu"}</label>
					<div class="controls">
						{$informations.type}
					</div>
				</div>
				{if $modulesList.seasonality}
					<h3 style="margin-bottom: 10px">Informations liées au module <i>saisonnalité</i></h3>
					<div class="control-group">
						<label class="control-label">{t d='repasrc' m="Date prévisionnelle de consommation"}</label>
						<div class="controls">
							{$informations.consumptiondate}
							<p class="help-block">{t d='repasrc' m="Date prévisionnelle à laquelle le menu devrait être consommé. C'est à partir de cette date que sera calculée la saisonnalité des aliments composant les menus du menu."}</p>	
						</div>
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
						{$informations.submit}
						{$informations.cancel}
				</div>
				<input type="hidden" name="menuId" value="{$menu.id}" />
			</fieldset>
			{/form}
		</div>

{/block}
