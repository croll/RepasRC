<div style="margin: 0 0 20px 20px; font-size: 16px">
	<div>Composante: <strong>{$recipe.component}</strong></div>
	<div>Nombre de convives: <strong>{$recipe.persons}</strong></div>
	{*
	<div>Empreinte écologique foncière: <strong>{$recipe.footprint}</strong> m²g</div>
	*}
</div>

{foreach $recipe.foodstuffList as $fs}
<div style="margin: 0 0 20px 20px">
	<div style="font-size: 18px">
		{$fs.quantity} {$fs.unit}
		<strong>
			{if (isset($fs.foodstuff.synonym))}
				{$fs.foodstuff.synonym}
			{else}
				{$fs.foodstuff.label}
			{/if}
		</strong>
	</div>
	<div>
	{foreach $fs.foodstuff.infos as $info}
		{if $info.family_group_id == 2}
			<span class="badge fam{$info.family_group_id} help" code="commentaireanalyserecetteempreintefoncierecerealesfeculents" style="margin: 0px 5px 0 0">{$info.family_group}</span>
		{else if $info.family_group_id == 6}
			<span class="badge fam{$info.family_group_id} help" code="commentaireanalyserecetteempreitnefoncierevpo" style="margin: 0px 5px 0 0">{$info.family_group}</span>
		{else}
			<span class="badge fam{$info.family_group_id}" style="margin: 0px 5px 0 0">{$info.family_group}</span>
		{/if}
	{/foreach}
	</div>
	<div style="font-size: 14px">
		{if (!empty($fs.conservation))}
			<div style="font-size: 12px">Mode de conservation: <strong>{$fs.conservation_label}</strong></div>
		{/if}
		{if (!empty($fs.production))}
			<div style="font-size: 12px">Mode de production: <strong>{$fs.production_label}</strong></div>
		{/if}
		{*
		<div>Empreinte écologique foncière: <strong>{$fs.foodstuff.footprint|round:3} m²g/Kg</strong></div>
		<div>Empreinte écologique foncière pour la recette: <strong>{math equation="round(x * y,3)" x=$fs.foodstuff.footprint y=$fs.quantity} m²g</strong></div>
		{if ($fs.foodstuff.infos.0.family_group == 'Fruits' || $fs.foodstuff.infos.0.family_group == 'Légumes') && $fs.foodstuff.seasonality}
		<div style="margin-top:10px">Saisonnalité: <span></span></div>
			<div class="btn-group">
			{foreach $fs.foodstuff.seasonality as $month=>$s}
					{if $s == 0}
						{if $s@index+1 == $recipe.consumptionmonth}
							<span class="btn btn-danger"><div style="border-bottom: 2px solid #fff">{$month}</div></span>
						{else}
							<span class="btn btn-danger">{$month}</span>
						{/if}
					{else if $s == 1}
						{if $s@index+1 == $recipe.consumptionmonth}
							<span class="btn btn-warning"><div style="border-bottom: 2px solid #fff">{$month}</div></span>
						{else}
							<span class="btn btn-warning">{$month}</span>
						{/if}
					{else}
						{if $s@index+1 == $recipe.consumptionmonth}
							<span class="btn btn-success"><div style="border-bottom: 2px solid #fff">{$month}</div></span>
						{else}
							<span class="btn btn-success">{$month}</span>
						{/if}
					{/if}
			{/foreach}
			</div>
		{/if}
		*}

	</div>
</div>
{/foreach}
<div style="margin:20px;0px;0px;20px"><a href="/recette/exporter/{$recipe.id}">Exporter la recette au format csv</a></div>
<div class="form-actions" style="margin-top:30px">
	<a class="btn analyzeButton help" location="top" code="boutonanalyserlarecette" href="/recette/analyse/resume/{$recipe.id}">Analyser la recette</a>
	{if !isset($menuId) && $comparison != false}
	<a class="btn compareButton help" code="boutonselectionnerlarecettepourcomparaison" location="top" href="/recette/liste/add/{$recipe.id}">Sélectionner la recette pour comparaison</a>
	{else}
		{if empty($menuRecipeId)}
			<a class="btn btn-primary" href="javascript:void(0)" onclick="showUpdateMenuRecipeModal({$menuId}, {$recipe.id}, null)">Ajouter la recette</a>
		{else}
			<a class="btn btn-primary" href="javascript:void(0)" onclick="showUpdateMenuRecipeModal(null, null, {$menuRecipeId})">Changer le nombre de portions</a>
			<a class="btn btn-danger" href="javascript:void(0)" onclick="deleteMenuRecipe({$menuRecipeId})">Supprimer la recette de ce menu</a>
		{/if}
	{/if}
	<a class="btn btn-inverse" href="javascript:void(0)" onclick="modalWin.hide()">Fermer</a>
	{if !isset($menuId)}
	<div style="text-align:center;margin-top:10px">
		{if \mod\user\Main::userBelongsToGroup('admin') || \mod\repasrc\RC::isRecipeOwner({$recipe.id})}
			<a class="btn help" code="boutonmodifierlarecette" location="top" href="/recette/edition/aliments/{$recipe.id}">Modifier la recette</a>
		{/if}
		<a class="btn help" code="boutondupliquerlarecette" location="top" href="Javascript:void(0)" onclick="duplicateRecipeModal({$recipe.id})">Dupliquer la recette</a>
		{if \mod\user\Main::userBelongsToGroup('admin') || \mod\repasrc\RC::isRecipeOwner({$recipe.id})}
			<a class="btn btn-danger" href="javascript:void(0)" onclick="deleteRecipe({$recipe.id})">Effacer la recette</a>
		{/if}
	</div>
	{/if}
</div>
