{extends tplextends('repasrc/recipe_edit')}

{block name='recipe_title'}
	<h1>{t d='repasrc' m='Composer une recette'}</h1>
	<p class="lead">{t d='repasrc' m='Indiquez les informations de qualification de votre recette.'}</p>
{/block}

{block name='recipe_content'}

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
					<label class="control-label">{t d='repasrc' m="Commentaires"}</label>
					<div class="controls">
						{$informations.comment}
						<p class="help-block">{t d='repasrc' m="Vous avez la possibilité de commenter la recette afin de donner des informations supplémentaires aux utililsateurs du calculateur. La recette sera alors classée en tant que <i>recette commentée</i>."}</p>	
					</div>
				</div>
				<div class="form-actions">
						{$informations.submit}
						{$informations.cancel}
				</div>
				<input type="hidden" name="recipeId" value="{$recipeId}" />
			</fieldset>
		{/form}

{/block}
