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

		<div style="margin: 15px 0 20px 0px; font-size: 16px">
			<div>Nombre de convives: <strong>{$menu.eaters}</strong></div>
			<div>Empreinte écologique foncière pour une personne: <strong>{$menu.footprint}</strong> m²g</div>
			<div>Empreinte écologique foncière pour {$menu.eaters} personne{if $menu.eaters > 1}s{/if}: <strong>{math equation="x * y" x=$menu.eaters y=$menu.footprint}</strong> m²g</div>
		</div>

		{foreach $menu.recipesList as $recipe}
			<div style="margin: 0 0 20px 0px">
				<div style="font-size: 18px">
					{$recipe.portions}
					<strong>
						<a href="/recette/analyse/resume/{$recipe.id}" target="_blank">{$recipe.label}</a> <span style="font-size: 14px">({$recipe.footprint} m²g par personne)</span>
					</strong>
				</div>
				<div>
					{foreach $recipe.foodstuffList as $fs}
					<div>
						{assign var='label' value=\mod\repasrc\Recipe::getFoodstuffLabel($fs)}
						<div style="font-size: 12px">
							- {$fs.quantity} {$fs.unit}
							<strong>
								{$label}
							</strong>
						</div>
					</div>
				{/foreach}
				</div>
			</div>
		{/foreach}

		{if !empty($menu.comment)}
			<h2>Remarques</h2>
			<div style="margin-top:10px">
				{$menu.comment|nl2br}
			</div>
		{/if}
		<h4>
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
					var dataPie = new google.visualization.DataTable({$dataFootprintPie});
					var dataCol = new google.visualization.DataTable({$dataFootprintCol});

					var optionsPie = { 
						'title':'Empreinte écologique foncière pour le menu',
						'width':800,
						'height':400,
						'fontSize' : 11
					};

					var optionsCol = { 
						'title':'Empreinte écologique foncière pour le menu',
						'width':800,
						'height':400, 
						'fontSize' : 11,
						'vAxis' : { format : '#.### m²g/Kg'},
					};

					var chart = new google.visualization.PieChart(document.getElementById('chart_div'));
					var chart2 = new google.visualization.ColumnChart(document.getElementById('chart_div2'));
					chart.draw(dataPie, optionsPie);
					chart2.draw(dataCol, optionsCol);
			}
			</script>

			<div id="chart_div"></div>
      {if empty($oldbrower)}
      <div style="width:200px;margin:0 auto 0 auto">
        <a href="javascript:void(0)" onclick="saveAsImg('chart_div', '{$menu.label} - Empreinte écologique foncière pour le menu')">Enregistrer le graphique</a>
      </div>
      {else}
        <div class="help" code="navigateurimpressionimpossible"></div>
      {/if}
      <br /><br /><hr>
			<div id="chart_div2"></div>
      {if empty($oldbrower)}
      <div style="width:200px;margin:0 auto 0 auto">
        <a href="javascript:void(0)" onclick="saveAsImg('chart_div2', '{$menu.label} - Empreinte écologique foncière pour le menu')">Enregistrer le graphique</a>
      </div>
      {else}
        <div class="help" code="navigateurimpressionimpossible"></div>
      {/if}

		</div>

</div>