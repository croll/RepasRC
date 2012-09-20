{extends tplextends('repasrc/recipe_edit')}

{block name='recipe_title'}
	<h1>{t d='repasrc' m='Sélectionner les modules'}</h1>
	<p class="lead">{t d='repasrc' m='Saisonnalité, transport, prix ... Ils vous permettront d\'analyser votre recette selon différents facteurs.'}</p>
{/block}

{block name='recipe_content'}
	<div class="alert alert-info">
		<a class="close" data-dismiss="alert">×</a>
		<p>
		L'impact écologique de ce que l'on mange dépend de nombreux facteurs : les aliments sont-ils de saison ? Comment ont-ils été produits ? Viennent-ils de loin ?<br /> 
Vous avez le choix de sélectionner ou non chacune de ces fonctionnalités du calculateur :<br />
		<strong>Saisonnalité</strong>, <strong>Mode de production</strong>, <strong>Origine et transport</strong><p>
		<p>
			<strong>Le prix</strong> étant un élément important des prises de décision alimentaires, vous pouvez choisir de renseigner ces données.
		</p>
		Cliquez sur les modules que vous souhaitez activer et validez votre sélection.<br />
	</div> 
	<div id="modules_container">
		<ul class="nav nav-tabs nav-stacked">
			<li id="seasonality" class="row select{if (isset($modulesList) && isset($modulesList.seasonality) && $modulesList.seasonality == 1)} checked{/if}">
				<div class="title"><h3>{t d='repasrc' m='Module saisonnalité'}</h3></div>
				<div class="hint">Le module Saisonnalité offre une aide pour savoir si la période de consommation du produit est adapté. Diverses informations vous seront données pour vous aider dans vos choix.</div>
			</li>
			<li id="production"  class="row select{if (isset($modulesList) && isset($modulesList.production) &&  $modulesList.production == 1)} checked{/if}">
				<div class="title"><h3>{t d='repasrc' m='Module Production'}</h3></div>
				<div class="hint">Ce module vous permet de définir les modes de conservation et de production des aliments.</div>
			</li>
			<li id="transport" class="row select{if (isset($modulesList) && isset($modulesList.transport) &&  $modulesList.transport == 1)} checked{/if}">
				<div class="title"><h3>{t d='repasrc' m='Module transport'}</h3></div>
				<div class="hint">Si vous avez la possibilité d'indiquer la provenance des aliments pour pourrez bénéficier d'une analyse sur l'impact des transports.</div>
			</li>
			<li id="price" class="row select{if (isset($modulesList) && isset($modulesList.price) &&  $modulesList.price == 1)} checked{/if}">
				<div class="title"><h3>{t d='repasrc' m='Module prix'}</h3></div>
				<div class="hint">En indiquant le prix des aliments, un calcul du prix par recette, menu ou plan alimentaire vous sera proposé.</div>
			</li>
		</ul>
			<form id="modules_form" name="modules_form"  action="/recette/edition/informations" method="post">
				<div class="form-actions">
					<input type="submit" class="btn btn-primary special" id="submit" value="Valider le choix de modules" />
					<input type="button" class="btn" id="cancel" value="Annuler la création de la recette" />
				</div>
				<input type="hidden" id="modules" name="modules" value="" />
				{if isset($recipe.id)}
					<input type="hidden" name="recipeId" value="{$recipe.id}" />
				{/if}
			</form>
	</div>
{/block}
