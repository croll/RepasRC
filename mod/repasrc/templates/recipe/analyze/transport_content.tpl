{* *************************
 * Tabs
 ************************* *}
<ul class="nav nav-tabs">
  <li class="active"><a href="#numbers" data-toggle="tab">Informations</a></li>
  <li><a href="#goomap" data-toggle="tab">Cartographie</a></li>
</ul>

<div class="tab-content">

	<h2 style="margin-bottom: 3px">{$recipe.label|ucfirst}</h2>
{* *************************
 * Tab datas
 ************************* *}
	<div class="tab-pane active" id="numbers">

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
						{foreach $recipe.transport as $fsname=>$transport}
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
										{if !empty($tr.carbon)}
											{$tr.carbon} m²g
										{/if}
									</td>
									{if ($tr.location == 'LETMECHOOSE' && $tr@index == 0) || ($tr.location != 'LETMECHOOSE')}
										<td rowspan="{$transport.origin|sizeof}">
										{$tr.location_label}
										</td>
									{/if}
								</tr>
							{/foreach}
						{/foreach}
					</tbody>
				</table>



	</div>

{* *************************
 * Tab graphs 
 ************************* *}
	<div class="tab-pane" id="graphs">
	</div>

{* *************************
 * Tab map 
 ************************* *}
	<div class="tab-pane" id="goomap">
		<div class="alert alert-warn">
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
						geocode({$recipe.markers|json_encode}, {$recipe.lines|json_encode});
				});

		});
		</script>
		<div id="map_canvas" style="border:1px solid #ccc;width: 870px;height:450px">
		</div>
	</div>

</div>

