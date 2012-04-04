{extends tplextends('repasrc/layout')}

{block name='webpage_head' append}
	{css file="/mod/cssjs/css/Modal.css"}
{/block}

{block name='repasrc_content'}
	<div style="width:900px; margin: 10px auto">
		{$content}
	</div>
{/block}
