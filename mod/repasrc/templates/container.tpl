{extends tplextends('repasrc/layout')}

{block name='repasrc_content'}
	<div class="page-header">
		{block name='main-container-title'}
		{/block}
	</div>

	<div class="main-container">

		<div class="span2">
			{block name='main-container-sidebar'}
			{/block}
		</div>

		<div class="span9">
			<div class="recipe_content">
				{block name='main-container-content'}
				{/block}
			</div>
		</div>

		<div class="span2">
			{block name='main-container-sidebar-right'}
			{/block}
		</div>

		<div class="clearfix"></div>
	</div>

{/block}
