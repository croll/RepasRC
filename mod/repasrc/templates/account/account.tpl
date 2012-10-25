{extends tplextends('repasrc/container')}

{block name='main-container-title'}
	<h1>{t d='repasrc' m='Mon compte'}</h1>
	<p class="lead">{t d='repasrc' m='Informations relatives à votre restauration collective.'}</p>
{/block}

{block name='webpage_head' append}
	{js file='/mod/repasrc/js/account.js'}
{/block}

{block name='main-container-content'}

		<div class="help" code="vosinformations"></div>
		{form mod="repasrc" file="templates/account/account.json" defaultValues=\mod\repasrc\RC::getRcInfos($smarty.session.rc)}
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
						{$informations.public}
					</div>
				</div>
				<div class="control-group">
					<label class="control-label">{t d='repasrc' m="Mode de gestion"}</label>
					<div class="controls">
						{$informations.type}
					</div>
				</div>
				<div class="alert alert-info">
					La localisation géographique de votre RC est utilisée pour le module Transport. Indiquez dans la zone de saisie les 1ères lettres de votre commune. Votre choix définitif s'affichera alors dans le champ suivant.
				</div>
				<div class="control-group">
					<label class="control-label">{t d='repasrc' m='Nom de la commune'}</label>
					<div class="controls">
						{$informations.city}
						<div class="help" code="nomdelacommune"></div>
					</div>
				</div>
				<div class="control-group">
					<label class="control-label"></label>
					<div class="controls">
						{$informations.zonelabel}
					</div>
				</div>
				<div class="control-group">
					<label class="control-label">{t d='repasrc' m="Afficher les bulles d'aide"}</label>
					<div class="controls">
						{$informations.showhelp}
					</div>
				</div>
				<div class="form-actions">
						{$informations.zoneid}
						{$informations.submit}
						{$informations.cancel}
				</div>
			</fieldset>
		{/form}

{/block}
