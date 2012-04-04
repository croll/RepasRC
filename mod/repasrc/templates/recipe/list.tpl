{extends tplextends('repasrc/recipe')}

{block name='webpage_head' append}
	{js file="/mod/repasrc/js/recipe.js"}
{/block}

{block name='recipe_title'}
	<h1>{t d='repasrc' m='Livre de recettes'}</h1>
	<p class="lead">{t d='repasrc' m='Recherchez parmi les recettes disponibles en libre consultation.'}</p>
{/block}

{block name='recipe_content'}
	<legend>{t d='repasrc' m='Liste des recettes'}</legend>
		<form class="well form-inline" id="search_form" name="search_form"  action="/recette/liste" method="post">
				
				<input type="text" id="label" name="label" style="width:120px"  placeholder="Nom de la recette" />

				<select name="owner" id="owner">
          <option value="">Vos recettes</option>
          <option value="admin">Les recettes commentées</option>
          <option value="other">Les recettes partagées par d'autres RC</option>
        </select>

				<select name="component" id="type">
          <option value="">Tout type de composante</option>
          <option value="STARTER">Entrée</option>
          <option value="MEAL">Plat</option>
          <option value="CHEESE/DESSERT">Fromage/Dessert</option>
          <option value="BREAD">Pain</option>
        </select>

				<input type="submit" class="btn" id="submit" value="Effectuer la recherche" />
		</form>
{/block}
