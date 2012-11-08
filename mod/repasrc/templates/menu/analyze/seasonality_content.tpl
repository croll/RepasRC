{* If no consumption date defined, error *}
{if $nodata === true}
	<div class="alert alert-danger">
		La saisonnalité ne peut être analysée car aucune recette de ce menu n'a de date de consommation définie.<br />
	</div> 
{else}
	{if empty($oldbrowser)}
	    <script type="text/javascript" src="http://canvg.googlecode.com/svn/trunk/rgbcolor.js"></script> 
	    <script type="text/javascript" src="http://canvg.googlecode.com/svn/trunk/canvg.js"></script>
	{/if}
	
	{* *************************
	 * Tabs
	 ************************* *}
	<ul class="nav nav-tabs">
		<li class="active"><a href="#numbers" data-toggle="tab">Chiffres</a></li>
		<li><a href="#graphs" data-toggle="tab">Graphiques</a></li>
	</ul>

	<div class="tab-content">
		
	<h2 style="margin-bottom: 3px">{$menu.label|ucfirst}</h2>
	
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
								{foreach $menu.seasonality.ok as $name}
									- {$name}<br />
								{/foreach}
							</td>
							<td>
								{foreach $menu.seasonality.nok as $name}
									- {$name}<br />
								{/foreach}
							</td>
							<td>
								{foreach $menu.seasonality.noinfo as $name}
									- {$name}<br />
								{/foreach}
							</td>
							<td>
								{foreach $menu.seasonality.out as $name}
									- {$name}<br />
								{/foreach}
							</td>
						</tr>
					</tbody>
				</table>

		<h3 style="margin:50px 0 -10px 0">Saisonalité des aliments répertoriés</h3>
		{assign var="done" value=array()}
		{foreach $menu.recipesList as $recipe}
			{foreach $recipe.foodstuffList as $fs}
					{foreach $fs.foodstuff.infos as $info}{/foreach}
						{if ($info.family_group == 'Fruits' || $info.family_group == 'Légumes') && $fs.foodstuff.seasonality}
							{assign var='label' value=\mod\repasrc\Recipe::getFoodstuffLabel($fs)}
							{if !in_array($label, $done)}
							{if !empty($menu.consumptionmonth)}
								{assign var="month" value=$menu.consumptionmonth}
							{else}
								{assign var="month" value=$recipe.consumptionmonth}
							{/if}
								<h4 style="margin: 25px 0 3px 0">
									{$label}
								</h4>
								{append var="done" value=$label}
								<div class="btn-group">
								{foreach $fs.foodstuff.seasonality as $m=>$s}
									{if $s == 0}
										{if !empty($month) && $s@index+1 == $month}
											<span class="btn btn-danger"><div style="border-bottom: 2px solid #fff">{$m}</div></span>
										{else}
											<span class="btn btn-danger">{$m}</span>
										{/if}
									{else if $s == 1}
										{if !empty($month) && $s@index+1 == $month}
											<span class="btn btn-warning"><div style="border-bottom: 2px solid #fff">{$m}</div></span>
										{else}
											<span class="btn btn-warning">{$m}</span>
										{/if}
									{else}
										{if !empty($month) && $s@index+1 == $month}
											<span class="btn btn-success"><div style="border-bottom: 2px solid #fff">{$m}</div></span>
										{else}
											<span class="btn btn-success">{$m}</span>
										{/if}
									{/if}
								{/foreach}
								</div>
							{/if}
						{/if}
			{/foreach}
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
					var data2 = new google.visualization.DataTable();
					data2.addColumn('string', 'Topping');
					data2.addColumn('number', 'Slices');
					data2.addRows([
							['De saison', {$menu.seasonality.ok|sizeof}],
							['Hors saison', {$menu.seasonality.nok|sizeof}],
							['Information non disponible', {$menu.seasonality.noinfo|sizeof}],
							['Hors contexte', {$menu.seasonality.out|sizeof}]
							]);

					// Set chart options
					var options2 = { 'title':'{$menu.label}',
						'width':800,
						'height':400 };

					// Instantiate and draw our chart, passing in some options.
					var chart2 = new google.visualization.PieChart(document.getElementById('chart_div'));
					chart2.draw(data2, options2);
			}
			</script>

			<div id="chart_div"></div>
      {if empty($oldbrower)}
      <div style="width:200px;margin:0 auto 0 auto">
        <a href="javascript:void(0)" onclick="saveAsImg('chart_div', '{$menu.label} - Saisonnalité des aliments')">Enregistrer le graphique</a>
      </div>
      {else}
        <div class="help" code="navigateurimpressionimpossible"></div>
      {/if}

		</div>

	</div>
	{/if}
