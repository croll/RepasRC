<div style="margin: 0 0 20px 20px; font-size: 16px">
	<div style="float:left;width: 100px">
		{if isset($foodstuff.0.synonym)}
			<img style="width:90px" src="/mod/repasrc/foodstuffImg/s{$foodstuff.0.synonym_id}.jpg" />
		{else}
			<img style="width:90px" src="/mod/repasrc/foodstuffImg/{$foodstuff.0.id}.jpg" />
		{/if}
	</div>
	<div style="float:left;padding-top:10px">
		<div>Identifiant: <strong>{$foodstuff.0.id}</strong></div>
		<div>Empreinte écologique foncière pour 1Kg: <strong>{$foodstuff.0.footprint}</strong> gha</div>
		{if isset($foodstuff.0.synonym)}
			<div class="alert alert-warn" style="margin-top: 5px;width: 457px">
				Cet aliment est basé sur l'aliment <strong>{$parent.0.label}</strong>
			</div>
		{/if}
	</div>
	<div class="clearfix"></div>
</div>

<div style="margin: 0 0 0px 20px">
	<div>
	{foreach $foodstuff.0.infos as $info}
		<span class="badge fam{$info.family_group_id}" style="margin: 0px 5px 0 0">{$info.family_group}</span>
	{/foreach}
	</div>
	<div style="font-size: 14px">
		{if (!empty($foodstuff.0.conservation))}
			<div>Mode de conservation: <strong>{$foodstuff.0.conservation}</strong></div>
		{/if}
		{if (!empty($foodstuff.0.production))}
			<div>Mode de production: <strong>{$foodstuff.0.production}</strong></div>
		{/if}
		{if $info.family_group == 'Fruits' || $info.family_group == 'Légumes'}
		<div style="margin-top:10px">Saisonnalité: <span></span></div>
			<div class="btn-group">
					<span class="btn btn-small">Jan</span>
					<span class="btn">Fev</span>
					<span class="btn btn-danger">Mar</span>
					<span class="btn btn-warning">Avr</span>
					<span class="btn btn-success">Mai</span>
					<span class="btn btn-success">Jui</span>
					<span class="btn btn-success">Jui</span>
					<span class="btn btn-success">Aou</span>
					<span class="btn btn-success">Sep</span>
					<span class="btn">Oct</span>
					<span class="btn">Nov</span>
					<span class="btn">Dec</span>
			</div>
		{/if}
	</div>
</div>
<div class="form-actions" style="margin-top:30px">
	{if ($recipeId)}
		{if isset($foodstuff.0.synonym)}
			<a class="btn" href="javascript:void(0)" onclick="addFoodstuffToRecipe({$parent.0.id}, {$foodstuff.0.synonym_id})">Ajouter l'aliment à la recette</a>
		{else}
			<a class="btn" href="javascript:void(0)" onclick="addFoodstuffToRecipe({$foodstuff.0.id}, null)">Ajouter l'aliment à la recette</a>
		{/if}
	{/if}
	<a class="btn btn-inverse" href="javascript:void(0)" onclick="modalWin.hide()">Fermer</a>
</div>
