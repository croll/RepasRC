{extends tplextends('repasrc/menu_edit')}

{block name='menu_title'}
	<h1>{t d='repasrc' m='Commentez'}</h1>
	<p class="lead">{t d='repasrc' m='Informations, astuces, reflexions, ... Commentez votre menu.'}</p>
{/block}

{block name='menu_content'}

	<div id="informations_container">
		<h2 style="margin-bottom: 3px">{$menu.label|ucfirst}</h2>
		<div class="alert alert-info">
			<a class="close" data-dismiss="alert">×</a>
			Les commentaires seront visibles par tous les utilisateurs.
		</div> 
		{form mod="repasrc" file="templates/menu/comments.json" defaultValues=$formDefaultValues}
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
				<input type="hidden" name="menuId" value="{$menu.id}" />
			</fieldset>
			{/form}
		</div>

{/block}
