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
				top.document.location.href='/menu/liste';
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
				top.document.location.href='/menu/edition/informations';
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

	// Menu list
	if (typeOf(document.id('menu_container')) == 'element' && (document.location.href.indexOf('menu/liste') != -1)) {

		loadMenus();

		document.id('type').addEvent('change', function() {
			document.id('label').set('value', '');
			var val = this.get('value');
			if (val !== '') {
				resetSearch();
				loadMenus();
			}
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
				loadMenus();
			}, 200);
		});

	}

	// Recipe list in menu creation section
	if (document.location.href.indexOf('/edition/recettes') != -1) {

		loadRecipes();

		document.id('type').addEvent('change', function() {
			document.id('label').set('value', '');
			var val = this.get('value');
			if (val !== '') {
				resetSearch();
				loadRecipes();
			}
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

/* ----------------------------------------------
 * Retrieve a list of menus
 * ---------------------------------------------- */

function loadMenus() {
	var typeId = null;
	var typeSelected = document.id('type').getElement('option:selected');
	if (typeOf(typeSelected) == 'element') {
		typeId = typeSelected.get('value');
	}
	showSpinner();
	var menuList = new Request.JSON({
		'url': '/ajax/call/repasrc/searchMenu',
		onRequest: function() {
			showSpinner();
		},
		'onSuccess': function(res) {
			hideSpinner();
			var container = document.body.getElement('.thumbnails');
			container.set('html', '');
			var html = '';
			var rowscount = 0;
			if (typeOf(res['menuList']) == 'array' && res['menuList'].length > 0) {
				Object.each(res['menuList'], function(me) {
					html += buildMenuThumb(me);
				});
				rowscount = res['numResults'];
			} else {
				html += '<div style="width: 540px;padding: 10px" class="alert alert-danger">Aucun menu ne correspond à vos critères de recherche</div>';
			}
			new Paginator(document.id('listpagination'), {
				rowscount: rowscount,
				rowsperpage: listLimit,
				page: currentPage,
				onSelect: function(infos) {
					listOffset = infos.offset;
					currentPage = infos.page;
					loadMenus();
				}
			});
			container.set('html', html);
		}
	}).post({typeId: typeId, label: document.id('label').value, offset: listOffset, limit: listLimit});
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
function buildMenuThumb(me) {
	html = '<li onclick="showMenuDetail('+me.id+')" class="span5 result" style="width: 550px;cursor:pointer"><div class="thumbnail">';
	html+= '<ul style="margin:0">';
	html+= '<li class="span2" style="margin: 0"><img style="height:100px" src="/mod/repasrc/foodstuffImg/none.jpg" alt /></li>';
	html+= '<li class="span5">';
	html+= '<div><h3 class="name" rel="'+me.label_caps+'">'+me.label+'</h3></div>';
	html+= '<div>';
	if (me.eaters) {
		html += '<dl class="dl-horizontal"><dt>Nombre de convives:</dt><dd>'+me.eaters+'</dd></dl>';
	}
	if (me.footprint !== 0) {
		html += '<dl class="dl-horizontal"><dt>Empreinte foncière:</dt><dd>'+Math.round(me.footprint,3)+'&nbsp;m²g</dd></dl>';
	}
	html+= '</div></li>';
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
	showSpinner();
	var recipeList = new Request.JSON({
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
						html += '<div style="width: 500px;padding: 10px" class="alert alert-danger">Aucune recette ne correspond à vos critères de recherche</div>';
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
	html = '<li class="span6" style="width:530px" onclick="showRecipeDetail('+re.id+')" class="span5 result" style="cursor:pointer"><div class="thumbnail">';
	html+= '<ul style="margin:0">';
	html+= '<li class="span2" style="margin: 0"><img style="height:110px" src="/mod/repasrc/foodstuffImg/'+'TODO'+'.jpg" alt /></li>';
	html+= '<li class="span4" style="margin: 0;padding:5px 0 0 10px">';
	html+= '<div><h3 class="name" rel="xyz">'+re.label+'</h3></div>';
	html += '<table>';
  html += '<tr><td>Composante:</td><td class="bold">'+re.component+'</td></tr>';
	html += '<tr><td>Empreinte foncière:</td><td class="bold">'+re.footprint+'&nbsp;m²</td></tr>';
  html += '<tr><td>Nombre d\'aliments:</td><td class="bold">'+re.foodstuffList.length+'</td></tr>';
	html+= '</table></li>';
	html+= '<div class="clearfix"></div>';
	html += '</ul></div></li>';
	return html;
}

/* -------------------------------------------------
 * Open a modal window and disply recipe infos
 * @id: Recipe id
 * ---------------------------------------------- */
function showMenuDetail(id, c) {
	var comp = c || false;
	new Request.JSON({
		'url': '/ajax/call/repasrc/showMenuDetail',
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
 * Open a modal window and disply recipe infos
 * @id:r recipe id
 * @menuRecipeId: recipe id for this menu
 * ---------------------------------------------- */
function showRecipeDetail(id, menuRecipeId) {
	new Request.JSON({
		'url': '/ajax/call/repasrc/showRecipeDetail',
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
			processHelp('div.modal-box');
		},
		onFailure: function() {
			hideSpinner();
			modalWin.setTitle("Erreur").setBody("Aucun contenu, réessayez plus tard.").show();
		}
	}).post({id: id, menuId: menuId, modulesList: modulesList, menuRecipeId: menuRecipeId});
}

/* -------------------------------------------------
 * Send ajax request to delete foodstuff from recipe
 * and close modal window
 * @recipeFoodstuffId: foodstuff id for this recipe
 * ---------------------------------------------- */
function deleteMenuRecipe(id) {
	if (!id) {
		alert('Erreur lors de la suppression de la recette');
		return;
	}
	new Request.JSON({
		'url': '/ajax/call/repasrc/deleteMenuRecipe',
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

/* -------------------------------------------------
 * Send ajax request to delete menu
 * @recipeId: id of the recipe
 * ---------------------------------------------- */
function deleteMenu(id) {
	new Request.JSON({
		'url': '/ajax/call/repasrc/deleteMenu',
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

function showUpdateMenuRecipeModal(menuId, recipeId, menuRecipeId) {
	new Request.JSON({
		'url': '/ajax/call/repasrc/getMenuRecipeModal',
		onRequest: function() {
			showSpinner();
		},
		onSuccess: function(res,a,b,c) {
			hideSpinner();
			modalWin.setTitle('Ajouter la recette au menu').setBody(res.content).setFooter('');
			var modw = $(document.body).getElement('div.modal-content');
			modw.setStyles({'min-height' : '20px', 'height': '140px'});

			// Form
			var chForm_recipeForm=document.id('informations');
			var chForm_recipeFormValidator = new Form.Validator.Inline(chForm_recipeForm, { evaluateFieldsOnChange: false, evaluateFieldsOnBlur: false, warningPrefix: '', errorPrefix: '' });

			document.id('cancel').addEvent('click', function() {
				modalWin.hide();
			});

			modw.getElement('input[type=submit]').addEvent('click', function(e) {
				e.stop();
				if (chForm_recipeForm.validate()) {
					updateMenuRecipe(menuId, recipeId, menuRecipeId, document.id('portions').value);
				}
			});
			processHelp('div.modal-box');
		},
		onFailure: function() {
			hideSpinner();
			modalWin.setTitle("Erreur").setBody("Aucun contenu, réessayez plus tard.").show();
		}
	}).post({menuId: menuId, recipeId: recipeId, menuRecipeId: menuRecipeId});

}

function updateMenuRecipe(menuId, recipeId, menuRecipeId, portions) {
	new Request.JSON({
		'url': '/ajax/call/repasrc/updateMenuRecipe',
		onRequest: function() {
			showSpinner();
		},
		onSuccess: function(res,a,b,c) {
			hideSpinner();
			var testurl = top.document.location.href.split('/');
			var tmpid = testurl.pop();
			if (tmpid != menuId) {
			console.log('ici');
			console.log(top.document.location.href+'/'+menuId);
				top.document.location.href=top.document.location.href+'/'+menuId;
			} else {
				top.document.location.href=top.document.location.href;
			}
		},
		onFailure: function() {
			hideSpinner();
			modalWin.setTitle("Erreur").setBody("Aucun contenu, réessayez plus tard.").show();
		}
	}).post({menuId: menuId, recipeId: recipeId, menuRecipeId: menuRecipeId, portions: portions});
}

function submitRecipeForm() {
		var form = document.id('recipeForm');
		form.set('action', top.document.location.href);
		form.submit();
}
