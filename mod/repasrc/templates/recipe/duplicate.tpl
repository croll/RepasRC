<div id="duplicate_container">
	{form mod="repasrc" file="templates/recipe/duplicate.json"}
		<fieldset>
			<div class="control-group">
				<label class="control-label">{t d='repasrc' m="Nom de la recette"}</label>
				<div class="controls">
					{$informations.label}
				</div>
			</div>
			<div class="form-actions">
					{$informations.submit}
					{$informations.cancel}
			</div>
		</fieldset>
		<input type="hidden" id='recipeDuplicationID' name="recipeId" value="{$recipeId}" />
		<input type="hidden" name="action" value="duplicate" />
	{/form}
</div>
