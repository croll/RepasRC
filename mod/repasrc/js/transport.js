var infowindow = new google.maps.InfoWindow();
var bounds = new google.maps.LatLngBounds();
var markers = {}
var lines = {};

function geocode(datas, l) {
	lines = l;
	var geocoder = new google.maps.Geocoder();
	var numTodo = Object.getLength(datas);
	// Geocode
	Object.each(datas, function(fsList, name) {
		geocoder.geocode({address: name}, function(result, status) {
			--numTodo;
			if (status == google.maps.GeocoderStatus.OK) {
				markers[name] = {
					'location': result[0].geometry.location,
					'fsList' : fsList
				};
				bounds.extend(result[0].geometry.location)
				if (numTodo == 0) {
					drawMarkers();
				}
			}
		});
	});
}

function drawMarkers() {
	Object.each(markers, function(datas, name) {
		var marker = new google.maps.Marker({
			position: datas.location,
			map: map
		});
		google.maps.event.addListener(marker, 'mouseover', function() {
			if (infowindow) {
				infowindow.close();
			}
			var content = '';
			content += '<h3>'+name+'</h3>';
			content += '<div><b>Aliment(s):</b></div>';
			datas.fsList.each(function(fs) {
				content += '<div>- '+fs.label+'</div>';
			});
			infowindow.setContent(content);
			infowindow.open(map, marker);
		});
	});
	drawLines();
}

function drawLines() {
	colors = ['#FF0000', '#00FF00', '#0000FF', '#000000', '#FFFF00', '#FF00FF', '#00FFFF', '#FFFFFF'];  
	var i = 0;
	lines.each(function(line) {
		var coords = [];
		line.each(function(cityName) {
			coords.push(markers[cityName].location);
		});
		var lPath = new google.maps.Polyline({
			path: coords,
			strokeColor: colors[i],
			strokeOpacity: 1.0,
			strokeWeight: 2
		});
		lPath.setMap(map);
		i++;
		if (i > 7) i= 0;
	});
	map.fitBounds(bounds);

}
