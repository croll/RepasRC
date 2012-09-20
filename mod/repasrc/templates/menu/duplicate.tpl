<div id="duplicate_container">
	{form mod="repasrc" file="templates/menu/duplicate.json"}
		<fieldset>
			<div class="control-group">
				<label class="control-label">{t d='repasrc' m="Nom du menu"}</label>
				<div class="controls">
					{$informations.label}
				</div>
			</div>
			<div class="form-actions">
					{$informations.submit}
					{$informations.cancel}
			</div>
		</fieldset>
		<input type="hidden" name="recipeId" value="{$menuId}" />
		<input type="hidden" name="action" value="duplicate" />
	{/form}
</div>
