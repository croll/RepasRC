var map;
window.addEvent('domready', function() {

    /* initialization of google map */
    map = new google.maps.Map($('map_canvas'), {
			center: new google.maps.LatLng(48.114722, -1.679444),
	zoom: 9, 
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

		     google.maps.event.addListener(map, 'bounds_changed', function() {
		var bounds = map.getBounds();
		var southWest = bounds.getSouthWest();
		var northEast = bounds.getNorthEast();
		var lngSpan = northEast.lng() - southWest.lng();
		var latSpan = northEast.lat() - southWest.lat();
		for (var i = 0; i < 5; i++) {
			var latlng = new google.maps.LatLng(southWest.lat() + latSpan * Math.random(),
					southWest.lng() + lngSpan * Math.random());
				  var marker = new google.maps.Marker({
						      position: latlng,
									      map: map,
												      title:"RC"
															  });}
		      });
});
