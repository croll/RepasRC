{extends tplextends('repasrc/recipe_edit')}

{block name='recipe_title'}
	<h1>{t d='repasrc' m='Commentez'}</h1>
	<p class="lead">{t d='repasrc' m='Informations, astuces, reflexions, ... Commentez votre recette.'}</p>
{/block}

{block name='recipe_content'}

	<div id="informations_container">
		<div class="alert alert-info">
			<a class="close" data-dismiss="alert">×</a>
			Les commentaires seront visibles par tous les utilisateurs.
		</div> 
		{form mod="repasrc" file="templates/recipe/comments.json" defaultValues=$formDefaultValues}
			<fieldset>
				<div class="control-group">
					<label class="control-label">{t d='repasrc' m="Commentaire"}</label>
					<div class="controls">
						{$comments.comment}
					</div>
				</div>
				<div class="form-actions">
						{$comments.submit}
				</div>
				<input type="hidden" name="recipeId" value="{$recipeId}" />
			</fieldset>
			{/form}
		</div>

{/block}
