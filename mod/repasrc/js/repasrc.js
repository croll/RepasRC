//  -*- mode:js; tab-width:2; c-basic-offset:2; -*-

var modalWin;
var spinner;

window.addEvent('domready', function() { 
	
	Locale.use('fr-FR');

	modalWin = new Modal.Base(document.body, {
		header: "",
		body: "Chargement...",
		limitHeight: false
	});

});

function showSpinner() {
  if (!spinner) {
    spinner = new Spinner({
      lines: 11, // The number of lines to draw
      length: 5, // The length of each line
      width: 2, // The line thickness
      radius: 6, // The radius of the inner circle
      corners: 1, // Corner roundness (0..1)
      rotate: 19, // The rotation offset
      color: '#fff', // #rgb or #rrggbb
      speed: 1, // Rounds per second
      trail: 59, // Afterglow percentage
      shadow: true, // Whether to render a shadow
      hwaccel: false, // Whether to use hardware acceleration
      className: 'repasspinner', // The CSS class to assign to the spinner
      zIndex: 2e9, // The z-index (defaults to 2000000000)
      top: 7, // Top position relative to parent in px
      left: -30 // Left position relative to parent in px
    })
    spinner.spin(document.id('spinnercontainer'));
  };
}

function hideSpinner() {
  spinner.stop();
}
