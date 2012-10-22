{extends tplextends('repasrc/menu_edit')}

{block name='webpage_head' append}
	{js file="/mod/repasrc/js/menu.js"}
{/block}

{block name='menu_title'}
	<h1>{t d='repasrc' m='Production / conservation'}</h1>
{/block}

{block name='menu_content'}
	{include file="repasrc/menu/analyze/mode_content"}
{/block}
