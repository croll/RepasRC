<div style="margin: 0 0 20px 20px; font-size: 16px">
	<div>Nombre de convives: <strong>{$menu.eaters}</strong></div>
	{*
	{if $menu.footprint > 0}
		<div>Empreinte écologique foncière: <strong>{$menu.footprint|round:3}</strong> m²g</div>
	{/if}
	*}
</div>

{foreach $menu.recipesList as $re}
<div style="margin: 0 0 20px 20px">
	<div style="font-size: 18px">
		{$re.portions} portion{if $re.portions > 1}s{/if} de
		<strong>
			<a href="/recette/analyse/resume/{$re.id}" target="_blank">{$re.label}</a>
		</strong>
	</div>
	<div style="font-size: 14px">
		{*
		{if $re.persons > 0 && $re.footprint > 0}
			<div>Empreinte écologique foncière de la recette: <strong>{round($re.footprint/$re.persons, 3)} m²g/Kg</strong></div>
		{/if}
		*}
	</div>
</div>
{/foreach}

<div class="form-actions" style="margin-top:30px">
	<a class="btn help" code="boutonanalyserlemenu" href="/menu/analyse/resume/{$menu.id}">Analyser le menu</a>
	{if $comparison != false}
		<a class="btn" href="/menu/liste/add/{$menu.id}">Sélectionner le menu pour comparaison</a>
	{/if}
	<a class="btn btn-inverse" href="javascript:void(0)" onclick="modalWin.hide()">Fermer</a>
	<div style="text-align:center;margin-top:10px">
		{if \mod\user\Main::userBelongsToGroup('Admin') || \mod\repasrc\RC::isMenuOwner({$menu.id})}
			<a class="btn" href="/menu/edition/recettes/{$menu.id}">Modifier le menu</a>
		{/if}
		{if \mod\user\Main::userBelongsToGroup('Admin') || \mod\repasrc\RC::isMenuOwner({$menu.id})}
			<a class="btn btn-danger" href="javascript:void(0)" onclick="deleteMenu({$menu.id})">Effacer le menu</a>
		{/if}
	</div>
</div>
