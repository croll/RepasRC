/* ------------------------------------------------------
 * Action triggered on page load 
 * Things done are differents between 
 * pages identified by an existing *_container element
 * --------------------------------------------------- */

window.addEvent('domready', function() {
		Locale.use('fr-FR');

	modalWin = new Modal.Base(document.body, {
		header: "",
		body: "Chargement...",
		limitHeight: false
	});

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

	// Recipe foodstuff list
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

	// Recipe list in recipe creation section
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

});

/* ----------------------------------
 * Remotely get families of foodstuff
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
	html = '<li onclick="showFoodstuffDetail('+fs.id+', '+fs.synonym_id+')" class="span5 result" style="width: 550px;cursor:pointer"><div class="thumbnail">';
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
		html += '<dl class="dl-horizontal"><dt style="width:235px">Empreinte écologique foncière:</dt><dd style="margin-left: 240px">'+Math.round(fs.footprint,3)+'&nbsp;m²/Kg</dd></dl>';
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
	html += '<dl class="dl-horizontal" style="height: 12px" style="margin:0px" style=""><dt>Empreinte écologique foncière:</dt><dd">'+re.footprint+'&nbsp;m²/Kg</dd></dl>';
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
	new Request.JSON({
		'url': '/ajax/call/repasrc/showRecipeDetail',
		'evalScripts' : true,
		'evalResponse' : true,
			onRequest: function() {
			},
		onSuccess: function(res) {
			modalWin.setTitle(res.title).setBody(res.content).show();
			CaptainHook.Bootstrap.initAlerts();
		},
		onFailure: function() {
			modalWin.setTitle("Erreur").setBody("Aucun contenu, réessayez plus tard.").show();
		}
	}).post({id: id});
}

/* -------------------------------------------------
 * Open a modal window and disply foodstuff infos  
 * @id: Foodstuff id 
 * @sid: Synonym id 
 * @recipeFoodstuffId: foodstuff id for this recipe
 * ---------------------------------------------- */
function showFoodstuffDetail(id, sid, recipeFoodstuffId) {
	synonymId = sid || null;
	new Request.JSON({
		'url': '/ajax/call/repasrc/showFoodstuffDetail',
		'evalScripts' : true,
		'evalResponse' : true,
			onRequest: function() {
			},
		onSuccess: function(res,a,b,c) {

			modalWin.setTitle(res.title).setBody(res.content).show();
			CaptainHook.Bootstrap.initTabs('quantity');
			CaptainHook.Bootstrap.initAlerts();
			// Form
			var chForm_foodstuffForm=document.id('foodstuffForm');
			var chForm_foodstuffFormValidator = new Form.Validator.Inline(chForm_foodstuffForm, { evaluateFieldsOnChange: false, evaluateFieldsOnBlur: false, warningPrefix: '', errorPrefix: '' });
			// JS for location
			document.body.getElement('select[name=location]').addEvent('change', function() {
				if (this.getSelected().get('value') == 'LETMECHOOSE') {
					document.id('location_steps').setStyle('display', 'block');
				}
			});
			// Autocomplete
			var myAutocomplete = new Meio.Autocomplete($('steps_input'), '/ajax/call/repasrc/getCities', {
					filter: {
						type: 'contains',
						path: 'label'
					},
					onNoItemToList: function(elements){
						elements.field.node.highlight('#ff5858');
					},
					onSelect: function(elements, value) {
						var el = new Element('div').addClass('step').set('rel', value.id);
						el.adopt(new Element('span').set('html', value.label));
						el.adopt(new Element('i').addClass('icon icon-remove').setStyle('cursor', 'pointer').addEvent('click', function() {
							$('steps_input').set('value', '');
							removeFoodstuffStep(this.getParent().get('rel'));
						}));
						el.inject(document.id('steps'));
						document.id('origin_steps').value+=value.id+' ';
					}
			});
		},
		onFailure: function() {
			modalWin.setTitle("Erreur").setBody("Aucun contenu, réessayez plus tard.").show();
		}
	}).post({id: id, synonymId: synonymId, recipeId: recipeId, modulesList: modulesList, recipeFoodstuffId: recipeFoodstuffId});
}

/* -------------------------------------------------
 * Remove origin step from receipe foodstuff 
 * @this: element
 * ---------------------------------------------- */
function removeFoodstuffStep(id) {
	el = document.body.getElement('div[rel='+id+']');
	el.dispose();
	var val = '';
	$('oritin_steps').get('value').split(' ').each(function(v) {
			if (v != id) {
				val += v+' ';
			}
	});
	$('origin_steps').set('value', val);
}

/* -------------------------------------------------
 * Send ajax request to delete foodstuff from recipe
 * and close modal window  
 * @recipeFoodstuffId: foodstuff id for this recipe
 * ---------------------------------------------- */
function deleteRecipeFoodstuff() {
	id = $('recipeFoodstuffId').get('value');
	if (!id) {
		alert('Erreur lors de la suppression de l\'aliment');
		return;
	}
	console.log(id);
	new Request.JSON({
		'url': '/ajax/call/repasrc/deleteRecipeFoodstuff',
			onRequest: function() {
			},
		onSuccess: function(res,a,b,c) {
			top.document.location.href=top.document.location.href;
		},
		onFailure: function() {
			modalWin.setTitle("Erreur").setBody("Aucun contenu, réessayez plus tard.").show();
		}
	}).post({id: id});
}
