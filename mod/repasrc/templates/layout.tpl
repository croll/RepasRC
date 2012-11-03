{extends tplextends('webpage/webpage_main_html5')}

{block name='webpage_head'}
	<meta charset="utf-8">
  <title>REPAS-RC</title>
	<script>
  {if isset($smarty.session.displayHelp) && $smarty.session.displayHelp == 1}
		var displayHelp = {$smarty.session.displayHelp};
  {else}
		var displayHelp = 1;
	{/if}
	</script>
  <link rel="shortcut icon" href="/mod/repasrc/favicon.ico" type="image/x-icon" />
  <!--[if lt IE 9]>
    <script src="/mod/cssjs/ext/html5shiv/html5.js"></script>
  <![endif]-->
	{js file="/mod/cssjs/js/mootools.js"}
	{js file="/mod/cssjs/js/mootools.more.js"}
	{js file="/mod/cssjs/js/captainhook.js"}
	{js file="/mod/cssjs/js/Modal.js"}
	{js file="/mod/cssjs/js/chtable.js"}
	{js file="/mod/cssjs/js/chfilter.js"}
	{js file="/mod/cssjs/js/messageclass.js"}
	{js file="/mod/cssjs/js/message.js"}
	{js file="/mod/cssjs/js/chbootstrap.js"}
	{js file="/mod/cssjs/js/spin.js"}
	{js file="/mod/repasrc/js/repasrc.js"}
	{js file="/mod/page/js/page.js"}
	{js file="/mod/repasrc/ext/Bootstrap.js"}
	{js file="/mod/repasrc/ext/Bootstrap.Tooltip.js"}
	{js file="/mod/repasrc/ext/Bootstrap.Popover.js"}
	{js file="/mod/repasrc/ext/MooDatePicker/js/MooDatePicker.js"}
	{js file="/mod/repasrc/js/help.js"}
	{js file="/mod/cssjs/ext/meioautocomplete/meioautocomplete.js"}
	{css file="/mod/cssjs/ext/twitter-bootstrap/css/bootstrap.css"}
	{css file="/mod/repasrc/css/bootstrap-responsive.css"}
	{css file="/mod/cssjs/css/Modal.css"}
	{css file="/mod/cssjs/css/mypaginate.css"}
	{css file="/mod/page/css/page.css"}
	{css file="/mod/repasrc/ext/MooDatePicker/css/MooDatePicker.css"}
	{css file="/mod/cssjs/ext/meioautocomplete/meioautocomplete.css"}
	{css file="/mod/repasrc/css/repasrc.css"}
{/block}

{block name='webpage_body'}
	<div id="repasrc_container">
		<div class="navbar navbar-fixed-top">
			<div class="navbar-inner">
				<div class="container-fluid">
					<div class="container">
						<span id="spinnercontainer"></span>
						<a class="brand" href="#">REPAS-RC</a>
						<ul class="nav">
							{if !\mod\user\Main::userIsLoggedIn()}
								<li><a href="/">{t d='repasrc' m='Accueil'}</a></li>
							{/if}
							{if \mod\user\Main::userIsLoggedIn()}
							{* Informations *}
							<li><a href="/compte">{t d='repasrc' m='Vos informations'}</a></li>
							{* recettes*}
							<li class="dropdown" onclick="this.toggleClass('open');">
								<a href="#" class="dropdown-toggle" data-toggle="dropdown">{t d='repasrc' m='Recettes'}<b class="caret"></b></a>
								<ul class="dropdown-menu">
									<li><a class="top-btn" href="/recette/liste"><i class="icon-book glyph-white"></i>  {t d='repasrc' m='Livre de recettes'}</a></li>
									<li><a class="top-btn" href="/recette/edition/modules"><i class="icon-plus glyph-white"></i>  {t d='repasrc' m='Composer une recette'}</a></li>
									{*
									<li><a class="top-btn" href="/recette/importer"><i class="icon-upload glyph-white"></i>  {t d='repasrc' m='Importer une recette'}</a></li>
									<li><a class="top-btn" href="/recette/exporter"><i class="icon-download glyph-white"></i>  {t d='repasrc' m='Exporter une recette'}</a></li>
									*}
								</ul>
							</li>
							{* menus *}
							<li class="dropdown" onclick="this.toggleClass('open');">
								<a href="#" class="dropdown-toggle" data-toggle="dropdown">{t d='repasrc' m='Menus'}<b class="caret"></b></a>
								<ul class="dropdown-menu">
									<li><a class="top-btn" href="/menu/liste"><i class="icon-th-list glyph-white"></i>  {t d='repasrc' m='Lister les menus'}</a></li>
									<li><a class="top-btn" href="/menu/edition/modules"><i class="icon-plus glyph-white"></i>  {t d='repasrc' m='Composer un menu'}</a></li>
								</ul>
							</li>
							{* plan alimentaire *}
							{*
							<li class="dropdown" onclick="this.toggleClass('open');">
								<a href="#" class="dropdown-toggle" data-toggle="dropdown">{t d='repasrc' m='Plan alimentaire'}<b class="caret"></b></a>
								<ul class="dropdown-menu">
									<li><a class="top-btn" href="/planalimentaire/lister"><i class="icon-th-list glyph-white"></i>  {t d='repasrc' m='Lister les plans alimentaires'}</a></li>
									<li><a class="top-btn" href="/planalimentaire/edition"><i class="icon-retweet glyph-white"></i>  {t d='repasrc' m='Créer un plan alimentaire'}</a></li>
								</ul>
							</li>
							*}
							{/if}
						</ul>
						<ul class="nav pull-right">
							{if \mod\user\Main::userhasRight('Manage page') }
							<li class="dropdown" onclick="this.toggleClass('open');">
								<a href="#" class="dropdown-toggle" data-toggle="dropdown">{t d='page' m='Page'}<b class="caret"></b></a>
								<ul class="dropdown-menu">
									{block name='page_menu' }
										<li><a class="top-btn" href="/page/list/"><i class="icon-th-list glyph-white"></i>  {t d='page' m='List'}</a></li>
										<li><a class="top-btn" href="/page/edit/0"><i class="icon-pencil glyph-white"></i>  {t d='page' m='Add'}</a></li>
									{/block}
								</ul>
							</li>
							{/if}
							{if \mod\user\Main::userhasRight('Manage rights') }
							<li class="dropdown" onclick="this.toggleClass('open');">
								<a href="#" class="dropdown-toggle" data-toggle="dropdown">{t d='user' m='User'}<b class="caret"></b></a>
								<ul class="dropdown-menu">
									{block name='user_menu' }
										<li><a class="top-btn" href="/user/"><i class="icon-th-list glyph-white"></i>  {t d='user' m='Manage users'}</a></li>
										<li><a class="top-btn" href="/user/edit/0"><i class="icon-user glyph-white"></i>  {t d='user' m='Add user'}</a></li>
									{/block}
								</ul>
							</li>
							{/if}
							{if \mod\user\Main::userIsLoggedIn()}
								<li><a href="/logout">({t d='user' m='Se déconnecter'})</a></li>
							{else}
								<li><a href="/login">{t d='user' m='Connexion'}</a></li>
							{/if}
						</ul>
					</div>
				</div>
			</div>
		</div>

		{if $smarty.server.REQUEST_URI != '/' && !strpos($smarty.server.REQUEST_URI, 'page')}
		<div id="content" style="position: relative">
		  <div style="position: absolute;top:5px;left: 680px">
		  	<a href="javascript:void(0)" id="helpToggler" onclick="toggleHelp()">
		  		{if isset($smarty.session.displayHelp) && $smarty.session.displayHelp == 1}
		  			Masquer l'aide et les explications.
		  		{else}
		  			Afficher l'aide et les explications.
		  		{/if}
		  	</a>
		  </div>
		  {/if}
			{block name='repasrc_content'}
			{/block}
		</div>

		<div id="footer">
			<div class="navbar">
				<div class="container">
					<div class="nav-collapse">
						<ul class="nav pull-right">
							<li><a href="javascript:void(0)">RepasRC 2012</a></li>
							<li><a href="/page/contact">{t d='repasrc' m='Contact'}</a></li>
						</ul>
					</div>
				</div>
			</div>
		</div>

	</div>
{/block}
