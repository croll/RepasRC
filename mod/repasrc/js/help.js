function processHelp(c) {

			var message, code, loc, informations, alertType, i, container;
			if (typeof(c) != 'undefined') {
				if (typeof(c) == 'string') {
					container = document.getElement(c);
				} else {
					container = c;
				}
			} else {
				container = document;
			}
			if (container === null) {
				console.log('No element found '+c);
				return;
			}
			container.getElements('.help').each(function(el) {
				loc = el.get('location') || 'right';
				message = helpMessages[el.get('code')];
				if (message.type == '?' || message.type == '!') {
				if (message.type == '?')	{
					icon = 'icon-question-sign';
				} else {
					icon = 'icon-informations';
				}
				if (el.get('tag') == 'div') {
					i = new Element('i', {'class': 'customhelp icon-question-sign '+icon, 'style': 'margin: 1px 5px 0px 0px', 'location': loc, 'rel': 'popover', 'msg': message.message}).inject(el.getPrevious(), 'after');
						el.dispose();
				} else {
					el.set('msg', message.message);
					i = el;
				}
				new Bootstrap.Popover(i, {
						location: loc,
						getContent: function(elem) {
							return elem.get('msg');
						},
						getTitle: function() {
							return 'Informations';
						},
						offset: 0
					});
				} else if (message.type.indexOf('adre') != -1) {
					switch(message.type.split(' ')[1]) {
						case 'jaune':
						alertType = 'alert-warn';
						break;
						case 'bleu':
						alertType = 'alert-info';
						break;
						case 'rouge':
						alertType = 'alert-error';
						break;
						case 'vert':
						alertType = 'alert-success';
						break;
					}
					el.adopt(new Element('a', {'class': 'close', 'data-dismiss': 'alert', 'html': 'x'}));
					el.addClass('customhelp alert '+alertType);
					el.set('html', el.get('html')+message.message);
				} else if (message.type.indexOf('form') != -1) {
					var p = new Element('p', {'class': 'customhelp help-block', 'html': message.message});
					p.inject(el.getPrevious(), 'after');
					el.dispose();
				} else if (message.type.indexOf('imple')) {
					el.addClass('customhelp hint');
				}
				if (displayHelp === 0) {
					if (typeOf(i) == 'element')
						i.setStyle('display', 'none');
					if (typeOf(el) == 'element')
					el.setStyle('display', 'none');
				}
			});
}

function toggleHelp() {
	if (displayHelp == 1) {
		document.id('helpToggler').set('html', 'Afficher l\'aide et les explications');
		$$('.customhelp').each(function(el) {
			el.setStyle('display', 'none');
		});
		displayHelp = 0;
	} else {
		document.id('helpToggler').set('html', 'Masquer l\'aide et les explications');
		$$('.customhelp').each(function(el) {
			var t = (el.get('tag') == 'div') ? 'block' : 'inline-block';
			el.setStyle('display', t);
		});
		displayHelp = 1;
	}
	var jsonRequest = new Request.JSON({
   'url': '/ajax/call/repasrc/setHelpVisibility',
	}).post({'displayHelp': displayHelp});
}

var helpMessages;

document.addEvent('domready', function() {
	var jsonRequest = new Request.JSON({
		url: '/mod/repasrc/messages.json',
		onSuccess: function(messages) {
			helpMessages = messages;
			processHelp();
		},
		onError: function(error) {
			console.log('Erreur lors de la recuperation des messages.');
			console.log(error);
		}
	}).get();
});
