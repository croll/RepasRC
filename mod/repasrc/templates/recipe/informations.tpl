{extends tplextends('repasrc/recipe_edit')}

{block name='recipe_title'}
	<h1>{t d='repasrc' m='Composer une recette'}</h1>
	<p class="lead">{t d='repasrc' m='Indiquez les informations de qualification de votre recette.'}</p>
{/block}

{block name='recipe_content'}

	<div id="informations_container">
		<div class="help" code="composerunerecetteformulaire"></div>
		{form mod="repasrc" file="templates/recipe/informations.json" defaultValues=\mod\repasrc\Recipe::getInfos($recipe.id)}
			<fieldset>
				<div class="control-group">
					<label class="control-label">{t d='repasrc' m="Nom de la recette"}</label>
					<div class="controls">
						{$informations.label}
						<div class="help" code="creernomdelarecette"></div>
					</div>
				</div>
				<div class="control-group">
					<label class="control-label">{t d='repasrc' m="Composante"}</label>

					<div class="controls">
						{$informations.component}
						<div class="help" code="creercomposante"></div>
					</div>
				</div>
				<div class="control-group">
					<label class="control-label">{t d='repasrc' m="Nombre de convives"}</label>
					<div class="controls">
						{$informations.persons}
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
					<label class="control-label">{t d='repasrc' m="Type de recette"}</label>
					<div class="controls">
						{$informations.type}
						<div class="help" code="creertypederecette"></div>
					</div>
				</div>
				{if $modulesList.seasonality}
					<h3 style="margin-bottom: 10px">Informations liées au module <i>saisonnalité</i></h3>
					<div class="control-group">
						<label class="control-label">{t d='repasrc' m="Date prévisionnelle de consommation"}</label>
						<div class="controls">
							{$informations.consumptiondate}
							<div class="help" code="creerdateprevisionnelledeconsommation"></div>
						</div>
					</div>
				{/if}
				{if $modulesList.price}
					<h3 style="margin-bottom: 10px">Informations liées au module <i>prix</i></h3>
					<div class="control-group">
						<label class="control-label">{t d='repasrc' m="Prix de la recette par personne"}</label>
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
				<input type="hidden" name="recipeId" value="{$recipe.id}" />
			</fieldset>
			{/form}
		</div>

{/block}
