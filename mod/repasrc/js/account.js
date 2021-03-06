window.addEvent('domready', function() {
	var myAutocomplete = new Meio.Autocomplete($('city'), '/ajax/call/repasrc/getCities', {
			minChars: 3,
			filter: {
				type: 'contains',
				path: 'label_caps'
			},
			onNoItemToList: function(elements){
				elements.field.node.highlight('#ff5858');
			},
			onSelect: function(elements, value) {
				$('city').set('value', '');
				$('zonelabel').set('value', value.label);
				$('zoneid').set('value', value.id);
			}
		});
		$('city').addEvent('onchange', function() {
			$('zonelabel').set('value', '');
			$('zoneid').set('value', '');
		});

		$('cancel').addEvent('click', function() {
			document.location.href='/';
		});
});
