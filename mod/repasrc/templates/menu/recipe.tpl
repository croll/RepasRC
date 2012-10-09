{extends tplextends('repasrc/menu_edit')}

{block name='webpage_head' append}
	{js file="/mod/repasrc/js/menu.js"}
{/block}

{block name='menu_title'}
	<h1>{t d='repasrc' m='Composer un menu'}</h1>
	<p class="lead">{t d='repasrc' m='Sélectionnez les recettes qui composent votre menu et définissez le nombre de portions.'}</p>
{/block}

{block name='menu_content'}
	<h2 style="margin-bottom: 3px">{$menu.label|ucfirst}</h2>
	<div class="alert alert-info">
		<a class="close" data-dismiss="alert">×</a>
		Cliquez sur une recette pour la voir en détail et l'ajouter à votre menu.<br />
		Vous pouvez chercher dans le livre de recettes en filtrant par type, composante et/ou par nom.
	</div> 

	<form class="well form-inline" id="menu_search_form" name="search_form"  action="/menu/liste" method="post">

		<select name="type" id="type">
	     <option value="me">Vos recettes</option>
	     <option value="LIGHTFOOTPRINT">Recettes "Pied léger"</option>
	     <option value="STALLION">Recettes "Etalon"</option>
	     <option value="OTHER">Recettes partagées par les autres RC</option>
	     <option value="ADMIN">Recettes proposées par les administrateurs</option>
	   </select>

		<select name="component" id="component">
	    <option value="">Tout type de composante</option>
	    <option value="STARTER">Entrée</option>
	    <option value="MEAL">Plat</option>
	    <option value="CHEESE/DESSERT">Fromage/Dessert</option>
	    <option value="BREAD">Pain</option>
	  </select>
				
		<input type="text" id="label" name="label" class="input-medium" placeholder="Nom de la recette" />

	</form>

	<div id="menu_container">
		<div class="span6 recipe-list">
			<ul class="thumbnails">
			</ul>
			<div class='alert alert-danger not-found' style='display: none'>Aucun résultat.</div>
		</div>
		<div class="span3" style="margin: 0">
			<h3 style="margin-bottom:10px">Composition du menu</h3>
			{if (!isset($menu.recipeList) || empty($menu.recipeList))}
			<div class="alert alert-error">
				Aucune recette.
			</div>
			{else}
				<ul class="nav nav-tabs nav-stacked">
					{foreach $menu.recipeList as $recipe}
						<li class="clearfix" style="cursor:pointer">
							<a href="javascript:showRecipeDetail({$recipe.id}, {$recipe.menuRecipeId})" style="color: #000;font-size:12px">
								<div style="float:left;font-weight:bold;font-size:12px;margin-right:5px;color: #0088CC">{$recipe.portions}</div>
								<span>
									<strong>
										{$recipe.label}
									</strong>
								</span>
							</a>
						</li>
					{/foreach}
				</ul>
			{/if}
		</div>
	</div>
{/block}

{block name="container-right"}
{/block}
