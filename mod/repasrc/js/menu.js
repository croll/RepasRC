/* ------------------------------------------------------
 * Action triggered on page load 
 * Things done are differents between 
 * pages identified by an existing *_container element
 * --------------------------------------------------- */

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
	if (typeOf(document.id('menu_container')) == 'element') {

		loadMenus();

		document.id('type').addEvent('change', function() {
			document.id('label').set('value', '');
			var val = this.get('value');
			if (val != '') {
				loadMenus();
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

	}

	// Recipe list in menu creation section
	if (typeOf(document.id('menu_search_form')) == 'element') {

		loadMenus();

		document.id('type').addEvent('change', function() {
			document.id('label').set('value', '');
			var val = this.get('value');
			if (val != '') {
				loadMenus();
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
	}

});

/* ----------------------------------------------
 * Retrieve a list of recipes
 * @reset: Reset families and sub families selects
 * ---------------------------------------------- */

function loadMenus() {
	var typeId = null;
	var typeSelected = document.id('type').getElement('option:selected');
	if (typeOf(typeSelected) == 'element') {
		typeId = typeSelected.get('value');
	}
	var menuList = new Request.JSON({
			'url': '/ajax/call/repasrc/searchMenu',
			'onSuccess': function(res) {
				var container = document.body.getElement('.thumbnails');
				container.set('html', '');
				var html = '';
				// for each foodstuff
				Object.each(res, function(fs) {
					html += buildMenuThumb(fs);
				});
				container.set('html', html);
			}
  }).post({typeId: typeId});
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
	if (found == false) {
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
	html+= '<li class="span3" style="margin: 0;padding:5px 0 0 10px">';
	html+= '<div><h3 class="name" rel="'+me.label_caps+'">'+me.label+'</h3></div>';
	if (me.eaters) {
		html += '<dl class="dl-horizontal"><dt>Nombre de convives:</dt><dd>'+me.eaters+'</dd></dl>';
	}
	if (me.footprint) {
		html += '<dl class="dl-horizontal"><dt>Empreinte écologique foncière:</dt><dd>'+Math.round(me.footprint,3)+'&nbsp;m²g</dd></dl>';
	}
	html+= '</li>';
	html+= '<div class="clearfix"></div>';
	html += '</ul></div></li>';
	return html;
}

/* ----------------------------------------------
 * Remotely get list of recipes 
 * ---------------------------------------------- */
function loadRecipes() {
	var recipeList = new Request.JSON({
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
  }).post({typeId: typeId});
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
	html+= '<div><h3 class="name" rel="xyz">'+re.label+'</h3></div>';
  html += '<dl class="dl-horizontal"><dt>Composante:</dt><dd>'+re.component+'</dd></dl>';
	html += '<dl class="dl-horizontal"><dt>Empreinte écologique foncière:</dt><dd">'+re.footprint+'&nbsp;m²</dd></dl>';
  html += '<dl class="dl-horizontal"><dt>Nombre d\'aliments:</dt><dd>'+re.foodstuffList.length+'</dd></dl>';
	html+= '</li>';
	html+= '<div class="clearfix"></div>';
	html += '</ul></div></li>';
	return html;
}

/* -------------------------------------------------
 * Open a modal window and disply recipe infos  
 * @id: Recipe id 
 * ---------------------------------------------- */
function showMenuDetail(id) {
	new Request.JSON({
		'url': '/ajax/call/repasrc/showMenuDetail',
		'evalScripts' : true,
		'evalResponse' : true,
			onRequest: function() {
			},
		onSuccess: function(res) {
			modalWin.setTitle(res.title).setBody(res.content);
			var clone = document.getElement('div.form-actions').clone();
			document.getElement('div.form-actions').dispose();
			modalWin.setFooter(clone.get('html'));
			modalWin.show();
			CaptainHook.Bootstrap.initAlerts();
		},
		onFailure: function() {
			modalWin.setTitle("Erreur").setBody("Aucun contenu, réessayez plus tard.").show();
		}
	}).post({id: id});
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
			},
		onSuccess: function(res,a,b,c) {

			modalWin.setTitle(res.title).setBody(res.content);
			var clone = document.getElement('div.form-actions').clone();
			document.getElement('div.form-actions').dispose();
			modalWin.setFooter(clone.get('html'));
			modalWin.show();
			CaptainHook.Bootstrap.initTabs('quantity');
			CaptainHook.Bootstrap.initAlerts();
			// Form
			var chForm_recipeForm=document.id('recipeForm');
			var chForm_recipeFormValidator = new Form.Validator.Inline(chForm_recipeForm, { evaluateFieldsOnChange: false, evaluateFieldsOnBlur: false, warningPrefix: '', errorPrefix: '' });
		},
		onFailure: function() {
			modalWin.setTitle("Erreur").setBody("Aucun contenu, réessayez plus tard.").show();
		}
	}).post({id: id, menuId: menuId, modulesList: modulesList, menuRecipeId: menuRecipeId});
}

/* -------------------------------------------------
 * Send ajax request to delete foodstuff from recipe
 * and close modal window  
 * @recipeFoodstuffId: foodstuff id for this recipe
 * ---------------------------------------------- */
function deleteMenuRecipe() {
	id = $('menuRecipeId').get('value');
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
		},
		onSuccess: function(res,a,b,c) {
			top.document.location.href=top.document.location.href;
		},
		onFailure: function() {
			modalWin.setTitle("Erreur").setBody("Aucun contenu, réessayez plus tard.").show();
		}
	}).post({id: id});
}

function submitRecipeForm() {
	document.id('recipeForm').submit();
}
