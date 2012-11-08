{extends tplextends('repasrc/container')}

{block name='main-container-title'}
	<h1>{t d='repasrc' m='Importer une liste de recettes'}</h1>
	<p class="lead">{t d='repasrc' m='Plutôt que saisir vos recettes, importez directement un fichier excel.'}</p>
{/block}

{block name='main-container-content'}
	<div class="alert alert-warn">
		<a class="close" data-dismiss="alert">×</a>
		Vous pouvez télécharger le fichier type en <a href="/mod/repasrc/files/exemple_import.csv">cliquant ici</a> ainsi que la liste des aliments et leur code associé en suivant <a href="/mod/repasrc//files/liste_des_aliments.csv">ce lien</a>. <br />
		Si des erreurs sont détectées lors de l'import, elles seront affichées ci dessous.
	</div> 

	{if !isset($result)}

		{form mod="repasrc" file="templates/recipe/import.json"}
			<fieldset>
				<legend>{t d='repasrc' m="Import d'une liste de recettes."}</legend>
				<div class="control-group">
					<label class="control-label">{t d='repasrc' m="Séparateur"}</label>
					<div class="controls">
					{$dbUpload.separator}
					<p class="help-block">{t d='repasrc' m="Utilisez \\t pour une tabulation"}</p>	
					</div>
				</div>
				<div class="control-group">
					<label class="control-label">{t d='repasrc' m="Lignes à ignorer"}</label>
					<div class="controls">
						{$dbUpload.skipline}
					<p class="help-block">{t d='repasrc' m="Nombre de ligne en début de fichier à ne pas traiter"}</p>	
					</div>
				</div>
				<div class="control-group">
					<label class="control-label">{t d='repasrc' m="Caractère d'échappement"}</label>
					<div class="controls">
						{$dbUpload.enclosure}
					</div>
				</div>
				<div class="control-group">
					<label class="control-label">Fichier à analyser</label>
					<div class="controls">
						{$dbUpload.dbfile}
					</div>
				</div>
				<div class="form-actions">
						{$dbUpload.submit}
				</div>
			</fieldset>
		{/form}

	{else}
		<a href="/import/">{t d="repasrc" m="Effectuer un autre import"}</a>
		<div style="width: 100%; margin: 0px auto 10px auto">
			<div style="padding:3px"><i class="icon-align-justify" style="margin-right: 3px"></i><b>{$result.total}</b> sites processed.</div>
			<div style="padding:3px"><i class="icon-ok" style="margin-right: 3px"></i><b>{$result.processed}</b> sites imported.</div>
			<div style="padding:3px"><i class="icon-exclamation-sign" style="margin-right: 3px"></i><b>{$result.errors|sizeof}</b> Errors (see below)</div>
		</div>	

		<table class="table table-striped table-bordered table-condensed" style="width: 1200px; margin: 0px auto 50px auto">
			<thead>
				<tr>
					<th>Code</th>
					<th>Error</th>
				</tr>
			</thead>
			<tbody>
			{foreach $result.errors as $item}
				{foreach $item as $it}
						<tr>
							<td>{$item@key}</td>
							<td>
								{foreach $it.msg as $msg}
									{$msg}<br />
								{/foreach}
							</td>
						</tr>
				{/foreach}
			{/foreach}
			</tbody>
		</table>

		{if is_array($result.processingErrors) && sizeof($result.processingErrors) > 0}
		<div style="font-weight: bold">Debug</div>
		<table class="table table-striped table-bordered table-condensed" style="width: 1200px; margin: 0px auto 50px auto">
			<thead>
				<tr>
					<th>Code</th>
					<th>Error</th>
				</tr>
			</thead>
			<tbody>
			{foreach $result.processingErrors as $item}
				{foreach $item as $it}
						<tr>
							<td>{$item@key}</td>
							<td>
								{foreach $it.msg as $msg}
									{$msg}<br />
								{/foreach}
							</td>
						</tr>
				{/foreach}
			{/foreach}
			</tbody>
		</table>
		{/if}

	{/if}

{/block}
