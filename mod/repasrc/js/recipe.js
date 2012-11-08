/* ------------------------------------------------------
 * Action triggered on page load
 * Things done are differents between
 * pages identified by an existing *_container element
 * --------------------------------------------------- */

var listOffset = 0;
var currentPage = 0;
var listLimit = 10;

function resetSearch() {
	listOffset = 0;
	currentPage = 0;
	listLimit = 10;
}

window.addEvent('domready', function() {
	
	// Informations
	if (typeOf(document.id('informations_container')) == 'element') {
		var myMooDatePicker = new MooDatePicker(document.getElement('input[name=consumptiondate]'), {
			onPick: function(date){
				this.element.set('value', date.format('%e/%m/%Y'));
			}
		});
	}

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

	// Recipe foodstuff list
	if (typeOf(document.id('foodstuff_container')) == 'element') {

		document.id('subfamily').adopt(new Element('option').set('value', '').set('html', 'Sous famille de produit'));

		loadFamilies();
		loadSubFamilies();
		loadFoodstuff();

		document.id('family').addEvent('change', function() {
			document.id('fsname').set('value', '');
			var val = this.get('value');
			if (val !== '') {
				document.id('subfamily').empty().adopt(new Element('option').set('value', '').set('html', 'Sous famille de produit'));
				resetSearch();
				loadFoodstuff();
				loadSubFamilies(val);
			} else {
				loadFoodstuff(true);
			}
		});

		document.id('subfamily').addEvent('change', function() {
				document.id('fsname').set('value', '');
				resetSearch();
				loadFoodstuff();
		});

		document.id('fsname').addEvent('keyup', function(e) {
			if (e.key == 'enter') {
				e.stop();
				e.stopPropagation();
				return;
			}
			var text = this.value;
			if (timeout !== undefined) {
				clearTimeout(timeout);
			}
			timeout = setTimeout(function() {
				resetSearch();
				loadFoodstuff();
			}, 200);
		});

	}

	// Recipe list in recipe creation section
	if (typeOf(document.id('recipe_search_form')) == 'element') {

		loadRecipes();

		document.id('type').addEvent('change', function() {
			document.id('label').set('value', '');
			document.id('fsname').set('value', '');
			var val = this.get('value');
			if (val !== '') {
				resetSearch();
				loadRecipes();
			}
		});

		document.id('component').addEvent('change', function() {
			document.id('label').set('value', '');
			document.id('fsname').set('value', '');
			var val = this.get('value');
			resetSearch();
			loadRecipes();
		});

		var timeout;
		document.id('label').addEvent('keyup', function(e) {
			if (e.key == 'enter') {
				e.stop();
				e.stopPropagation();
				return;
			}
			var text = this.value;
			if (timeout !== undefined) {
				clearTimeout(timeout);
			}
			timeout = setTimeout(function() {
				resetSearch();
				loadRecipes();
			}, 200);
		});

		document.id('fsname').addEvent('keyup', function(e) {
			if (e.key == 'enter') {
				e.stop();
				e.stopPropagation();
				return;
			}
			var text = this.value;
			if (timeout !== undefined) {
				clearTimeout(timeout);
			}
			timeout = setTimeout(function() {
				resetSearch();
				loadRecipes();
			}, 200);
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
			onRequest: function() {
				showSpinner();
			},
			'onSuccess': function(res) {
				hideSpinner();
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
	if (num === undefined) num = null;
	var userList = new Request.JSON({
			'url': '/ajax/call/repasrc/getSubFamilies',
			onRequest: function() {
				showSpinner();
			},
			'onSuccess': function(res) {
				hideSpinner();
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
	var familyId = null;
	var subFamilyId = null;
	if (reset !== true) {
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
			onRequest: function() {
				showSpinner();
			},
			'onSuccess': function(res) {
				hideSpinner();
				var container = document.body.getElement('.thumbnails');
				container.empty();
				var html = '';
				var rowscount = 0;
				// for each foodstuff
				if (typeOf(res['fsList']) == 'array' && res['fsList'].length > 0) {
					Object.each(res['fsList'], function(fs) {
						html += buildFoodstuffThumb(fs);
					});
					rowscount = res['numResults'];
				}
				new Paginator(document.id('listpagination'), {
					rowscount: rowscount,
					rowsperpage: listLimit,
					page: currentPage,
					onSelect: function(infos) {
						listOffset = infos.offset;
						currentPage = infos.page;
						loadFoodstuff();
					}
				});
				container.set('html', html);
			}
			// Hack for familyId, humfr...
  }).post({familyId: ''+familyId, subFamilyId: subFamilyId, label: document.id('fsname').get('value'), limit: listLimit, offset: listOffset});
}

/* ---------------------------------------------------------------------
 * Hide result not matching criterias in foodstuff list
 * @txt: value of filter
 * @type: type of filter (name, familie, etc) equal to element class name
 * --------------------------------------------------------------------- */
function filterResults(txt, type) {
	t = type || 'name';
	var els = document.body.getElements('.result') || null;
	notfoundEl = document.getElement('div.not-found');
	notfoundEl.setStyle('display', 'none');
	var found = false;
	if (els) {
		els.each(function(el) {
			if (el.getElement('.'+t).get('rel').toLowerCase().indexOf(txt.toLowerCase()) == -1 && el.getElement('.'+t).get('html').toLowerCase().indexOf(txt.toLowerCase()) == -1 ) {
				el.setStyle('display', 'none');
			} else {
				el.setStyle('display', 'block');
				found = true;
			}
		});
	}
	if (found === false) {
		if (notfoundEl) {
			notfoundEl.setStyle('display', 'block');
		}
	}
}

/* -------------------------------------------------
 * Build foodstuff tiny block with image, fs name, etc
 * multiple occurences build the foodstuff list
 * @fs: foodstuff object
 * ---------------------------------------------- */
function buildFoodstuffThumb(fs) {
	var imgId, name, tmpcode;
	if (typeOf(fs.synonym_id) == 'number') {
		imgId = 's'+fs.synonym_id;
		name = fs.synonym;
	} else {
		fs.synonym_id = null;
		imgId = fs.id;
		name = fs.label;
	}
	html = '<li class="span6" onclick="showFoodstuffDetail('+fs.id+', '+fs.synonym_id+')" class="span5 result" style="cursor:pointer"><div class="thumbnail">';
	html+= '<ul style="margin:0">';
	html+= '<li class="span2" style="margin: 0"><img style="height:100px" src="/mod/repasrc/foodstuffImg/'+imgId+'.jpg" alt /></li>';
	html+= '<li class="span3" style="margin: 0;padding:5px 0 0 10px">';
		html+= '<div><h3 class="name" rel="'+fs.label_caps+'">'+name+'</h3></div>';
		if (typeOf(fs.infos) == 'array') {
			html += '<div>';
			fs.infos.each(function(info) {
				html += '<span class="badge fam'+info.family_group_id+'" style="margin: 0px 5px 0 0">'+info.family_group+'</span>';
			});
			html += '</div>';
		}
		if (fs.footprint) {
			html += '<dl class="dl-horizontal"><dt>Empreinte foncière:</dt><dd>'+Math.round(fs.footprint,3)+'&nbsp;m²</dd></dl>';
		}
		if (fs.synonym && (fs.synonym != fs.label)) {
			html += '<div class="alert alert-warning">'+fs.label+'</div>';
		}
		if (fs.conservation) {
		html += '<dl class="dl-horizontal"><dt>Mode de conservation</dt><dd>'+fs.conservation+'</dd></dl>';
		}
		if (fs.production) {
			html += '<dl class="dl-horizontal"><dt>Mode de production</dt><dd>'+fs.production+'</dd></dl>';
		}
		if (!fs.footprint) {
			html += '<div class="alert alert-danger" style="margin-top:10px">Aucune valeur connue  d\'empreinte écologique foncière</div>';
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
	var typeId = null;
	var componentId = null;
	if (reset !== true) {
		var typeSelected = document.id('type').getElement('option:selected');
		if (typeOf(typeSelected) == 'element') {
			typeId = typeSelected.get('value');
		}
		var componentSelected = document.id('component').getElement('option:selected');
		if (typeOf(componentSelected) == 'element') {
			componentId = componentSelected.get('value');
		}
	}
	var rList = new Request.JSON({
			'url': '/ajax/call/repasrc/searchRecipe',
			onRequest: function() {
				showSpinner();
			},
			'onSuccess': function(res) {
				hideSpinner();
				var container = document.body.getElement('.thumbnails');
				container.set('html', '');
				var html = '';
				var rowscount = 0;
				// for each recipe
				if (typeOf(res['recipeList']) == 'array' && res['recipeList'].length > 0) {
					Object.each(res['recipeList'], function(re) {
						html += buildRecipeThumb(re);
					});
					rowscount = res['numResults'];
				} else {
						html += '<div style="width: 540px;padding: 10px" class="alert alert-danger">Aucune recette ne correspond à vos critères de recherche</div>';
				}
				new Paginator(document.id('listpagination'), {
					rowscount: rowscount,
					rowsperpage: listLimit,
					page: currentPage,
					onSelect: function(infos) {
						listOffset = infos.offset;
						currentPage = infos.page;
						loadRecipes();
					}
				});
				container.set('html', html);
			}
  }).post({typeId: typeId, componentId: componentId, recipeLabel: document.id('label').value, foodstuffName: document.id('fsname').value, offset: listOffset, limit: listLimit});
}

/* -------------------------------------------------
 * Build recipe tiny block with image, name, etc
 * multiple occurences build the recipe list
 * @re: recipe object
 * ---------------------------------------------- */
function buildRecipeThumb(re) {
	html = '<li class="span9" onclick="showRecipeDetail('+re.id+')" class="span5 result" style="cursor:pointer"><div class="thumbnail">';
	html+= '<ul style="margin:0">';
	html+= '<li class="span2" style="margin: 0"><img style="height:110px" src="/mod/repasrc/foodstuffImg/'+'TODO'+'.jpg" alt /></li>';
	html+= '<li class="span7" style="margin: 0;padding:5px 0 0 10px">';
	html+= '<div><h3 class="name" rel="xyz">'+re.label+'</h3></div>';
	if (typeOf(re.families) == 'object') {
		html += '<div>';
		var i = 0;
		Object.each(re.families, function(fam, famId) {
			info = fam.split('_');
			html += '<span class="badge fam'+famId+'" style="margin: 0px 5px 0 0">'+info[1]+'</span>';
			if (i>3) {
				html += '<br/>';
				i=0;
			}
			i+=1;
		});
		html += '</div>';
	}
  html += '<table style="margin-top:8px">';
  html += '<tr><td>Composante:</td><td class="bold">'+re.component+'</td></tr>';
	html += '<tr><td>Empreinte foncière:</td><td class="bold">'+re.footprint+'&nbsp;m²</td></tr>';
  html += '<tr><td>Nombre d\'aliments:</td><td class="bold">'+re.foodstuffList.length+'</td></tr>';
	html+= '</table></li>';
	html+= '</table></li>';
	html+= '<div class="clearfix"></div>';
	html += '</ul></div></li>';
	return html;
}

/* -------------------------------------------------
 * Open a modal window and disply recipe infos
 * @id: Recipe id
 * ---------------------------------------------- */
function showRecipeDetail(id, c) {
	var comp = c || false;
	new Request.JSON({
		'url': '/ajax/call/repasrc/showRecipeDetail',
		'evalScripts' : true,
		'evalResponse' : true,
		onRequest: function() {
			showSpinner();
		},
		onSuccess: function(res) {
			hideSpinner();
			modalWin.setTitle(res.title).setBody(res.content);
			var clone = document.getElement('div.form-actions').clone();
			document.getElement('div.form-actions').dispose();
			modalWin.setFooter(clone.get('html'));
			modalWin.show();
			processHelp('div.modal-box');
		},
		onFailure: function() {
			hideSpinner();
			modalWin.setTitle("Erreur").setBody("Aucun contenu, réessayez plus tard.").show();
		}
	}).post({id: id, comparison: comp});
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
			showSpinner();
		},
		onSuccess: function(res,a,b,c) {
			hideSpinner();
			modalWin.setTitle(res.title).setBody(res.content);
			var clone = document.getElement('div.form-actions').clone();
			document.getElement('div.form-actions').dispose();
			modalWin.setFooter(clone.get('html'));
			modalWin.show();
			CaptainHook.Bootstrap.initTabs('quantity');
			processHelp('div.modal-box');
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
						if (document.body.getElement('div[rel='+value.id+']')) {
							return false;
						}
						var el = new Element('div').addClass('step').set('rel', value.id);
						el.adopt(new Element('span').set('html', value.label));
						el.adopt(new Element('i').addClass('icon icon-remove').setStyle('cursor', 'pointer').addEvent('click', function() {
							$('steps_input').set('value', '');
							removeFoodstuffStep(this.getParent().get('rel'));
						}));
						el.inject(document.id('steps'));
						$('steps_input').set('value', '');
						document.id('origin_steps').value+=value.id+' ';
					}
			});
		},
		onFailure: function() {
			hideSpinner();
			modalWin.setTitle("Erreur").setBody("Aucun contenu, réessayez plus tard.").show();
		}
	}).post({id: id, synonymId: synonymId, recipeId: recipeId, modulesList: modulesList, recipeFoodstuffId: recipeFoodstuffId});
}

/* -------------------------------------------------
 * Remove origin step from receipe foodstuff
 * @this: element
 * ---------------------------------------------- */
function removeFoodstuffStep(id) {
	document.body.getElement('div[rel='+id+']').dispose();
	var val = '';
	document.body.getElements('div[class="step"]').each(function(el) {
		val += el.get('rel')+' ';
	});
	$('origin_steps').empty().set('value', val);
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
	new Request.JSON({
		'url': '/ajax/call/repasrc/deleteRecipeFoodstuff',
		onRequest: function() {
			showSpinner();
		},
		onSuccess: function(res,a,b,c) {
			hideSpinner();
			top.document.location.href=top.document.location.href;
		},
		onFailure: function() {
			hideSpinner();
			modalWin.setTitle("Erreur").setBody("Aucun contenu, réessayez plus tard.").show();
		}
	}).post({id: id});
}

/* -------------------------------------------------
 * Send ajax request to delete recipe
 * @recipeId: id of the recipe
 * ---------------------------------------------- */
function deleteRecipe(id) {
	new Request.JSON({
		'url': '/ajax/call/repasrc/deleteRecipe',
		onRequest: function() {
			showSpinner();
		},
		onSuccess: function(res,a,b,c) {
			hideSpinner();
			top.document.location.href=top.document.location.href;
		},
		onFailure: function() {
			hideSpinner();
			modalWin.setTitle("Erreur").setBody("Aucun contenu, réessayez plus tard.").show();
		}
	}).post({id: id});
}

/* -------------------------------------------------
 * Replace modal content to duplicate recipe
 * @recipeId: id of the recipe
 * ---------------------------------------------- */
function duplicateRecipeModal(id) {
	new Request.JSON({
		'url': '/ajax/call/repasrc/duplicateRecipeModal',
		onRequest: function() {
			showSpinner();
		},
		onSuccess: function(res,a,b,c) {
			hideSpinner();
			modalWin.setTitle('Dupliquer la recette').setBody(res.content).setFooter('');
			processHelp('div.modal-box');
		},
		onFailure: function() {
			hideSpinner();
			modalWin.setTitle("Erreur").setBody("Aucun contenu, réessayez plus tard.").show();
		}
	}).post({id: id});
}

/* -------------------------------------------------
 * Send ajax request to duplicate recipe
 * @recipeId: id of the recipe
 * ---------------------------------------------- */
function duplicateRecipe(id) {
	new Request.JSON({
		'url': '/ajax/call/repasrc/duplicateRecipe',
		onRequest: function() {
			showSpinner();
		},
		onSuccess: function(res,a,b,c) {
			hideSpinner();
			top.document.location.href='/recette/edition/informations/'+id;
		},
		onFailure: function() {
			hideSpinner();
			modalWin.setTitle("Erreur").setBody("Aucun contenu, réessayez plus tard.").show();
		}
	}).post({id: id});
}

function submitFoodstuffForm() {
	// Form
	var chForm_foodstuffForm=document.id('foodstuffForm');
	var chForm_foodstuffFormValidator = new Form.Validator.Inline(chForm_foodstuffForm, { evaluateFieldsOnChange: false, evaluateFieldsOnBlur: false, warningPrefix: '', errorPrefix: '' });
	if(chForm_foodstuffForm.validate()) {
		var form = document.id('foodstuffForm');
		form.set('action', top.document.location.href);
		form.submit();
	}
}
