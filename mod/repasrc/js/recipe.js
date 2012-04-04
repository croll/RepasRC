window.addEvent('domready', function() {

	// Modules 
	if (typeOf(document.id('modules_container')) == 'element') {

		document.id('cancel').addEvent('click', function() {
				top.document.location.href='/recette/liste';
		});

		document.id('submit').addEvent('click', function(e) {
			e.stopPropagation();
			var modules = [];
			document.body.getElements('.checked').each(function(el) {
				modules.push(el.get('id'));
			});
			if (modules.length > 0) {
				document.id('modules_form').getElement('input[type=hidden]').set('value', modules.join(' '));
				document.id('modules_form').submit();
			} else {
				top.document.location.href='/recette/edition/informations';
			}
		});

		document.id('modules_container').getElements('li').each(function(el) {
			el.addEvents({
				click: function(){
					el.toggleClass('checked').tween('background-color','#87C6DB','#FFF');
				}
			});
		});
	}

	// Foodstuff
	if (typeOf(document.id('foodstuff_container')) == 'element') {

		document.id('subfamily').adopt(new Element('option').set('value', '').set('html', 'Sous famille de produit'));

		loadFamilies();
		loadSubFamilies();
		loadFoodstuff();

		document.id('family').addEvent('change', function() {
				document.id('fsname').set('value', '');
				var val = this.get('value');
				if (val != '') {
					document.id('subfamily').empty().adopt(new Element('option').set('value', '').set('html', 'Sous famille de produit'));
					loadFoodstuff();
					loadSubFamilies(val);
				} else {
					loadFoodstuff(true);
				}
		});

		document.id('subfamily').addEvent('change', function() {
				document.id('fsname').set('value', '');
				loadFoodstuff();
		});

		document.id('fsname').addEvent('keyup', function(e) {
				if (e.key == 'enter') {
					e.stop();
					e.stopPropagation();
					return;
				}
				filterResults(this.get('value'));
		});

	}
});

function loadFamilies() {
	var num = null;
	var el = document.id('family').getElement('option:selected');
	if (typeOf(el) == 'element') {
		num = el.get('value');
	}
	var userList = new Request.JSON({
			'url': '/ajax/call/repasrc/getFamilies',
			'onSuccess': function(res) {
				select = $('family');
				select.empty();
				select.adopt(new Element('option').set('value', '').set('html', 'Famille de produit'));
				res.each(function(f) {
					select.adopt(new Element('option').set('value', f.id).set('html', f.label));
				});
			}
  }).send();
}

function loadSubFamilies(num) {
	if (num == undefined) num = null;
	var userList = new Request.JSON({
			'url': '/ajax/call/repasrc/getSubFamilies',
			'onSuccess': function(res) {
				res.each(function(f) {
					document.id('subfamily').adopt(new Element('option').set('value', f.id).set('html', f.label));
				});
			}
  }).post({id: num});
}

function loadFoodstuff(reset) {
	var familyId = subFamilyId = null;
	if (reset != true) {
		var familySelected = document.id('family').getElement('option:selected');
		if (typeOf(familySelected) == 'element') {
			familyId = familySelected.get('value');
		}
		var subFamilySelected = document.id('subfamily').getElement('option:selected');
		if (typeOf(subFamilySelected) == 'element') {
			subFamilyId = subFamilySelected.get('value');
		}
	}
	var foodstuffList = new Request.JSON({
			'url': '/ajax/call/repasrc/searchFoodstuff',
			'onSuccess': function(res) {
				var container = document.body.getElement('.thumbnails');
				container.set('html', '');
				var html = '';
				// for each foodstuff
				Object.each(res, function(fs) {
					html += buildThumb(fs);
				});
				container.set('html', html);
			}
  }).post({familyId: familyId, subFamilyId: subFamilyId});
}

function filterResults(txt) {
	var els = document.body.getElements('.result') || null;
	if (els) {
		els.each(function(el) {
			if (el.getElement('.name').get('html').indexOf(txt) == -1) {
				el.setStyle('display', 'none');
			} else {
				el.setStyle('display', 'block');
			}
		});
	}
}

function buildThumb(fs) {
	if (typeOf(fs.synonym_id) == 'number') {
		var imgId = 's'+fs.synonym_id;
		var name = fs.synonym;
	} else {
		var imgId = fs.foodstuff_id;
		var name = fs.label;
	}
	html = '<li class="span5 result" style="width: 550px"><div class="thumbnail">';
	html+= '<ul style="margin:0">';
	html+= '<li class="span2" style="margin: 0"><img style="height:100px" src="/mod/repasrc/foodstuffImg/'+imgId+'.jpg" alt /></li>';
	html+= '<li class="span3" style="margin: 0;padding:5px 0 0 10px">';
		html+= '<div><h3 class="name">'+name+'</h3></div>';
		if (typeOf(fs.infos) == 'array') {
			html += '<div>';
			fs.infos.each(function(info) {
				html += '<span class="badge fam'+info.family_group_id+'" style="margin: 0px 5px 0 0">'+info.family_group+'</span>';
			});
			html += '</div>';
		}
		html += '<dl class="dl-horizontal"><dt style="width:235px">Empreinte écologique foncière:</dt><dd style="margin-left: 240px">'+Math.round(fs.footprint,3)+'&nbsp;gha</dd></dl>';
		if (fs.synonym) {
			html += '<dl class="alert dl-horizontal" style="width:300px"><dt style="width:70px">Basé sur:</dt><dd style="margin-left: 75px">'+fs.label+'</dd></dl>';
		}
		if (fs.conservation) {
		html += '<dl class="dl-horizontal"><dt>Mode de conservation</dt><dd>'+fs.conservation+'</dd></dl>';
		}
		if (fs.production) {
			html += '<dl class="dl-horizontal"><dt>Mode de production</dt><dd>'+fs.production+'</dd></dl>';
		}
	html+= '</li>';
	html+= '<div class="clearfix"></div>';
	html += '</ul></div></li>';
	return html;
}
