{* *************************
 * Tabs
 ************************* *}
<ul class="nav nav-tabs">
  <li class="active"><a href="#numbers" data-toggle="tab">Chiffres</a></li>
  <li><a href="#graphs" data-toggle="tab">Graphiques</a></li>
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
							<th>Précision</th>
						</tr>
					</thead>
					<tbody>
						{foreach $recipe.transport as $fsname=>$transport}
							{foreach $transport as $tr}
								<tr>
									{if $tr@index == 0}
										<td rowspan="{$transport|sizeof}">
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
									{if ($tr.location == 'Précise' && $tr@index == 0) || ($tr.location != 'Précise')}
									<td rowspan="{$transport|sizeof}">
										{$tr.location}
									</td>
									{/if}
								</tr>
							{/foreach}
						{/foreach}
					</tbody>
				</table>



	</div>

	<div class="tab-pane" id="graphs">
	</div>

	<div class="tab-pane" id="goomap">
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

