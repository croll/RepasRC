{* If no consumption date defined, error *}
{if empty($recipe.consumptionmonth)}
	<div class="alert alert-danger">
		La saisonnalité ne peut être analysée car aucune date de consommation de la recette n'est définie.<br />
		{if \mod\repasrc\RC::isRecipeOwner($recipe.id)}
			Vous pouvez indiquer cette information en <a href="/recette/edition/informations/{$recipe.id}">cliquant ici</a>.
		{/if}
			</div> 
	{* Ok we get a consumption date *}
{else}

	<ul class="nav nav-tabs">
		<li class="active"><a href="#numbers" data-toggle="tab">Chiffres</a></li>
		<li><a href="#graphs" data-toggle="tab">Graphiques</a></li>
	</ul>

	<div class="tab-content">

		<div class="tab-pane active" id="numbers">
			{foreach $recipes as $recipe}
			<h3>{$recipe.label}</h3>
			<table class="table table-bordered">
				<thead>
					<tr>
						<th>Aliments de saison</th>
						<th>Aliments hors siason</th>
						<th>Information non disponible</th>
						<th>Hors contexte</th>
					</tr>
				</thead>
				<tbody>
					<tr>
						<td>
							{foreach $recipe.seasonality.ok as $name}
								- {$name}<br />
							{/foreach}
						</td>
						<td>
							{foreach $recipe.seasonality.nok as $name}
								- {$name}<br />
							{/foreach}
						</td>
						<td>
							{foreach $recipe.seasonality.noinfo as $name}
								- {$name}<br />
							{/foreach}
						</td>
						<td>
							{foreach $recipe.seasonality.out as $name}
								- {$name}<br />
							{/foreach}
						</td>
					</tr>
				</tbody>
			</table>
			{/foreach}
		</div>

		<div class="tab-pane" id="graphs">
		</div>

	</div>

{/if}
