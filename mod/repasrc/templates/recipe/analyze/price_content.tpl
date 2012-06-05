
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

		<div style="margin: 15px 0 20px 0px; font-size: 16px">
			{if isset($recipe.totalPrice.vatin) && !empty($recipe.totalPrice.vatin)}	
				<div style="margin:10px 0">Montant total pour les aliments renseignés en prix TTC: <strong>{$recipe.totalPrice.vatin} €/Kg</strong></div>
			{/if}
			{if isset($recipe.totalPrice.vatout) && !empty($recipe.totalPrice.vatout)}	
				<div style="margin:10px 0">Montant total pour les aliments renseignés en prix HT: <strong>{$recipe.totalPrice.vatout} €/Kg</strong></div>
			{/if}
			{if isset($recipe.price) && !empty($recipe.price)}	
				<div style="margin:10px 0 30px 0">Prix par personne défini pour la recette: <strong>{$recipe.price|print_r} €/Kg</strong></div>
			{/if}
		</div>

		<h3 style="margin:20px 0 10px 0">Prix par aliment</h3>

		<table class="table table-bordered">
			<thead>
				<tr>
					<th>Aliment</th>
					<th>Prix HT par Kilo</th>
					<th>Prix TTC par Kilo</th>
					<th>Prix pour la recette</th>
					<th>Prix par personne</th>
				</tr>
			</thead>
			<tbody>
			{foreach $recipe.foodstuffList as $fs}
				{if (isset($fs.foodstuff.synonym))}
					{assign var='label' value=$fs.foodstuff.synonym}
				{else}
					{assign var='label' value=$fs.foodstuff.label}
				{/if}
				<tr>
					<td>
						{$label}
					</td>
					<td>
						{if empty($fs.price)}
							-
						{else}
							{if empty($fs.vat)}
								{$fs.price} €/Kg
							{/if}
						{/if}
					</td>
					<td>
						{if empty($fs.price)}
							-
						{else}
							{if !empty($fs.vat)}
								{$fs.price} €/Kg
							{/if}
						{/if}
					</td>
					<td>
						{if empty($fs.price)}
							-
						{else}
							{math equation="x * y" x=$fs.price y=$fs.quantity} €
						{/if}
					</td>
					<td>
						{if empty($fs.price)}
							-
						{else}
								{math equation="x * (y/z)" x=$fs.price y=$fs.quantity z=$recipe.persons} €
						{/if}
					</td>
				</tr>
				{/foreach}
			</tbody>
		</table>

	</div>

	{* *************************
	 * Tab graphs
	 ************************* *}
			<div class="tab-pane" id="graphs">
				{if $noprice}
					<div class="alert alert-danger">
						Aucune information de prix a été renseignée pour les aliments composant la recette.
					</div>
				{else}

					<script type="text/javascript" src="https://www.google.com/jsapi"></script>
					<script type="text/javascript">

					google.load('visualization', '1.0', { 'packages':['corechart'] } );
					google.setOnLoadCallback(drawChart);

					function drawChart() {
							
							{if isset($dataFootprintCol1)}
								var dataCol1 = new google.visualization.DataTable({$dataFootprintCol1});

								var optionsCol1 = { 
									'title':'Prix des aliments HT (pour 1 personne)',
									'colors' : {$colors1},
									'width':800,
									'height':400 
								};

								var chart1 = new google.visualization.ColumnChart(document.getElementById('chart_div1'));
								chart1.draw(dataCol1, optionsCol1);
							{/if}
							
							{if isset($dataFootprintCol2)}
								var dataCol2 = new google.visualization.DataTable({$dataFootprintCol2});

								var optionsCol2 = { 
									'title':'Prix des aliments TTC (pour 1 personne)',
									'colors' : {$colors2},
									'width':800,
									'height':400 
								};

								var chart2 = new google.visualization.ColumnChart(document.getElementById('chart_div2'));
								chart2.draw(dataCol2, optionsCol2);
							{/if}
					}
					</script>

					<div id="chart_div1"></div>
					<div id="chart_div2"></div>
				{/if}

		</div>
