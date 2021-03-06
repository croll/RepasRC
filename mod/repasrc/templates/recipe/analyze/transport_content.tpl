{if empty($oldbrowser)}
    <script type="text/javascript" src="http://canvg.googlecode.com/svn/trunk/rgbcolor.js"></script> 
    <script type="text/javascript" src="http://canvg.googlecode.com/svn/trunk/canvg.js"></script>
{/if}
{* *************************
 * Tabs
 ************************* *}
<ul class="nav nav-tabs">
  <li class="active"><a href="#numbers" data-toggle="tab">Informations</a></li>
  <li><a href="#graphs" data-toggle="tab">Graphiques</a></li>
  <li><a href="#goomap" data-toggle="tab">Cartographie</a></li>
</ul>

<div class="tab-content">

	<h2 style="margin-bottom: 3px">{$recipe.label|ucfirst}</h2>
{* *************************
 * Tab datas
 ************************* *}
	<div class="tab-pane active" id="numbers">
				{if isset($recipe.transport.total.distance) && ($recipe.transport.total.distance > 0)}
					<h5 style="margin:5px 0 5px 0">Distance totale parcourue par les aliments: {$recipe.transport.total.distance} Km</h5>
					<h5>Empreinte écologique du transport pour la recette pour le service: {$recipe.transport.total.footprint|round:3} m²g</h5>
				{/if}
				{if sizeof($recipe.transport.datas) > 0}
				<h3 style="margin:20px 0 10px 0">Provenance des aliments</h3>
				<table class="table table-bordered">
					<thead>
						<tr>
							<th>Aliment</th>
							<th>Origine et étapes</th>
							<th>Distance parcourue</th>
							<th>Empreinte du transport</th>
							<th>Précision</th>
						</tr>
					</thead>
					<tbody>
							{foreach $recipe.transport.datas as $fsname=>$transport}
								{foreach $transport.origin as $tr}
									<tr>
										{if $tr@index == 0}
											<td rowspan="{$transport.origin|sizeof}">
													{$fsname}
											</td>
										{/if}
										<td>
												{$tr.zonelabel}
										</td>
										<td>
											{if !empty($tr.distance)}
												{$tr.distance} Km
											{/if}
										</td>
										<td>
											{if !empty($tr.footprint)}
												{$tr.footprint|round:3} m²g
											{/if}
										</td>
										{if ($tr.location == 'LETMECHOOSE' && empty($tr@index)) || ($tr.location != 'LETMECHOOSE')}
											<td rowspan="{$transport.origin|sizeof}">
											{$tr.location_label}
											</td>
										{/if}
									</tr>
								{/foreach}
							{/foreach}
					</tbody>
				</table>
				<div class="help" code="commentaireanalyserecettetransport"></div>
			{/if}
			{if isset($recipe.transport.nodata) && sizeof($recipe.transport.nodata) > 0}
				<h4>Aliments dont l'origine est indéfinie</h4>
					{foreach $recipe.transport.nodata as $fsname}
						<div>- {$fsname}</div>
					{/foreach}
			{/if}
	</div>

{* *************************
 * Tab graphs 
 ************************* *}
	<div class="tab-pane" id="graphs">

			{if sizeof($recipe.transport.datas) == 0}
				<div class="alert alert-error">
					Aucune origine n'est définie.
				</div>
			{else}
				<script type="text/javascript" src="https://www.google.com/jsapi"></script>
				<script type="text/javascript">
				google.load('visualization', '1.0', { 'packages':['corechart'] } );
				google.setOnLoadCallback(drawChart);
				function drawChart() {
						var dataCol1 = new google.visualization.DataTable({$dataFootprintCol1});
						var dataCol2 = new google.visualization.DataTable({$dataFootprintCol2});
						var dataCol3 = new google.visualization.DataTable({$dataFootprintCol3});
						//var dataComp = new google.visualization.DataTable({$dataFootprintComp});
						var optionsCol1 = { 
							'title':'Distance parcourue par les aliments en Km',
							{if isset($colors)}
								'colors' : {$colors},
							{/if}
							'width':800,
							'height':400 
						};
						var optionsCol2 = { 
							'title':'Empreinte écologique des transports par aliment pour une portion',
							{if isset($colors)}
								'colors' : {$colors},
							{/if}
							'width':800,
							'height':400 
						};
						var optionsCol3 = { 
							'title':'Empreinte écologique des transports par aliment pour le service',
							{if isset($colors)}
								'colors' : {$colors},
							{/if}
							'width':800,
							'height':400 
						};
						/*
						var optionsComp = { 
							'title':'Relation entre la distance parcourue et l\'empreinte écologique des transports',
							'width':800,
							'height':400,
							'isStacked':false
						};
						*/
						var chart1 = new google.visualization.ColumnChart(document.getElementById('chart_div'));
						var chart2 = new google.visualization.ColumnChart(document.getElementById('chart_div2'));
						var chart3 = new google.visualization.ColumnChart(document.getElementById('chart_div3'));
						//var chart4 = new google.visualization.ColumnChart(document.getElementById('chart_div4'));
						chart1.draw(dataCol1, optionsCol1);
						chart2.draw(dataCol2, optionsCol2);
						chart3.draw(dataCol3, optionsCol3);
						//chart4.draw(dataComp, optionsComp);
				}
				</script>
				<div id="chart_div"></div>
				{if empty($oldbrower)}
				<div style="width:200px;margin:0 auto 0 auto">
					<a href="javascript:void(0)" onclick="saveAsImg('chart_div', '{$recipe.label} - Distance parcourue par les aliments en Km')">Enregistrer le graphique</a>
				</div>
				{else}
					<div class="help" code="navigateurimpressionimpossible"></div>
				{/if}

				<div id="chart_div2"></div>
				{if empty($oldbrower)}
				<div style="width:200px;margin:0 auto 0 auto">
					<a href="javascript:void(0)" onclick="saveAsImg('chart_div2', '{$recipe.label} - Empreinte écologique des transports par aliment pour une portion.')">Enregistrer le graphique</a>
				</div>
				{else}
					<div class="help" code="navigateurimpressionimpossible"></div>
				{/if}
				<div id="chart_div3"></div>
				{if empty($oldbrower)}
				<div style="width:200px;margin:0 auto 0 auto">
					<a href="javascript:void(0)" onclick="saveAsImg('chart_div3', '{$recipe.label} - Empreinte écologique des transports par aliment pour le service.')">Enregistrer le graphique</a>
				</div>
				{else}
					<div class="help" code="navigateurimpressionimpossible"></div>
				{/if}
				<!--
				<div id="chart_div4"></div>
				{if empty($oldbrower)}
				<div style="width:200px;margin:0 auto 0 auto">
					<a href="javascript:void(0)" onclick="saveAsImg('chart_div4', '{$recipe.label} - .')">Enregistrer le graphique</a>
				</div>
				{else}
					<div class="help" code="navigateurimpressionimpossible"></div>
				{/if}
				-->

			{/if}
	</div>

{* *************************
 * Tab map 
 ************************* *}
	<div class="tab-pane" id="goomap">
	{if sizeof($recipe.transport.datas) == 0}
		<div class="alert alert-error">
			Aucune origine n'est définie.
		</div>
	{else}
		<div class="alert alert-warn">
			<a class="close" data-dismiss="alert">×</a>
			La carte permet de visualiser les distances parcourues par les aliments. Pour cela l'origine des aliments doit être définie avec le plus de précision possible lors de la création de la recette.<br />
			En passant la souris sur un repère, une liste d'aliments est affichée. 
			Les aliments dont l'origine est vague ("Régionale", "France" ou "Internationale") sont affichés sur le repère de la RC. <br/>
			Dans le cas où l'origine est définie avec précision, chaque étape est représentée sur la carte et les aliments sont affichés dans la bulle d'information.
		</div>
		<script>
		var map;
		window.addEvent('domready', function() {
				map = new google.maps.Map($('map_canvas'), {
					disableDefaultUI: true,
					mapTypeId: google.maps.MapTypeId.TERRAIN,
					mapTypeControl: true,
					mapTypeControlOptions: {
							style: google.maps.MapTypeControlStyle.HORIZONTAL_BAR,
							position: google.maps.ControlPosition.TOP_RIGHT
					},
					zoomControl: true,
					zoomControlOptions: {
							style: google.maps.ZoomControlStyle.BIG,
							position: google.maps.ControlPosition.RIGHT_TOP
					},
					panControl: true,
					panControlOptions: {
							style: google.maps.ZoomControlStyle.BIG,
							position: google.maps.ControlPosition.RIGHT_TOP
					},
					scaleControl: true,
					scaleControlOptions: {
							position: google.maps.ControlPosition.BOTTOM_LEFT
					}
				});
			
				$('goomap').addEvent('show', function() {
				    google.maps.event.trigger(map, 'resize');
						geocode({$recipe.transport.markers|json_encode}, {$recipe.transport.lines|json_encode});
				});

		});
		</script>
		<div id="map_canvas" style="border:1px solid #ccc;width: 870px;height:450px">
		</div>
	{/if}
	</div>

</div>

