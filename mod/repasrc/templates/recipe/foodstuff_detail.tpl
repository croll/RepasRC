<style type="text/css">
	.tab-content {
		margin-top: 0px;
		padding: 20px 0 0 10px;
		border: 1px solid #DDD;
		border-top: none;
	}
</style>

<div style="width:650px;margin: 0 auto">

	<div style="font-size: 16px">
		<div style="float:left;width: 100px">
			{if isset($foodstuff.0.synonym)}
				<img style="width:90px" src="/mod/repasrc/foodstuffImg/s{$foodstuff.0.synonym_id}.jpg" />
			{else}
				<img style="width:90px" src="/mod/repasrc/foodstuffImg/{$foodstuff.0.id}.jpg" />
			{/if} 
		</div>
		<div style="float:left;padding-top:10px">
			<div>Identifiant: <strong>{$foodstuff.0.id}</strong></div>
			<div>Empreinte écologique foncière: <strong>{$foodstuff.0.footprint}</strong> m²/Kg</div>
			{if isset($foodstuff.0.synonym)}
				<div class="alert alert-warn" style="margin-top: 5px;width: 457px">
					Cet aliment est basé sur l'aliment <strong>{$parent.0.label}</strong>
				</div>
			{/if}
		</div>
		<div class="clearfix"></div>
	</div>

	<div>
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
			{if ($info.family_group == 'Fruits' || $info.family_group == 'Légumes') && $foodstuff.0.seasonality}
			<div style="margin-top:10px">Saisonnalité: <span></span></div>
				<div class="btn-group">
				{foreach $foodstuff.0.seasonality as $month=>$s}
						{if $s == 0}
							{if $s@index+1 == $recipe.consumptionmonth}
								<span class="btn btn-danger"><div style="border-bottom: 2px solid #fff">{$month}</div></span>
							{else}
								<span class="btn btn-danger">{$month}</span>
							{/if}
						{else if $s == 1}
							{if $s@index+1 == $recipe.consumptionmonth}
								<span class="btn btn-warning"><div style="border-bottom: 2px solid #fff">{$month}</div></span>
							{else}
								<span class="btn btn-warning">{$month}</span>
							{/if}
						{else}
							{if $s@index+1 == $recipe.consumptionmonth}
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

	<div id="foodstuff-form-comtainer" style="margin-top:20px">

		<div class="alert alert-info">
			<a class="close" data-dismiss="alert">×</a>
			<p>
				En fonction des modules choisis, il vous est possible de saisir différentes informations.<br />
				Veuillez renseigner les informations demandées dans chacun des onglets ci dessous pour avoir une analyse la plus complète de votre recette.
			</p>
		</div> 

			{assign var='defaultValues' value=\mod\repasrc\Foodstuff::getFromRecipe($recipeFoodstuffId)}
			{form mod="repasrc" file="templates/recipe/foodstuff.json" defaultValues=$defaultValues}
			<ul class="nav nav-tabs" style="margin-bottom: 0px">
				<li><a href="#quantity" data-toggle="tab">Quantité</a></li>
				{if (isset($modulesList) && $modulesList.production == 1)}
					<li><a href="#production" data-toggle="tab">Production / Conservation</a></li>
				{/if}
				{if (isset($modulesList) && $modulesList.transport == 1)}
					<li><a href="#transport" data-toggle="tab">Transport</a></li>
				{/if}
				{if (isset($modulesList) && $modulesList.price == 1)}
					<li><a href="#price" data-toggle="tab">Prix</a></li>
				{/if}
			</ul>
			<div class="tab-content" style="padding-bottom:18px">
				<div class="tab-pane" id="quantity">
					<fieldset>
						<div class="control-group">
							<label class="control-label" for="prependInput" style="width: 60px">{t d='repasrc' m="Quantité"}</label>
							<div class="controls" style="margin-left:75px">
								<div class="input-append">
									{$foodstuffForm.quantity}
									<span class="add-on">Kg</span>
								</div>
							</div>
						</div>
					</fieldset>
				</div>
				{if (isset($modulesList) && $modulesList.production == 1)}
					<div class="tab-pane" rel="les informations de production" id="production">
						<fieldset>
							<div class="control-group">
								<label class="control-label" style="width: 150px">{t d='repasrc' m="Mode de production"}</label>
								<div class="controls" style="margin-left:160x">
									{$foodstuffForm.production}
								</div>
							</div>
							<div class="control-group">
								<label class="control-label" style="width: 150px">{t d='repasrc' m="Mode de conservation"}</label>
								<div class="controls" style="margin-left: 160px">
									{$foodstuffForm.conservation}
								</div>
							</div>
						</fieldset>
					</div>
				{/if}
				{if (isset($modulesList) && $modulesList.transport == 1)}
					<div class="tab-pane" rel="les informations de production/conservation" id="transport">
						<fieldset>
							<div class="control-group">
								<label class="control-label" style="width: 50px">{t d='repasrc' m="Origine"}</label>
								<div class="controls" style="margin-left:75px">
									{$foodstuffForm.location}
								</div>
							</div>
							<div class="control-group" id="location_steps" style="display:none">
								<label class="control-label" style="width: 50px">{t d='repasrc' m="Etapes"}</label>
								<div class="controls" style="margin-left:75px">
									<input type="text" id="steps_input" />
									<div id="steps" style="margin-top:10px">
										{assign var="steps" value=""}
										{if isset($defaultValues.origin) && is_array($defaultValues.origin) && sizeof($defaultValues.origin) > 0}
											{foreach $defaultValues.origin as $step}
												{if isset($step.zonelabel)}
													<div class="step step{$step.zoneid}"><span>{$step.zonelabel}</span><i class="icon icon-remove" onclick="removeFoodstuffStep({$step.zoneid})"></i></div>
												{/if}
												{assign var="steps" value=$step}
											{/foreach}
										{/if}
									</div>
								</div>
							</div>
						</fieldset>
					</div>
				{/if}
				{if (isset($modulesList) && $modulesList.price == 1)}
					<div class="tab-pane" rel="les informations de prix" id="price">
						<fieldset>
							<div class="control-group">
								<label class="control-label" style="width: 50px">{t d='repasrc' m="Prix"}</label>
								<div class="controls" style="margin-left:75px">
								<div class="input-append">
									{$foodstuffForm.price}
									<span class="add-on">au Kg</span>
								</div>
									{$foodstuffForm.vat}
								</div>
							</div>
						</fieldset>
					</div>
				{/if}
			</div>

		<div id="popup-actions" class="form-actions" style="margin-top:-16px">
			{if (isset($recipe.id))}
				<input type="hidden" name="recipeId" value="{$recipe.id}"></input>
				<input type="hidden" id="recipeFoodstuffId" name="recipeFoodstuffId" value="{$recipeFoodstuffId}"></input>
				<input type="hidden" name="foodstuffId" value="{$foodstuff.0.id}"></input>
				<input type="hidden" name="synonymId" value="{if isset($foodstuff.0.synonym)}{$foodstuff.0.synonym_id}{/if}"></input>
				<input type="hidden" id="origin_steps" name="origin_steps" value="{$steps}"></input>
				<input type="hidden" name="action" value="{$action}"></input>
				{if isset($recipeFoodstuffId) && !empty($recipeFoodstuffId)}
					{$foodstuffForm.submitEdit}
					{$foodstuffForm.cancel}
					{$foodstuffForm.del}
				{else}
					{$foodstuffForm.submitAdd}
					{$foodstuffForm.cancel}
				{/if}
			{/if}
		</div>
		{/form}

	</div>

</div>
