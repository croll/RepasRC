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
			<h3 style="margin:20px 0 10px 0">Modes de conservation et de production</h3>
			<table class="table table-bordered">
				<thead>
					<tr>
						<th>Aliment</th>
						<th>Mode de conservation</th>
						<th>Mode de production</th>
					</tr>
				</thead>
				<tbody>
					{assign var="done"  value=array()}
					{foreach $menu.recipesList as $recipe}
						{foreach $recipe.foodstuffList as $fs}
							{assign var='label' value=\mod\repasrc\Recipe::getFoodstuffLabel($fs)}
							{if !in_array($label, $done)}
								<tr>
									<td>
										{$label}
									</td>
									<td>
										{$fs.conservation_label}
									</td>
									<td>
										{$fs.production_label}
									</td>
								</tr>
								{append var="done" value="label"}
							{/if}
						{/foreach}
					{/foreach}
				</tbody>
			</table>

		</div>

		<div class="tab-pane" id="graphs">

			<script type="text/javascript" src="https://www.google.com/jsapi"></script>
			<script type="text/javascript">

			google.load('visualization', '1.0', { 'packages':['corechart'] } );
			google.setOnLoadCallback(drawChart);

			function drawChart() {
				var dataPie1 = new google.visualization.DataTable({$dataConservation});
				var dataPie2 = new google.visualization.DataTable({$dataProduction});

				var optionsPie1 = { 
					'title':'Répartition des modes de production',
					'width':800,
					'height':400 
				};

				var optionsPie2 = { 
					'title':'Répartition des modes de conservation',
					'width':800,
					'height':400
				};

				var chart1 = new google.visualization.PieChart(document.getElementById('chart_div'));
				var chart2 = new google.visualization.PieChart(document.getElementById('chart_div2'));
				chart1.draw(dataPie1, optionsPie1);
				chart2.draw(dataPie2, optionsPie2);
			}
			</script>

			<div id="chart_div"></div>
      {if empty($oldbrower)}
      <div style="width:200px;margin:0 auto 0 auto">
        <a href="javascript:void(0)" onclick="saveAsImg('chart_div', '{$menu.label} - Répartition des modes de production')">Enregistrer le graphique</a>
      </div>
      {else}
        <div class="help" code="navigateurimpressionimpossible"></div>
      {/if}
      <br /><br /><hr>
			<div id="chart_div2"></div>
      {if empty($oldbrower)}
      <div style="width:200px;margin:0 auto 0 auto">
        <a href="javascript:void(0)" onclick="saveAsImg('chart_div', '{$menu.label} - Répartition des modes de conservation')">Enregistrer le graphique</a>
      </div>
      {else}
        <div class="help" code="navigateurimpressionimpossible"></div>
      {/if}

		</div>

	</div>
