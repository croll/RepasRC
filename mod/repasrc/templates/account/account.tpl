{extends tplextends('repasrc/container')}

{block name='main-container-title'}
	<h1>{t d='repasrc' m='Mon compte'}</h1>
	<p class="lead">{t d='repasrc' m='Informations relatives à votre restauration collective.'}</p>
{/block}

{block name='main-container-content'}

		{form mod="repasrc" file="templates/account/account.json"}
			<fieldset>
				<div class="control-group">
					<label class="control-label">{t d='repasrc' m="Nom"}</label>
					<div class="controls">
						{$informations.name}
					</div>
				</div>
				<div class="control-group">
					<label class="control-label">{t d='repasrc' m="Type de public"}</label>
					<div class="controls">
						{$informations.select_public}
						<p class="help-block">{t d='repasrc' m=""}</p>	
					</div>
				</div>
				<div class="control-group">
					<label class="control-label">{t d='repasrc' m="Mode de gestion"}</label>
					<div class="controls">
						{$informations.select_administration}
						<p class="help-block">{t d='repasrc' m=""}</p>	
					</div>
				</div>
				<div class="control-group">
					<label class="control-label">{t d='repasrc' m="Nombre de jours d'activité dans l'année"}</label>
					<div class="controls">
						{$informations.daysactive}
					</div>
				</div>
				<div class="alert alert-info">
					La localisation géographique de votre RC est utilisée pour le module Transport. Indiquez dans la zone de saisie les 1ères lettres de votre commune. Votre choix définitif s'affichera alors dans le champ suivant.
				</div>
				<div class="control-group">
					<label class="control-label">{t d='repasrc' m='Nom de la commune'}</label>
					<div class="controls">
						{$informations.city}
						<p class="help-block">{t d='repasrc' m="Saisissez les premieres lettres du nom de la commune."}</p>	
					</div>
				</div>
				<div class="control-group">
					<label class="control-label">{t d='repasrc' m=""}</label>
					<div class="controls">
						{$informations.city_selected}
						<p class="help-block">{t d='repasrc' m="La commune sélectionnée s'affichera dans ce champs de saisie."}</p>	
					</div>
				</div>
				<div class="form-actions">
						{$informations.submit}
						{$informations.cancel}
				</div>
			</fieldset>
		{/form}

{/block}
