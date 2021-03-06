{extends tplextends('repasrc/recipe_edit')}

{block name='webpage_head' append}
	{js file="/mod/repasrc/js/recipe.js"}
{/block}

{block name='recipe_title'}
	<h1>{t d='repasrc' m='Composer une recette'}</h1>
	<p class="lead">{t d='repasrc' m='Sélectionnez les aliments composants votre recette et définissez leur grammage.'}</p>
{/block}

{block name='recipe_content'}

	<h2 style="margin-bottom: 3px">{$recipe.label|ucfirst}</h2>
	<div class="help" code="composerunerecette"></div> 

	<form class="well form-inline" id="foodstuff_search_form" name="search_form"  action="/recette/liste" method="post">
		<select class="input-medium" name="family" id="family">
    </select>

		<select class="input-large" name="subfamily" id="subfamily">
    </select>

		<input type="text" id="fsname" name="fsname" style="width:120px"  placeholder="Nom de l'aliment" />
	</form>

	<div id="foodstuff_container">
    <div class="pagination pagination-small" id="listpagination"></div>
		<div class="span7 foodstuff-list">
			<ul class="thumbnails">
			</ul>
			<div class='alert alert-danger not-found' style='display: none'>Attention, la liste des aliments disponibles n'est pas exhaustive ; elle comprend surtout des aliments bruts, classés par catégorie.</div>
		</div>
		<div class="span4" style="margin: 0">
			<h4 style="margin-bottom:10px">Composition de la recette</h4>
			{if (!isset($recipe.foodstuffList) || empty($recipe.foodstuffList))}
			<div class="alert alert-error">
				Aucun aliment.
			</div>
			{else}
				<ul class="nav nav-tabs nav-stacked">
					{foreach $recipe.foodstuffList as $fs}
						<li class="clearfix" style="cursor:pointer">
							<a href="javascript:showFoodstuffDetail({$fs.foodstuff.id}, {if (isset($fs.foodstuff.synonym))}{$fs.foodstuff.synonym_id}{else}null{/if}, {$fs.recipeFoodstuffId})" style="color: #000;font-size:12px">
								<div style="float:left;height:7px;font-size:4px;margin:4px 5px 0 0" class="label fam{if (isset($fs.foodstuff.infos))}{$fs.foodstuff.infos.0.family_group_id}{/if}">&nbsp;</div>
								<span>
									{$fs.quantity} {$fs.unit}
									<strong>
									{\mod\repasrc\Recipe::getFoodstuffLabel($fs)}
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
