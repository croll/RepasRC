{extends tplextends('repasrc/container')}

{block name='webpage_head' append}
	{js file="/mod/repasrc/js/menu.js"}
{/block}

{block name='main-container-title'}
	<h1>{t d='repasrc' m='Liste de menus'}</h1>
	<p class="lead">{t d='repasrc' m='Recherchez parmi les menus disponibles en libre consultation.'}</p>
{/block}

{block name='main-container-content'}
<form class="well form-inline" id="menu_search_form" name="menu_search_form"  action="/menu/liste" method="post">

	<select name="type" id="type">
   <option value="me">Vos Menus</option>
   <option value="STALLION">Menus "Etalon"</option>
   <option value="OTHER">Menus partagés par les autres RC</option>
   <option value="ALL">Tous les menus</option>
  </select>
			
	<input type="text" id="label" name="label" class="input-medium" placeholder="Nom du menu" />

</form>

	<div id="menu_container" class="clearfix">
		<div class="span8 menu-list">
      <div class="pagination pagination-small" id="listpagination"></div>
			<div class='alert alert-danger not-found' style='display: none'>Aucun menu ne correspond aux critères de recherche.</div>
			<ul class="thumbnails">
			</ul>
		</div>
		<div class="span3">
			<h3 style="margin-bottom:10px">Menus sélectionnés</h3>
			{if (!is_array($menuList) || sizeof($menuList) < 1)}
			<div class="alert alert-error">
				Aucun menu.
			</div>
			{else}
				<ul class="nav nav-tabs nav-stacked">
					{foreach $menuList as $mid}
						<li class="clearfix" style="cursor:pointer;width:270px">
							<a href="javascript:void(0)">
								<span>
									<strong onclick="showMenuDetail({$mid}, true)">
										{\mod\repasrc\Menu::getNameFromId($mid)}
									</strong>
									<span style="margin-left:5px"><i onclick="window.document.location.href='/menu/liste/del/{$mid}'" class="icon icon-remove"></i></span>
								</span>
							</a>
						</li>
						{if $mid@index == 1}
							{assign var="showCompareButton" value="true"}
						{/if}
					{/foreach}
				</ul>
				{if isset($showCompareButton) && $showCompareButton}
					<a style="margin-left:40px" href="/menu/comparer" class="btn btn-primary">Comparer les menus</a>
				{/if}
			{/if}
		</div>
	</div>
{/block}
