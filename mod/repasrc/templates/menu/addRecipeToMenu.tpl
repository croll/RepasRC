<div id="duplicate_container">
	{form mod="repasrc" file="templates/menu/addRecipeToMenu.json"}
		<fieldset>
			<div class="control-group">
				<label class="control-label">{t d='repasrc' m="Nombre de convives"}</label>
				<div class="controls">
					{$informations.eaters}
				</div>
			</div>
			<div class="form-actions">
					{$informations.submit}
					{$informations.cancel}
			</div>
		</fieldset>
		<input type="hidden" name="menuId" value="{$menuId}" />
		<input type="hidden" name="recipeId" value="{$recipeId}" />
		<input type="hidden" name="action" value="addRecipeToMenu" />
	{/form}
</div>
