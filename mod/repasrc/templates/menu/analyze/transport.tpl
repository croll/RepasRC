{extends tplextends('repasrc/menu_edit')}

{block name='webpage_head' append}
	{js file="/mod/repasrc/js/menu.js"}
	{js file="/mod/repasrc/js/transport.js"}
	<script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false"></script>
{/block}

{block name='menu_title'}
	<h1>{t d='repasrc' m='Transport'}</h1>
{/block}

{block name='menu_content'}
	{include file="repasrc/menu/analyze/transport_content"}
{/block}