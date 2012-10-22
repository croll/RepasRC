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
	
	{* *************************
	 * Tabs
	 ************************* *}
	<ul class="nav nav-tabs">
		<li class="active"><a href="#numbers" data-toggle="tab">Chiffres</a></li>
		<li><a href="#graphs" data-toggle="tab">Graphiques</a></li>
	</ul>

	<div class="tab-content">
		
	<h2 style="margin-bottom: 3px">{$recipe.label|ucfirst}</h2>
	
	{* *************************
	 * Tab datas
	 ************************* *}
		<div class="tab-pane active" id="numbers">
				<h3 style="margin:20px 0 10px 0">Répartition des aliments</h3>
				<table class="table table-bordered">
					<thead>
						<tr>
							<th>Aliments de saison</th>
							<th>Aliments hors saison</th>
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


		{foreach $recipe.foodstuffList as $fs}
				{foreach $fs.foodstuff.infos as $info}{/foreach}
					{if ($info.family_group == 'Fruits' || $info.family_group == 'Légumes') && $fs.foodstuff.seasonality}
						{if $fs@index == 0}
							<h3 style="margin:50px 0 -10px 0">Saisonalité des aliments répertoriés</h3>
						{/if}
						{if (isset($fs.foodstuff.synonym))}
							{assign var='label' value=$fs.foodstuff.synonym}
						{else}
							{assign var='label' value=$fs.foodstuff.label}
						{/if}
						<h4 style="margin: 25px 0 3px 0">
							{$label}
						</h4>
						<div class="btn-group">
						{foreach $fs.foodstuff.seasonality as $month=>$s}
							{if $s == 0}
								{if !empty($recipe.consumptionmonth) && $s@index+1 == $recipe.consumptionmonth}
									<span class="btn btn-danger"><div style="border-bottom: 2px solid #fff">{$month}</div></span>
								{else}
									<span class="btn btn-danger">{$month}</span>
								{/if}
							{else if $s == 1}
								{if !empty($recipe.consumptionmonth) && $s@index+1 == $recipe.consumptionmonth}
									<span class="btn btn-warning"><div style="border-bottom: 2px solid #fff">{$month}</div></span>
								{else}
									<span class="btn btn-warning">{$month}</span>
								{/if}
							{else}
								{if !empty($recipe.consumptionmonth) && $s@index+1 == $recipe.consumptionmonth}
									<span class="btn btn-success"><div style="border-bottom: 2px solid #fff">{$month}</div></span>
								{else}
									<span class="btn btn-success">{$month}</span>
								{/if}
							{/if}
						{/foreach}
						</div>
					{/if}
		{/foreach}



		</div>

	{* *************************
	 * Tab graphs
	 ************************* *}
		<div class="tab-pane" id="graphs">

			<script type="text/javascript" src="https://www.google.com/jsapi"></script>
			<script type="text/javascript">

			google.load('visualization', '1.0', { 'packages':['corechart'] } );
			google.setOnLoadCallback(drawChart);

			function drawChart() {

				{foreach $recipes as $recipe}

					var data2 = new google.visualization.DataTable();
					data2.addColumn('string', 'Topping');
					data2.addColumn('number', 'Slices');
					data2.addRows([
							['De saison', {$recipe.seasonality.ok|sizeof}],
							['Hors saison', {$recipe.seasonality.nok|sizeof}],
							['Information non disponible', {$recipe.seasonality.noinfo|sizeof}],
							['Hors contexte', {$recipe.seasonality.out|sizeof}]
							]);

					// Set chart options
					var options2 = { 'title':'{$recipe.label}',
						'width':800,
						'height':400 };

					// Instantiate and draw our chart, passing in some options.
					var chart2{$recipe@index} = new google.visualization.PieChart(document.getElementById('chart_div2{$recipe@index}'));
					chart2{$recipe@index}.draw(data2, options2);
				{/foreach}
			}
			</script>

			<div id="chart_div{$recipe@index}"></div>
			<div id="chart_div2{$recipe@index}"></div>

		</div>

	</div>
	{/if}
