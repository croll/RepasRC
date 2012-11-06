{extends tplextends('repasrc/layout')}

{block name='webpage_head' append}
	{css file="/mod/cssjs/css/Modal.css"}
{/block}

{block name='webpage_content'}
  <div style="width:800px; margin: 10px auto">
  {block name='repasrc_content'}
  {/block}
  </div>
{/block}
