{extends tplextends('repasrc/recipe_edit')}

{block name='webpage_head' append}
	{js file="/mod/repasrc/js/recipe.js"}
{/block}

{block name='recipe_title'}
	<h1>{t d='repasrc' m='Composer une recette'}</h1>
	<p class="lead">{t d='repasrc' m='Sélectionnez les aliments composants votre recette et définissez leur grammage.'}</p>
{/block}

{block name='recipe_content'}
	<div class="alert alert-info">
		<a class="close" data-dismiss="alert">×</a>
		Cliquez sur un aliment pour l'ajouter à votre recette.<br />
		Vous pouvez chercher dans la base des aliments en filtrant par famille ou par nom.
	</div> 

	<form class="well form-inline" id="foodstuff_search_form" name="search_form"  action="/recette/liste" method="post">
		<select class="input-medium" name="family" id="family">
    </select>

		<select class="input-large" name="subfamily" id="subfamily">
    </select>

		<input type="text" id="fsname" name="fsname" style="width:120px"  placeholder="Nom de l'aliment" />
	</form>

	<div id="foodstuff_container">
		<div class="span6 foodstuff-list">
			<ul class="thumbnails">
			</ul>
		</div>
		<div class="span3" style="margin: 0">
			<h3 style="margin-bottom:10px">Composition de la recette</h3>
			{if (!isset($recipeFoodstuffList))}
			<div class="alert alert-error">
				Aucun aliment.
			</div>
			{else}
				<ul class="nav nav-tabs nav-stacked">
					{foreach $recipeFoodstuffList as $fs}
						<li class="clearfix" style="cursor:pointer">
							<a style="color: #000;font-size:12px">
								<div style="float:left;height:7px;font-size:4px;margin:4px 5px 0 0" class="label fam{if (isset($fs.foodstuff.0.infos))}{$fs.foodstuff.0.infos.0.family_group_id}{/if}">&nbsp;</div>
								<span style="">
									{$fs.quantity} {$fs.unit}
									<strong>
									{if (isset($fs.foodstuff.0.synonym))}
										{$fs.foodstuff.0.synonym}
									{else}
										{$fs.foodstuff.0.label}
									{/if}
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
