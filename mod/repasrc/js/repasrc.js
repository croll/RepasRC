//  -*- mode:js; tab-width:2; c-basic-offset:2; -*-

var modalWin;

window.addEvent('domready', function() { 
	
	Locale.use('fr-FR');

	modalWin = new Modal.Base(document.body, {
		header: "",
		body: "Chargement...",
		limitHeight: false
	});

});
