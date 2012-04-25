{extends tplextends('repasrc/recipe_edit')}

{block name='recipe_title'}
	<h1>{t d='repasrc' m='Composer une recette'}</h1>
	<p class="lead">{t d='repasrc' m='Indiquez les informations de qualification de votre recette.'}</p>
{/block}

{block name='recipe_content'}

	<div id="informations_container">
		<div class="alert alert-info">
			<a class="close" data-dismiss="alert">×</a>
			Veuillez remplir le formulaire suivant pour renseigner les informations essentielles pour qualifier votre recette.
		</div> 
		{form mod="repasrc" file="templates/recipe/informations.json" defaultValues=\mod\repasrc\Recipe::getInfos($recipeId)}
			<fieldset>
				<div class="control-group">
					<label class="control-label">{t d='repasrc' m="Nom de la recette"}</label>
					<div class="controls">
						{$informations.label}
					</div>
				</div>
				<div class="control-group">
					<label class="control-label">{t d='repasrc' m="Composante"}</label>
					<div class="controls">
						{$informations.component}
						<p class="help-block">{t d='repasrc' m="Indique le type de recette: entrée, plat, dessert, pain."}</p>	
					</div>
				</div>
				<div class="control-group">
					<label class="control-label">{t d='repasrc' m="Nombre de convives"}</label>
					<div class="controls">
						{$informations.persons}
						<p class="help-block">{t d='repasrc' m="Nombre de personnes prévues pour la recette."}</p>	
					</div>
				</div>
				<div class="control-group">
					<label class="control-label">{t d='repasrc' m='Partager'}</label>
					<div class="controls">
						{$informations.shared}
						<p class="help-block">{t d='repasrc' m="Une recette partagée sera visible par les autres utilisateurs du calculateur. Ils pourront comparer leur recette avec la votre et créer une recette en s'inspirant de cette dernière."}</p>	
					</div>
				</div>
				<div class="control-group">
					<label class="control-label">{t d='repasrc' m="Type de recette"}</label>
					<div class="controls">
						{$informations.type}
					</div>
				</div>
				{if $modulesList.seasonality}
					<h3 style="margin-bottom: 10px">Informations liées au module de saisonnalité</h3>
					<div class="control-group">
						<label class="control-label">{t d='repasrc' m="Date prévisionnelle de consommation"}</label>
						<div class="controls">
							{$informations.consumptiondate}
							<p class="help-block">{t d='repasrc' m="Date prévisionnelle à laquelle la recette devrait être consommée. C'est à partir de cette date que sera calculée la saisonnalité des aliments composant la recette."}</p>	
						</div>
					</div>
				{/if}
				<div class="form-actions">
						{$informations.submit}
						{$informations.cancel}
				</div>
				<input type="hidden" name="recipeId" value="{$recipeId}" />
			</fieldset>
			{/form}
		</div>

{/block}
