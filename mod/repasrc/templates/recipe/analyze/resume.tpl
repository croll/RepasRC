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
	<div style="margin: 15px 0 20px 0px; font-size: 16px">
		<div>Composante: <strong>{$recipe.component}</strong></div>
		<div>Nombre de convives: <strong>{$recipe.persons}</strong></div>
		<div>Empreinte écologique foncière: <strong>{$recipe.footprint}</strong> gha</div>
	</div>

	{foreach $recipe.foodstuffList as $fs}
	<div style="margin: 0 0 20px 0px">
		<div style="font-size: 18px">
			{$fs.quantity} {$fs.unit}
			<strong>
				{if (isset($fs.foodstuff.synonym))}
					{$fs.foodstuff.synonym}
				{else}
					{$fs.foodstuff.label}
				{/if}
			</strong>
		</div>
		<div>
		{foreach $fs.foodstuff.infos as $info}
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
			<div>Empreinte écologique foncière: <strong>{$fs.foodstuff.footprint} m²/Kg</strong></div>
			<div>Empreinte écologique foncière pour la recette: <strong>{math equation="x * y" x=$fs.foodstuff.footprint y=$fs.quantity} m²</strong></div>
			{if (isset($fs.origin) && !empty($fs.origin.0.zonelabel))}
				<div>Origine: <strong>{$fs.origin.0.zonelabel}</strong></div>
			{else if (isset($fs.origin) && !empty($fs.origin.0.location))} 
				{if $fs.origin.0.location == 'LOCAL'}
					<div>Origine: <strong>Locale</strong></div>
				{else if $fs.origin.0.location == 'REGIONAL'}
					<div>Origine: <strong>Locale</strong></div>
				{else if $fs.origin.0.location == 'FRANCE'}
					<div>Origine: <strong>France</strong></div>
				{else if $fs.origin.0.location == 'EUROPE'}
					<div>Origine: <strong>Europe</strong></div>
				{else if $fs.origin.0.location == 'WORLD'}
					<div>Origine: <strong>Monde</strong></div>
				{/if}
			{/if}
			{if (isset($fs.price) && !empty($fs.price))}
				<div>Prix: <strong>{$fs.price} {if $fs.vat == 0}HT{else}TTC{/if}</strong></div>
			{/if}

			{if ($info.family_group == 'Fruits' || $info.family_group == 'Légumes') && $fs.foodstuff.seasonality}
			<div style="margin-top:10px">Saisonnalité: <span></span></div>
				<div class="btn-group">
				{foreach $fs.foodstuff.seasonality as $month=>$s}
					{if $s == 0}
						{if !empty($recipe.consumptionmonth) && $s@index+1 == $recipe.consumptionmonth}
							<span class="btn btn-danger"><div style="border-bottom: 2px solid #fff">{$month}</div></span>
						{else}
							<span class="btn btn-danger">{$month}</span>
						{/if}
					{else if $s == 1}
						{if !empty($recipe.consumptionmonth) && $s@index+1 == $recipe.consumptionmonth}
							<span class="btn btn-warning"><div style="border-bottom: 2px solid #fff">{$month}</div></span>
						{else}
							<span class="btn btn-warning">{$month}</span>
						{/if}
					{else}
						{if !empty($recipe.consumptionmonth) && $s@index+1 == $recipe.consumptionmonth}
							<span class="btn btn-success"><div style="border-bottom: 2px solid #fff">{$month}</div></span>
						{else}
							<span class="btn btn-success">{$month}</span>
						{/if}
					{/if}
				{/foreach}
				</div>
			{/if}

		</div>
	</div>
	{/foreach}
{/block}
