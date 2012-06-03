
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
			<div>Composante: <strong>{$recipe.component}</strong></div>
			<div>Nombre de convives: <strong>{$recipe.persons}</strong></div>
			<div>Empreinte écologique foncière: <strong>{$recipe.footprint}</strong> m²g</div>
		</div>

		{foreach $recipe.foodstuffList as $fs}
			{if (isset($fs.foodstuff.synonym))}
				{assign var='label' value=$fs.foodstuff.synonym}
			{else}
				{assign var='label' value=$fs.foodstuff.label}
			{/if}
			<div style="margin: 0 0 20px 0px">
				<div style="font-size: 18px">
					{$fs.quantity} {$fs.unit}
					<strong>
						{$label}
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
					{if !empty($fs.foodstuff.footprint)}
						<div>Empreinte écologique foncière: <strong>{$fs.foodstuff.footprint} m²g/Kg</strong></div>
						<div>Empreinte écologique foncière pour la recette: <strong>{math equation="x * y" x=$fs.foodstuff.footprint y=$fs.quantity} m²g</strong></div>
					{/if}
					{if (isset($fs.origin) && !empty($fs.origin.0.zonelabel))}
						<div>Origine: <strong>{$fs.origin.0.zonelabel}</strong></div>
					{else if (isset($fs.origin) && !empty($fs.origin.0.location))} 
						{if $fs.origin.0.location == 'LOCAL'}
							<div>Origine: <strong>Locale</strong></div>
						{else if $fs.origin.0.location == 'REGIONAL'}
							<div>Origine: <strong>Locale</strong></div>
						{else if $fs.origin.0.location == 'FRANCE'}
							<div>Origine: <strong>France</strong></div>
						{else if $fs.origin.0.location == 'EUROPE'}
							<div>Origine: <strong>Europe</strong></div>
						{else if $fs.origin.0.location == 'WORLD'}
							<div>Origine: <strong>Monde</strong></div>
						{/if}
					{/if}
					{if (isset($fs.price) && !empty($fs.price))}
						<div>Prix: <strong>{$fs.price} {if $fs.vat == 0}HT{else}TTC{/if}</strong></div>
					{/if}

					{if empty($fs.foodstuff.footprint)}
						<div class="alert alert-danger">
							{if empty($fs.foodstuff.comment)}
								Attention, nous ne connaissons pas aujourd'hui l'empreinte écologique de cet aliment. Nous vous indiquerons la proportion d'aliments de votre recette dont nous ne connaissons pas l'empreinte.
							{else}
								{$fs.foodstuff.comment}
							{/if}
						</div>
					{/if}

					{if ($info.family_group == 'Fruits' || $info.family_group == 'Légumes') && $fs.foodstuff.seasonality}
					<div style="margin-top:10px">Saisonnalité: <span></span></div>
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

				</div>
			</div>
		{/foreach}

		{if !empty($recipe.comment)}
			<h2>Remarques</h2>
			<div style="margin-top:10px">
				{$recipe.comment}
			</div>
		{/if}
		<h4>
	</div>

	{* *************************
	 * Tab graphs
	 ************************* *}
		<div class="tab-pane" id="graphs">
		
			{if sizeof($noData) > 0}
				<div class='alert alert-danger'>
					<h5>Liste des aliments dont on ne connait pas l'empreinte écologique:</h5>
					<ul style="margin: 5px 0 10px 20px">
					{foreach $noData as $nd}
						<li style="font-weight: bold">{$nd}</li>
					{/foreach}
					</ul>
					De fait, ils ne sont pas pris en compte dans les graphiques suivant, pourtant leur impact est bien sûr réel.
				</div>
			{/if}

			<script type="text/javascript" src="https://www.google.com/jsapi"></script>
			<script type="text/javascript">

			google.load('visualization', '1.0', { 'packages':['corechart'] } );
			google.setOnLoadCallback(drawChart);

			function drawChart() {
					var dataPie = new google.visualization.DataTable({$dataFootprintPie});
					var dataCol = new google.visualization.DataTable({$dataFootprintCol});
					var dataComp = new google.visualization.DataTable({$dataFootprintComp});

					var optionsPie = { 
						'title':'Empreinte écologique foncière par aliment',
						'colors' : {$colors},
						'width':800,
						'height':400 
					};

					var optionsCol = { 
						'title':'Empreinte écologique foncière par aliment (Pour 1 personne)',
						'colors' : {$colors},
						'width':800,
						'height':400 
					};

					var optionsComp = { 
						'title':'Relation entre  l\'empreinte écologique foncière et la quantité d\'aliment (Pourcentage)',
						'width':800,
						'height':400,
						'isStacked':false
					};

					var chart = new google.visualization.PieChart(document.getElementById('chart_div'));
					var chart2 = new google.visualization.ColumnChart(document.getElementById('chart_div2'));
					var chart3 = new google.visualization.SteppedAreaChart(document.getElementById('chart_div3'));
					chart.draw(dataPie, optionsPie);
					chart2.draw(dataCol, optionsCol);
					chart3.draw(dataComp, optionsComp);
			}
			</script>

			<div id="chart_div"></div>
			<div id="chart_div2"></div>
			<div id="chart_div3"></div>

		</div>
