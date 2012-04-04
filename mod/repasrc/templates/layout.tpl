{extends tplextends('webpage/webpage_main_html5')}

{block name='webpage_head' append}
	{js file="/mod/cssjs/js/mootools.js"}
	{js file="/mod/cssjs/js/mootools.more.js"}
	{js file="/mod/cssjs/js/captainhook.js"}
	{js file="/mod/cssjs/js/Modal.js"}
	{js file="/mod/cssjs/js/chtable.js"}
	{js file="/mod/cssjs/js/chfilter.js"}
	{js file="/mod/cssjs/js/chmypaginate.js"}
	{js file="/mod/repasrc/js/repasrc.js"}
	{js file="/mod/page/js/page.js"}
	{js file="/mod/repasrc/js/MilkChart.js"}
	{css file="/mod/cssjs/ext/twitter-bootstrap/css/bootstrap.css"}
	{css file="/mod/repasrc/css/bootstrap-responsive.css"}
	{css file="/mod/cssjs/css/Modal.css"}
	{css file="/mod/cssjs/css/mypaginate.css"}
	{css file="/mod/page/css/page.css"}
	{css file="/mod/repasrc/css/repasrc.css"}
{/block}

{block name='webpage_body'}
	<div id="repasrc_container">
		<div class="navbar navbar-fixed-top">
			<div class="navbar-inner">
				<div class="container-fluid">
					<div class="container">
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
									<li><a class="top-btn" href="/recette/importer"><i class="icon-upload glyph-white"></i>  {t d='repasrc' m='Importer une recette'}</a></li>
									<li><a class="top-btn" href="/recette/exporter"><i class="icon-download glyph-white"></i>  {t d='repasrc' m='Exporter une recette'}</a></li>
								</ul>
							</li>
							{* menus *}
							<li class="dropdown" onclick="this.toggleClass('open');">
								<a href="#" class="dropdown-toggle" data-toggle="dropdown">{t d='repasrc' m='Menus'}<b class="caret"></b></a>
								<ul class="dropdown-menu">
									<li><a class="top-btn" href="/menu/liste"><i class="icon-th-list glyph-white"></i>  {t d='repasrc' m='Lister les menus'}</a></li>
									<li><a class="top-btn" href="/menu/creer"><i class="icon-plus glyph-white"></i>  {t d='repasrc' m='Composer un menu'}</a></li>
									<li><a class="top-btn" href="/menu/comparer"><i class="icon-retweet glyph-white"></i>  {t d='repasrc' m='Comparer des menus'}</a></li>
								</ul>
							</li>
							{* plan alimentaire *}
							<li class="dropdown" onclick="this.toggleClass('open');">
								<a href="#" class="dropdown-toggle" data-toggle="dropdown">{t d='repasrc' m='Plan alimentaire'}<b class="caret"></b></a>
								<ul class="dropdown-menu">
									<li><a class="top-btn" href="/planalimentaire/lister/"><i class="icon-th-list glyph-white"></i>  {t d='repasrc' m='Lister les plans alimentaires'}</a></li>
									<li><a class="top-btn" href="/planalimentaire/creer/"><i class="icon-retweet glyph-white"></i>  {t d='repasrc' m='Créer un plan alimentaire'}</a></li>
								</ul>
							</li>
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

		<div id="content">
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
