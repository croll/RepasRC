window.addEvent('domready', function() {
		Locale.use('fr-FR');

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
				$('modules').set('value', modules.join(' '));
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

	// Informations
	if (typeOf(document.id('informations_container')) == 'element') {
		var myMooDatePicker = new MooDatePicker(document.getElement('input[name=consumptiondate]'), {
			onPick: function(date){
				this.element.set('value', date.format('%e/%m/%Y'));
			}
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

	if (typeOf(document.id('recipe_search_form')) == 'element') {

		loadRecipes();

		document.id('type').addEvent('change', function() {
			document.id('label').set('value', '');
			document.id('fsname').set('value', '');
			var val = this.get('value');
			if (val != '') {
				loadRecipes();
			}
		});

		document.id('component').addEvent('change', function() {
			document.id('label').set('value', '');
			document.id('fsname').set('value', '');
			var val = this.get('value');
			if (val != '') {
				loadRecipes();
			}
		});

		document.id('label').addEvent('keyup', function(e) {
			if (e.key == 'enter') {
				e.stop();
				e.stopPropagation();
				return;
			}
			filterResults(this.get('value'));
		});

		document.id('fsname').addEvent('keyup', function(e) {
				if (e.key == 'enter') {
					e.stop();
					e.stopPropagation();
					return;
				}
				filterResults(this.get('value'), 'fsname');
		});
	}

	// List

});

/* ----------------------------------
 * Remotely get families of foodstuff
 *
 * --------------------------------- */
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

/* --------------------------------------
 * Remotely get sub families of foodstuff
 * @num : Parent family id
 * ------------------------------------ */
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

/* ----------------------------------------------
 * Retrieve a list of foodstuff 
 * @reset: Reset families and sub families selects
 * ---------------------------------------------- */
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
					html += buildFoodstuffThumb(fs);
				});
				container.set('html', html);
			}
  }).post({familyId: familyId, subFamilyId: subFamilyId});
}

/* ---------------------------------------------------------------------
 * Hide result not matching criterias in foodstuff list
 * @txt: value of filter
 * @type: type of filter (name, familie, etc) equal to element class name
 * --------------------------------------------------------------------- */
function filterResults(txt, type) {
	t = type || 'name';
	var els = document.body.getElements('.result') || null;
	if (els) {
		els.each(function(el) {
			if (el.getElement('.'+t).get('html').indexOf(txt) == -1) {
				el.setStyle('display', 'none');
			} else {
				el.setStyle('display', 'block');
			}
		});
	}
}

/* -------------------------------------------------
 * Build foodstuff tiny block with image, fs name, etc  
 * multiple occurences build the foodstuff list
 * @fs: foodstuff object 
 * ---------------------------------------------- */
function buildFoodstuffThumb(fs) {
	if (typeOf(fs.synonym_id) == 'number') {
		var imgId = 's'+fs.synonym_id;
		var name = fs.synonym;
	} else {
		fs.synonym_id = null;
		var imgId = fs.id;
		var name = fs.label;
	}
	html = '<li onclick="showFoodstuffDetail('+fs.id+', '+fs.synonym_id+')" class="span5 result" style="width: 550px"><div class="thumbnail">';
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

/* ----------------------------------------------
 * Remotely get list of recipes 
 * @reset: reset filter search select
 * ---------------------------------------------- */
function loadRecipes(reset) {
	var typeId = componentId = null;
	if (reset != true) {
		var typeSelected = document.id('type').getElement('option:selected');
		if (typeOf(typeSelected) == 'element') {
			typeId = typeSelected.get('value');
		}
		var componentSelected = document.id('component').getElement('option:selected');
		if (typeOf(componentSelected) == 'element') {
			componentId = componentSelected.get('value');
		}
	}
	var foodstuffList = new Request.JSON({
			'url': '/ajax/call/repasrc/searchRecipe',
			'onSuccess': function(res) {
				var container = document.body.getElement('.thumbnails');
				container.set('html', '');
				var html = '';
				// for each recipe 
				Object.each(res, function(re) {
					html += buildRecipeThumb(re);
				});
				container.set('html', html);
			}
  }).post({typeId: typeId, componentId: componentId});
}

/* -------------------------------------------------
 * Build recipe tiny block with image, name, etc  
 * multiple occurences build the recipe list
 * @re: recipe object 
 * ---------------------------------------------- */
function buildRecipeThumb(re) {
	html = '<li onclick="showRecipeDetail('+re.id+')" class="span5 result" style="width: 550px;cursor:pointer"><div class="thumbnail">';
	html+= '<ul style="margin:0">';
	html+= '<li class="span" style="margin: 0"><img style="height:110px" src="/mod/repasrc/foodstuffImg/'+'TODO'+'.jpg" alt /></li>';
	html+= '<li class="span4" style="margin: 0;padding:5px 0 0 10px">';
	html+= '<div><h3 class="name">'+re.label+'</h3></div>';
	html+= '<span style="display:none" class="fsname">'+re.foodstuff.join('')+'</span>';
	if (typeOf(re.families) == 'array') {
		html += '<div>';
		re.families.each(function(fam) {
			info = fam.split('_');

			html += '<span class="badge fam'+info[0]+'" style="margin: 0px 5px 0 0">'+info[1]+'</span>';
		});
		html += '</div>';
	}
  html += '<dl class="dl-horizontal" style="height: 12px"><dt>Composante:</dt><dd>'+re.component+'</dd></dl>';
	html += '<dl class="dl-horizontal" style="height: 12px" style="margin:0px" style=""><dt>Empreinte écologique foncière:</dt><dd">'+re.footprint+'&nbsp;gha</dd></dl>';
  html += '<dl class="dl-horizontal" style="height: 12px"><dt>Nombre d\'aliments:</dt><dd>'+re.foodstuff.length+'</dd></dl>';
	html+= '</li>';
	html+= '<div class="clearfix"></div>';
	html += '</ul></div></li>';
	return html;
}

/* -------------------------------------------------
 * Open a modal window and disply recipe infos  
 * @id: Recipe id 
 * ---------------------------------------------- */
function showRecipeDetail(id) {
	modalWin = new Modal.Base(document.body, {
		header: "Fiche site",
		body: "Chargement..."
	});
	new Request.JSON({
		'url': '/ajax/call/repasrc/showRecipeDetail',
			onRequest: function() {
			},
		onSuccess: function(res) {
			modalWin.setTitle(res.title).setBody(res.content).show();
		},
		onFailure: function() {
			modalWin.setTitle("Erreur").setBody("Aucun contenu, réessayez plus tard.").show();
		}
	}).post({id: id});
}

/* -------------------------------------------------
 * Open a modal window and disply foodstuff infos  
 * @id: Foodstuff id 
 * ---------------------------------------------- */
function showFoodstuffDetail(id, sid) {
	synonymId = sid || null;
	modalWin = new Modal.Base(document.body, {
		header: "Fiche site",
		body: "Chargement..."
	});
	new Request.JSON({
		'url': '/ajax/call/repasrc/showFoodstuffDetail',
			onRequest: function() {
			},
		onSuccess: function(res) {
			modalWin.setTitle(res.title).setBody(res.content).show();
		},
		onFailure: function() {
			modalWin.setTitle("Erreur").setBody("Aucun contenu, réessayez plus tard.").show();
		}
	}).post({id: id, synonymId: synonymId, recipeId: recipeId});
}

function addFoodstuffToRecipe(foodstuffId, synonymId) {
	console.log(foodstuffId+' - '+synonymId+' - '+recipeId);
	modalWin.setBody('OIOK');
}
