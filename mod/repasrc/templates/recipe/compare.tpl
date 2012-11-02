{extends tplextends('repasrc/container')}

{block name='webpage_head' append}
	{js file="/mod/repasrc/js/recipe.js"}
	{if empty($oldbrowser)}
	    <script type="text/javascript" src="http://canvg.googlecode.com/svn/trunk/rgbcolor.js"></script> 
	    <script type="text/javascript" src="http://canvg.googlecode.com/svn/trunk/canvg.js"></script>
	{/if}
{/block}

{block name='main-container-title'}
	<h1>{t d='repasrc' m='Comparaison de recettes'}</h1>
{/block}

{block name='main-container-content'}

	{* *************************
	 * Tabs
	 ************************* *}
	<ul class="nav nav-tabs">
		<li class="active"><a href="#numbers" data-toggle="tab">Chiffres</a></li>
		<li><a href="#graphs" data-toggle="tab">Graphiques</a></li>
	</ul>

	<div class="tab-content" style="width: 1100px">
		
		<h2 style="margin-bottom: 3px">{$recipe.label|ucfirst}</h2>

	{* *************************
	 * Tab datas
	 ************************* *}
		<div class="tab-pane active" id="numbers">

			<div class="span8">

				<div style="margin: 15px 0 20px 0px; font-size: 16px">
					{if isset($recipe.totalPrice.vatin) && !empty($recipe.totalPrice.vatin)}	
						<div style="margin:10px 0">Montant total pour les aliments renseignés en prix TTC: <strong>{$recipe.totalPrice.vatin} €/Kg</strong></div>
					{/if}
					{if isset($recipe.totalPrice.vatout) && !empty($recipe.totalPrice.vatout)}	
						<div style="margin:10px 0">Montant total pour les aliments renseignés en prix HT: <strong>{$recipe.totalPrice.vatout} €/Kg</strong></div>
					{/if}
					{if isset($recipe.price) && !empty($recipe.price)}	
						<div style="margin:10px 0 30px 0">Prix par personne défini pour la recette: <strong>{$recipe.price|print_r} €/Kg</strong></div>
					{/if}
				</div>

				{* RESUME TABLE *}
				<h3 style="margin:20px 0 10px 0">Résumé des informations</h3>

				<table class="table table-bordered">
					<thead>
						<tr>
							<th>Recette</th>
							<th>Empreinte écologique foncière pour une personne</th>
							<th>Distance parcourue par les aliments</th>
							<th>Empreinte écologique foncière du transport</th>
							<th>Prix par personne</th>
						</tr>
					</thead>
					<tbody>
					{foreach $recipeList as $recipe}
						<tr>
							<td>
								<a href="javascript:void(0)" onclick="showRecipeDetail({$recipe.id}, true)">{$recipe.label}</a>
							</td>
							<td>
								{$recipe.footprint} m²g
							</td>
							<td>
								{if empty($recipe.transport.total.distance)}
									-
								{else}
									{$recipe.transport.total.distance} Km
								{/if}
							</td>
							<td>
								{if empty($recipe.transport.total.footprint)}
									-
								{else}
									{$recipe.transport.total.footprint} m²g
								{/if}
							</td>
							<td>
								{if isset($recipe.price) && !empty($recipe.price)}
									{$recipe.price} €
								{else if !empty($recipe.totalPrice.vatin) || !empty($recipe.totalPrice.vatout)}
									{if !empty($recipe.totalPrice.vatin)}
										Aliments HT: {$recipe.totalPrice.vatin} €
									{/if}
									{if !empty($recipe.totalPrice.vatout)}
										Aliments TTC: {$recipe.totalPrice.vatout} €
									{/if}
								{else}
									-
								{/if}
							</td>
						</tr>
						{/foreach}
					</tbody>
				</table>

				{* Foodstuff TABLE *}
				<h3 style="margin:40px 0 10px 0">Information à propos des aliments</h3>

				<table class="table table-bordered">
					<thead>
						<tr>
							<th>Recette</th>
							<th>Aliments</th>
							<th>Empreinte écologique foncière par personne</th>
							<th>Familles de produits</th>
						</tr>
					</thead>
					<tbody>
					{foreach $recipeList as $recipe}
						{foreach $recipe.foodstuffList as $fs}
						<tr>
								{if $fs@index == 0}
								<td rowspan="{$recipe.foodstuffList|sizeof}">
									<a href="javascript:void(0)" onclick="showRecipeDetail({$recipe.id}, true)">{$recipe.label}</a>
								</td>
								{/if}
								<td>{$fs.quantity} Kg 
									{if (isset($fs.foodstuff.synonym))}
										{$fs.foodstuff.synonym}
									{else}
										{$fs.foodstuff.label}
									{/if}
								</td>
								<td>
									{if !empty($fs.foodstuff.footprint)}
										{math equation="round(x * (y/z),3)" x=$fs.foodstuff.footprint y=$fs.quantity z=$recipe.persons} m²g
									{else}
										-
									{/if}
								</td>
								<td>
									{if isset($fs.foodstuff.infos)}
										{foreach $fs.foodstuff.infos as $info}
											<span class="badge fam{$info.family_group_id}" style="margin: 0px 5px 0 0">{$info.family_group}</span>
										{/foreach}
									{/if}
								</td>
								</tr>
								{/foreach}
						{/foreach}
					</tbody>
				</table>
		
			</div>
	
			<div class="span3" style="margin: 0 0 0 30px">

				<h3 style="margin-bottom:10px">Recettes sélectionnées</h3>
				{if (!is_array($recipeCompareList) || sizeof($recipeCompareList) < 1)}
				<div class="alert alert-error">
					Aucune recette.
				</div>
				{else}
					<ul class="nav nav-tabs nav-stacked">
						{foreach $recipeCompareList as $rid}
							<li class="clearfix" style="cursor:pointer;width:270px">
								<a href="javascript:void(0)">
									<span>
										<strong onclick="showRecipeDetail({$rid}, true)">
											{\mod\repasrc\Recipe::getNameFromId($rid)}
										</strong>
										<span style="margin-left:5px"><i onclick="window.document.location.href='/recette/comparer/del/{$rid}'" class="icon icon-remove"></i></span>
									</span>
								</a>
							</li>
						{/foreach}
					</ul>
					<div><a style="margin-left: 50px" href="/recette/liste">Ajouter d'autres recettes</a></div>
				{/if}

			</div>

		</div>

		{* *************************
		 * Tab graphs
		 ************************* *}
				<div class="tab-pane" id="graphs">
					{if $noprice}
						<div class="alert alert-danger">
							Aucune information de prix a été renseignée pour les aliments composant la recette.
						</div>
					{else}

						<script type="text/javascript" src="https://www.google.com/jsapi"></script>
						<script type="text/javascript">

						google.load('visualization', '1.0', { 'packages':['corechart'] } );
						google.setOnLoadCallback(drawChart);

						function drawChart() {
								
								{if isset($dataFootprintCol)}
									var dataFootprintCol = new google.visualization.DataTable({$dataFootprintCol});

									var optionsFootprintCol = { 
										'title':'Empreinte écologique foncière des aliments',
										'colors' : {$colors},
										'width':800,
										'height':400 
									};

									var chart1 = new google.visualization.ColumnChart(document.getElementById('chart_div'));
									chart1.draw(dataFootprintCol, optionsFootprintCol);
								{/if}
								
								{if isset($dataTransportCol)}
									var dataTransportCol = new google.visualization.DataTable({$dataTransportCol});

									var optionsTransportCol = { 
										'title':'Empreinte écologique des transports',
										'colors' : {$colors},
										'width':800,
										'height':400 
									};

									var chart2 = new google.visualization.ColumnChart(document.getElementById('chart_div2'));
									chart2.draw(dataTransportCol, optionsTransportCol);
								{/if}
								
						}
						</script>

						<div id="chart_div"></div>
			      {if empty($oldbrower)}
			      <div style="width:200px;margin:0 auto 0 auto">
			        <a href="javascript:void(0)" onclick="saveAsImg('chart_div', '{$recipe.label} - Empreinte écologique foncières des aliments')">Enregistrer le graphique</a>
			      </div>
			      {else}
			        <div class="help" code="navigateurimpressionimpossible"></div>
			      {/if}
			      <br /><br /><hr>
						<div id="chart_div2"></div>
			      {if empty($oldbrower)}
			      <div style="width:200px;margin:0 auto 0 auto">
			        <a href="javascript:void(0)" onclick="saveAsImg('chart_div2', '{$recipe.label} - Empreinte des transports')">Enregistrer le graphique</a>
			      </div>
			      {else}
			        <div class="help" code="navigateurimpressionimpossible"></div>
			      {/if}
					{/if}

			</div>

		</div>






{/block}
