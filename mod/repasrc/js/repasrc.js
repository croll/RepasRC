//  -*- mode:js; tab-width:2; c-basic-offset:2; -*-

var modadWin = new Modal.Base(document.body);

window.addEvent('domready', function() {
		var els = document.body.getElements('div.alert .close') || undefined;
		if (els) {
			els.each(function(el) {
				el.addEvent('click', function() {
					this.getParent().setStyle('display', 'none');
				});
			});
		}
});
