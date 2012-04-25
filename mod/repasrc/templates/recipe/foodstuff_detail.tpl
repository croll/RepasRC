<div style="padding: 20px 20px 0 20px">

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
			<div>Empreinte écologique foncière pour 1Kg: <strong>{$foodstuff.0.footprint}</strong> gha</div>
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

	<div id="foodstuff-form-comtainer" style="margin-top:20px;width:90%">

		<div class="alert alert-info">
			<a class="close" data-dismiss="alert">×</a>
			<p>
				En fonction des modules choisis, il vous est possible de saisir différentes informations.<br />
				Chaque onglet ci dessous correpond à un module.
			</p>
		</div> 

		{form mod="repasrc" file="templates/recipe/foodstuff.json" defaultValues=\mod\repasrc\Foodstuff::getFromRecipe($recipeId, $foodstuff.0.id, $foodstuff.0.synonym_id)}
			<fieldset>
				<div class="control-group">
					<label class="control-label">{t d='repasrc' m="Nom de la recette"}</label>
					<div class="controls">
						{$foodstuffForm.label}
					</div>
				</div>
				<div class="form-actions">
						{$foodstuffForm.submit}
						{$foodstuffForm.cancel}
				</div>
				<input type="hidden" name="recipeId" value="{$recipeId}" />
			</fieldset>
				
		{/form}
		<ul class="nav nav-tabs">
			<li><a href="#quantity" data-toggle="tab">Quantité</a></li>
			<li><a href="#conservation" data-toggle="tab">Conservation</a></li>
			<li><a href="#transport" data-toggle="tab">Transport</a></li>
		</ul>

		<div class="tab-content">
			<div class="tab-pane active" id="quantity">1</div>
			<div class="tab-pane" id="conservation">2</div>
			<div class="tab-pane" id="transport">3</div>
		</div>
	</div>

	<div id="popup-actions" class="form-actions" style="margin-top:80px">
		{if ($recipeId)}
				<a class="btn" href="javascript:void(0)" onclick="addFoodstuffToRecipe({$parent.0.id}, {if isset($foodstuff.0.synonym)}{$foodstuff.0.synonym_id}{else}null{/if})">Ajouter l'aliment à la recette</a>
		{/if}
		<a class="btn btn-inverse" href="javascript:void(0)" onclick="modalWin.hide()">Fermer</a>
	</div>

</div>
