{if empty($oldbrowser)}
    <script type="text/javascript" src="http://canvg.googlecode.com/svn/trunk/rgbcolor.js"></script> 
    <script type="text/javascript" src="http://canvg.googlecode.com/svn/trunk/canvg.js"></script>
{/if}
<div class="help" code="analysedelarecetteempreintefonciere"></div>
{* *************************
 * Tabs
 ************************* *}
<ul class="nav nav-tabs">
	<li class="active"><a href="#numbers" data-toggle="tab">Chiffres</a></li>
	<li><a href="#graphs" data-toggle="tab">Graphiques</a></li>
</ul>

<div class="tab-content">
{* *************************
 * Tab datas
 ************************* *}
	<div class="tab-pane active" id="numbers">
		<div class="help" code="analysedelarecetteempreintefoncierechiffres"></div>
		<h2 style="margin-bottom: 3px">{$recipe.label|ucfirst}</h2>

		<div style="margin: 15px 0 20px 0px; font-size: 16px">
			<div>Empreinte écologique foncière pour une personne: <strong>{$recipe.footprint}</strong> m²g</div>
			<div>Empreinte écologique foncière pour {$recipe.persons} personne{if $recipe.persons > 1}s{/if}: <strong>{math equation="x * y" x=$recipe.persons y=$recipe.footprint}</strong> m²g</div>
			<div style="margin-top:5px;font-size:12px">Composante: <strong>{$recipe.component}</strong></div>
			<div style="font-size:12px">Nombre de convives: <strong>{$recipe.persons}</strong></div>
		</div>

		<hr></hr>

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
					{if !empty($fs.foodstuff.footprint)}
						<div>Empreinte écologique foncière pour un kilo: <b>{$fs.foodstuff.footprint|round:3} m²g/Kg</b></div>
						<div style="margin-bottom:5px">Empreinte écologique foncière pour une personne: <b>{math equation="round(x * (y/z),3)" x=$fs.foodstuff.footprint y=$fs.quantity z=$recipe.persons|round:3} m²g</b></div>
					{/if}
					{if (!empty($fs.conservation))}
						<div style="font-size:12px">Mode de conservation: <b>{$fs.conservation_label}</b></div>
					{/if}
					{if (!empty($fs.production))}
						<div style="font-size:12px">Mode de production: <b>{$fs.production_label}</b></div>
					{/if}
					{if (isset($fs.origin) && !empty($fs.origin.0.zonelabel))}
						<div style="font-size:12px">Provenance: <b>{$fs.origin.0.zonelabel}</b></div>
					{else if (isset($fs.origin) && !empty($fs.origin.0.location))} 
						{if $fs.origin.0.location == 'LOCAL'}
							<div style="font-size:12px">Provenance: <b>Locale</b></div>
						{else if $fs.origin.0.location == 'REGIONAL'}
							<div style="font-size:12px">Provenance: <b>Locale</b></div>
						{else if $fs.origin.0.location == 'FRANCE'}
							<div style="font-size:12px">Provenance: <b>France</b></div>
						{else if $fs.origin.0.location == 'EUROPE'}
							<div style="font-size:12px">Provenance: <b>Europe</b></div>
						{else if $fs.origin.0.location == 'WORLD'}
							<div style="font-size:12px">Provenance: <b>Monde</b></div>
						{/if}
					{/if}
					{if (isset($fs.price) && !empty($fs.price))}
						<div style="font-size:12px">Prix: <b>{$fs.price} {if $fs.vat == 0}HT{else}TTC{/if}</b></div>
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
			<div class="help" code="analysedelarecetteempreintefoncieregraphiques"></div>
			<h2 style="margin-bottom: 3px">{$recipe.label|ucfirst}</h2>
		
			{if sizeof($noData) > 0}
				<div class='alert alert-danger'>
					<h5>Liste des aliments dont on ne connait pas l'empreinte écologique:</h5>
					<ul style="margin: 5px 0 10px 20px">
					{foreach $noData as $nd}
						<li style="font-weight: bold">{$nd}</li>
					{/foreach}
					</ul>
					De fait, ils ne sont pas pris en compte dans les graphiques ci-dessous, pourtant leur impact est bien sûr réel.
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
						'isStacked': true
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
			{if empty($oldbrower)}
			<div style="width:200px;margin:0 auto 0 auto">
				<a href="javascript:void(0)" onclick="saveAsImg('chart_div', '{$recipe.label} - Empreinte écologique foncière par aliment')">Enregistrer le graphique</a>
			</div>
			{else}
				<div class="help" code="navigateurimpressionimpossible"></div>
			{/if}
			<hr>

			
			<div id="chart_div2"></div>
			{if empty($oldbrower)}
			<div style="width:200px;margin:0 auto 0 auto">
				<a href="javascript:void(0)" onclick="saveAsImg('chart_div2', '{$recipe.label} - Empreinte écologique foncière par aliment (pour une personne)')">Enregistrer le graphique</a>
			</div>
			{else}
				<div class="help" code="navigateurimpressionimpossible"></div>
			{/if}
			<hr>
			
			<div id="chart_div3"></div>
			{if empty($oldbrower)}
			<div style="width:200px;margin:0 auto 0 auto">
				<a href="javascript:void(0)" onclick="saveAsImg('chart_div3', '{$recipe.label} - Relation empreinte foncière et quantité d\'aliment')">Enregistrer le graphique</a>
			</div>
			{else}
				<div class="help" code="navigateurimpressionimpossible"></div>
			{/if}

		</div>

</div>
