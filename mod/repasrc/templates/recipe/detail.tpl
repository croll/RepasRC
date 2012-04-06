<div style="margin: 0 0 20px 20px; font-size: 16px">
	<div>Composante: <strong>{$recipe.component}</strong></div>
	<div>Nombre de convives: <strong>{$recipe.persons}</strong></div>
	<div>Empreinte écologique foncière: <strong>{$recipe.footprint}</strong> gha</div>
</div>

{foreach $foodstuffList as $fs}
<div style="margin: 0 0 20px 20px">
	<div style="font-size: 18px">
		{$fs.quantity} {$fs.unit}
		<strong>
			{if (isset($fs.foodstuff.0.synonym))}
				{$fs.foodstuff.0.synonym}
			{else}
				{$fs.foodstuff.0.label}
			{/if}
		</strong>
	</div>
	<div>
	{foreach $fs.foodstuff.0.infos as $info}
		<span class="badge fam{$info.family_group_id}" style="margin: 0px 5px 0 0">{$info.family_group}</span>
	{/foreach}
	</div>
	<div style="font-size: 14px">
		{if (!empty($fs.conservation))}
			<div>Mode de conservation: <strong>{$fs.conservation}</strong></div>
		{/if}
		{if (!empty($fs.production))}
			<div>Mode de production: <strong>{$fs.production}</strong></div>
		{/if}
		<div>Empreinte écologique foncière (donnée générale): <strong>{$fs.foodstuff.0.footprint} gah</strong></div>
		<div>Empreinte écologique foncière pour la recette: <strong>{math equation="x * y" x=$fs.foodstuff.0.footprint y=$fs.quantity} gah</strong></div>
		{if $info.family_group == 'Fruits' || $info.family_group == 'Légumes'}
		<div>Saisonnalité: <span></span></div>
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
{/foreach}
<div class="form-actions" style="margin-top:30px">
	<a class="btn" href="/recette/edition/aliments/{$recipe.id}">Modifier la recette</a>
	<a class="btn" href="/recette/edition/aliments/{$recipe.id}">Ajouter la recette pour comparaison</a>
	<a class="btn btn-inverse" href="javascript:void(0)" onclick="modalWin.hide()">Fermer</a>
</div>
