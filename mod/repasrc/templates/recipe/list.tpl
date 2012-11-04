{extends tplextends('repasrc/container')}

{block name='webpage_head' append}
	{js file="/mod/repasrc/js/recipe.js"}
{/block}

{block name='main-container-title'}
	<h1>{t d='repasrc' m='Livre de recettes'}</h1>
	<p class="lead">{t d='repasrc' m='Recherchez parmi les recettes disponibles en libre consultation.'}</p>
{/block}

{block name='main-container-content'}
<div class="help" code="livrederecette"></div>
<form class="well form-inline" id="recipe_search_form" name="repice_search_form"  action="/recette/liste" method="post">

	<select name="type" id="type">
     <option value="me">Vos recettes</option>
     <option value="STALLION">Recettes "Etalon"</option>
     <option value="OTHER">Recettes partagées par les autres RC</option>
     <option value="ALL">Toutes les recettes</option>
   </select>
   <div class="help" code="vosrecettes" location="bottom"></div>

	<select name="component" id="component">
    <option value="">Tout type de composante</option>
    <option value="STARTER">Entrée</option>
    <option value="MEAL">Plat</option>
    <option value="CHEESE/DESSERT">Fromage/Dessert</option>
    <option value="BREAD">Pain</option>
  </select>
   <div class="help" code="typesdecomposantes" location="bottom"></div>
			
	<input type="text" id="label" name="label" class="input-medium" placeholder="Nom de la recette" />
  <div class="help" code="nomdelarecette" location="bottom"></div>

	<input type="text" id="fsname" name="fsname" class="input-medium" placeholder="Nom d'un l'aliment" />
  <div class="help" code="nomdunaliment" location="bottom"></div>

	</form>

	<div id="recipe_container" class="clearfix">
		<div class="span9 recipe-list">
      <div class="pagination pagination-small" id="listpagination"></div>
			<div class='alert alert-danger not-found' style='display: none'>Aucune recette ne correspond aux critères de recherche.</div>
			<ul class="thumbnails">
			</ul>
		</div>
		<div class="span3">
			<h4 style="margin-bottom:10px">Recettes sélectionnées</h4>
			<div class="help" code="recettesselectionnees"></div>
			{if (!is_array($recipeList) || sizeof($recipeList) < 1)}
			<div class="alert alert-error">
				Aucune recette.
			</div>
			{else}
				<ul class="nav nav-tabs nav-stacked">
					{foreach $recipeList as $rid}
						<li class="clearfix" style="cursor:pointer;width:270px">
							<a href="javascript:void(0)">
								<span>
									<strong onclick="showRecipeDetail({$rid}, true)">
										{\mod\repasrc\Recipe::getNameFromId($rid)}
									</strong>
									<span style="margin-left:5px"><i onclick="window.document.location.href='/recette/liste/del/{$rid}'" class="icon icon-remove"></i></span>
								</span>
							</a>
						</li>
						{if $rid@index == 1}
							{assign var="showCompareButton" value="true"}
						{/if}
					{/foreach}
				</ul>
				{if isset($showCompareButton) && $showCompareButton}
					<a style="margin-left:40px" href="/recette/comparer" class="btn btn-primary">Comparer les recettes</a>
				{/if}
			{/if}
		</div>
	</div>
{/block}
