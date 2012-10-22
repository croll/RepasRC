{extends tplextends('repasrc/container')}

{block name='webpage_head' append}
	{js file="/mod/repasrc/js/menu.js"}
{/block}

{block name='main-container-title'}
	<h1>{t d='repasrc' m='Comparaison de menus'}</h1>
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
		
		<h2 style="margin-bottom: 3px">{$menu.label|ucfirst}</h2>

	{* *************************
	 * Tab datas
	 ************************* *}
		<div class="tab-pane active" id="numbers">

			<div class="span8">

				<div style="margin: 15px 0 20px 0px; font-size: 16px">
					{if isset($menu.totalPrice.vatin) && !empty($menu.totalPrice.vatin)}	
						<div style="margin:10px 0">Montant total pour les aliments renseignés en prix TTC: <strong>{$menu.totalPrice.vatin} €/Kg</strong></div>
					{/if}
					{if isset($menu.totalPrice.vatout) && !empty($menu.totalPrice.vatout)}	
						<div style="margin:10px 0">Montant total pour les aliments renseignés en prix HT: <strong>{$menu.totalPrice.vatout} €/Kg</strong></div>
					{/if}
					{if isset($menu.price) && !empty($menu.price)}	
						<div style="margin:10px 0 30px 0">Prix par personne défini pour le menu: <strong>{$menu.price|print_r} €/Kg</strong></div>
					{/if}
				</div>

				{* RESUME TABLE *}
				<h3 style="margin:20px 0 10px 0">Résumé des informations</h3>

				<table class="table table-bordered">
					<thead>
						<tr>
							<th>Menu</th>
							<th>Empreinte écologique foncière pour une personne</th>
							<th>Distance parcourue par les aliments</th>
							<th>Empreinte écologique foncière du transport</th>
							<th>Prix par personne</th>
						</tr>
					</thead>
					<tbody>
					{foreach $menuList as $menu}
						<tr>
							<td>
								<a href="javascript:void(0)" onclick="showMenuDetail({$menu.id}, true)">{$menu.label}</a>
							</td>
							<td>
								{$menu.transport.footprint} m²g
							</td>
							<td>
								{if empty($menu.transport.distance)}
									-
								{else}
									{$menu.transport.distance} Km
								{/if}
							</td>
							<td>
								{if empty($menu.transport.footprint)}
									-
								{else}
									{$menu.footprint} m²g
								{/if}
							</td>
							<td>
								{if isset($menu.price) && !empty($menu.price)}
									{$menu.price} €
								{else if !empty($menu.totalPrice.vatin) || !empty($menu.totalPrice.vatout)}
									{if !empty($menu.totalPrice.vatin)}
										HT: {$menu.totalPrice.vatin} €
									{/if}
									{if !empty($menu.totalPrice.vatout)}
										TTC: {$menu.totalPrice.vatout} €
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
				<h3 style="margin:40px 0 10px 0">Information à propos des recettes</h3>

				<table class="table table-bordered">
					<thead>
						<tr>
							<th>Menu</th>
							<th>Empreinte écologique foncière du menu</th>
							<th>Recettes</th>
							<th>Empreinte écologique foncière par recette</th>
						</tr>
					</thead>
					<tbody>
					{foreach $menuList as $menu}
						{foreach $menu.recipesList as $recipe}
						<tr>
								{if $recipe@index == 0}
								<td rowspan="{$recipe.foodstuffList|sizeof}">
									<a href="javascript:void(0)" onclick="showMenuDetail({$menu.id}, true)">{$menu.label}</a>
								</td>
								{/if}
								<td>{$recipe.portions} 
									{$recipe.label}
								</td>
								<td>
									{if !empty($recipe.footprint)}
										{math equation="round(x * (y/z),3)" x=$recipe.footprint y=$recipe.persons z=$menu.eaters} m²g
									{else}
										-
									{/if}
								</td>
							</tr>
							{/foreach}
						{/foreach}
					</tbody>
				</table>
			</div>
	
			<div class="span3" style="margin: 0 0 0 30px">

				<h3 style="margin-bottom:10px"> sélectionnées</h3>
				{if (!is_array($menuCompareList) || sizeof($menuCompareList) < 1)}
				<div class="alert alert-error">
					Aucun menu.
				</div>
				{else}
					<ul class="nav nav-tabs nav-stacked">
						{foreach $menuCompareList as $mid}
							<li class="clearfix" style="cursor:pointer;width:270px">
								<a href="javascript:void(0)">
									<span>
										<strong onclick="showRecipeDetail({$mid}, true)">
											{\mod\repasrc\Menu::getNameFromId($mid)}
										</strong>
										<span style="margin-left:5px"><i onclick="window.document.location.href='/menu/comparer/del/{$mid}'" class="icon icon-remove"></i></span>
									</span>
								</a>
							</li>
						{/foreach}
					</ul>
					<div><a style="margin-left: 50px" href="/menu/liste">Ajouter d'autres menus</a></div>
				{/if}

			</div>

		</div>

		{* *************************
		 * Tab graphs
		 ************************* *}
				<div class="tab-pane" id="graphs">
					{if $noprice}
						<div class="alert alert-danger">
							Aucune information de prix a été renseignée pour les aliments composant le menu.
						</div>
					{else}

						<script type="text/javascript" src="https://www.google.com/jsapi"></script>
						<script type="text/javascript">

						google.load('visualization', '1.0', { 'packages':['corechart'] } );
						google.setOnLoadCallback(drawChart);

						function drawChart() {
								
								{if isset($dataMenuFootprint)}
									var dataMenuFootprint = new google.visualization.DataTable({$dataMenuFootprint});

									var optionsMenuFootprint = { 
										'title':'Empreinte écologique foncière des aliments',
										'width':800,
										'height':400 
									};

									var menuFootprint = new google.visualization.ColumnChart(document.getElementById('chart_div0'));
									menuFootprint.draw(dataMenuFootprint, optionsMenuFootprint);
								{/if}
								
								{if isset($dataFootprintCol)}
									var dataFootprintCol = new google.visualization.DataTable({$dataFootprintCol});

									var optionsFootprintCol = { 
										'title':'Empreinte écologique foncière des aliments',
										'width':800,
										'height':400 
									};

									var chart1 = new google.visualization.ColumnChart(document.getElementById('chart_div1'));
									chart1.draw(dataFootprintCol, optionsFootprintCol);
								{/if}
								
								{if isset($dataTransportCol)}
									var dataTransportCol = new google.visualization.DataTable({$dataTransportCol});

									var optionsTransportCol = { 
										'title':'Empreinte écologique foncière des transports',
										'width':800,
										'height':400 
									};

									var chart2 = new google.visualization.ColumnChart(document.getElementById('chart_div2'));
									chart2.draw(dataTransportCol, optionsTransportCol);
								{/if}
								
						}
						</script>

						<div id="chart_div0"></div>
						<div id="chart_div1"></div>
						<div id="chart_div2"></div>
					{/if}

			</div>

		</div>






{/block}
