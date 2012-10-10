<div id="duplicate_container">
	{form mod="repasrc" file="templates/menu/updateRecipe.json"}
		<fieldset>
			<div class="control-group">
				<label class="control-label">{t d='repasrc' m="Nombre de convives"}</label>
				<div class="controls">
					{$informations.portions}
				</div>
			</div>
			<div class="form-actions">
					{if $recipeId}
						{$informations.addRecipe}
					{else}
						{$informations.updateRecipePortions}
					{/if}
					{$informations.cancel}
			</div>
		</fieldset>
		<input type="hidden" name="menuId" value="{$menuId}" />
		<input type="hidden" name="recipeId" value="{$recipeId}" />
		<input type="hidden" name="menuRecipeId" value="{$menuRecipeId}" />
	{/form}
</div>
