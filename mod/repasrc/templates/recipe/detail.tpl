<div style="margin: 0 0 20px 20px; font-size: 16px">
	<div>Composante: <strong>{$recipe.component}</strong></div>
	<div>Nombre de convives: <strong>{$recipe.persons}</strong></div>
	<div>Empreinte écologique foncière: <strong>{$recipe.footprint}</strong> m²g</div>
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
		<span class="badge fam{$info.family_group_id}" style="margin: 0px 5px 0 0">{$info.family_group}</span>
	{/foreach}
	</div>
	<div style="font-size: 14px">
		{if (!empty($fs.conservation))}
			<div>Mode de conservation: <strong>{$fs.conservation_label}</strong></div>
		{/if}
		{if (!empty($fs.production))}
			<div>Mode de production: <strong>{$fs.production_label}</strong></div>
		{/if}
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

	</div>
</div>
{/foreach}
<div class="form-actions" style="margin-top:30px">
	<a class="btn analyzeButton" href="/recette/analyse/resume/{$recipe.id}">Analyser la recette</a>
	<a class="btn compareButton" href="/recette/liste/add/{$recipe.id}">Sélectionner la recette pour comparaison</a>
	<a class="btn btn-inverse" href="javascript:void(0)" onclick="modalWin.hide()">Fermer</a>
	<div style="text-align:center;margin-top:10px">
		{if \mod\user\Main::userBelongsToGroup('admin') || \mod\repasrc\RC::isRecipeOwner({$recipe.id})}
			<a class="btn" href="/recette/edition/aliments/{$recipe.id}">Modifier la recette</a>
		{/if}
		<a class="btn" href="Javascript:void(0)" onclick="duplicateRecipeModal({$recipe.id})">Dupliquer la recette</a>
		{if \mod\user\Main::userBelongsToGroup('admin') || \mod\repasrc\RC::isRecipeOwner({$recipe.id})}
			<a class="btn btn-danger" href="javascript:void(0)" onclick="deleteRecipe({$recipe.id})">Effacer la recette</a>
		{/if}
	</div>
</div>
