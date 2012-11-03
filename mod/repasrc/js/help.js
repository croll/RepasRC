function processHelp(c) {

			var message, code, loc, informations, alertType, i, container, tmp;
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
			var pop;
			container.getElements('.help').each(function(el) {
				code = el.get('code');
					loc = el.get('location') || 'right';
					message = helpMessages[code];
					if (message.type == '?' || message.type == '!') {
						if (message.type == '?')	{
							icon = 'icon-question-sign';
						} else {
							icon = 'icon-informations';
						}
						if (el.get('tag') == 'div' || el.get('tag') == 'i') {
							tmp = new Element('i', {'class': 'customhelp help icon-question-sign '+icon, code: code, 'style': 'margin: 1px 5px 0px 0px', 'location': loc, 'rel': 'popover', 'msg': message.message}).inject(el.getPrevious(), 'after');
							el.dispose();
							el = tmp;
						} else {
							el.set('msg', message.message).removeClass('help');
						}
						pop = new Bootstrap.Popover(el, {
							location: loc,
							getContent: function(elem) {
								return elem.get('msg');
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
						el.addClass('customhelp alert '+alertType).removeClass('help');
						el.set('html', el.get('html')+message.message);
					} else if (message.type.indexOf('form') != -1) {
						var p = new Element('p', {'class': 'customhelp hint', 'html': message.message});
						p.inject(el.getPrevious(), 'after');
						el.dispose();
					} else if (message.type.indexOf('imple')) {
						el.addClass('customhelp hint').removeClass('help');
					}
					if (displayHelp === 0) {
						if ((typeOf(i) == 'element') && !i.hasClass('btn') && !el.hasClass('badge')) {
							i.setStyle('display', 'none');
						}
						if ((typeOf(el) == 'element') && !el.hasClass('btn') && !el.hasClass('badge')) {
							el.setStyle('display', 'none');
						}
					}
					helpDone.push(pop);
			});
			// show / hide popover
			if (displayHelp == 0) {
				helpDone.each(function(pop) {
					if (displayHelp == 0) {
						if (typeOf(pop) == 'object')
							pop.disable();
					}
				});
			}
			CaptainHook.Bootstrap.initAlerts();
}

function toggleHelp() {
	if (displayHelp == 1) {
		document.id('helpToggler').set('html', 'Afficher l\'aide et les explications');
		$$('.customhelp').each(function(el) {
			el.setStyle('display', 'none');
		});
		displayHelp = 0;
		// show / hide popover
		helpDone.each(function(pop) {
			if (displayHelp == 0) {
				if (typeOf(pop) == 'object')
					pop.disable();
			}
		});
	} else {
		document.id('helpToggler').set('html', 'Masquer l\'aide et les explications');
		displayHelp = 1;
		processHelp();
		$$('.customhelp').each(function(el) {
			var t = (el.get('tag') == 'div') ? 'block' : 'inline-block';
			el.setStyle('display', t);
		});
	}
	var jsonRequest = new Request.JSON({
		'url': '/ajax/call/repasrc/setHelpVisibility',
	}).post({'displayHelp': displayHelp});
}

var helpMessages;
var helpDone = [];

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
