{extends tplextends('repasrc/layout')}

{block name='webpage_head' append}
	{css file='/mod/cssjs/ext/twitter-bootstrap/css/bootstrap.css'}
	{js file='/mod/cssjs/js/mootools.js'}
	{js file='/mod/cssjs/js/mootools.more.js'}
	{if isset($url_redirect)}
		<meta http-equiv="Refresh" content="2; url={$url_redirect}" />
	{/if}
{/block}
{$_SESSION|print_r}

{block name='webpage_body'}
  <div style="width: 340px;margin: 100px auto">
  {if $displayForm}
	<div class="hero-unit">
		<legend><h2>REPAS-RC</h2></legend>
		<div style="width:320px;margin: 0 auto">
		{form mod="user" file="templates/loginForm.json"}
		<fieldset>
			{if isset($login_failed)}
				<div id="message" style="margin: 10px;color: red">{t d='repasrc' m="Mauvais login ou mot de passe"}</div>
			{/if}	
			<div>
				<div style="margin: 10px 0px">
					{$loginForm.login}
				</div>
				<div style="margin: 10px 0px">
					{$loginForm.password}
				</div>
			</div>
			<div>
				<input type="submit" class="btn btn-primary" value="{t d='repasrc' m="Connexion"}" ?>
			</div>
		</fieldset>
	</div>
</div>
		<script>
		window.addEvent('domready', function(){
			document.id('loginForm').getElements('[type=text], [type=password]').each(function(el){
				new OverText(el, {
					poll: true
				});
			});
		});
		</script>
		{/form}
	{else}
		{if isset($login_ok)}
			<div class="alert alert-success">
			{l s='Identification réussie, redirection...'}
			</div>
		{elseif isset($logout)}
			<div class="alert alert-success">
			{l s='Déconnexion réussie, redirection...'}
			</div>
		{else}
			<div class="alert alert-warning">
			{l s='Vous êtes déjà identifié, redirection...'}
			</div>
		{/if}
	{/if}	
	</div>
{/block}
