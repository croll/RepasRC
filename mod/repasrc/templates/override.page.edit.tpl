{extends tplextends('repasrc/layout')}

{block name='webpage_head' append}
	{js file="/mod/cssjs/js/ckeditor/ckeditor.js"}
	{js file="/mod/cssjs/js/chwysiwyg.js"}
{/block}
{block name='page_menu' append}
		{if isset($page.pid) && $page.pid !=0} 
		<li><a  href="/page/{$page.sysname}"><i class="icon-eye-open glyph-white"></i>  {t d='page' m='View'}</a></li>
		{/if}
{/block}
{block name='repasrc_content'}
	
	{if isset($page.pid) && $page.pid !=0} 
	<div class="page-header" id="page_title">
		<h1>{$page.name}</h1>
		<small>
			{t d='page' m='Created %s by %s - last updated: %s' p0=$page.created|date_format: '%d %b %Y' p1=$page.full_name p2=$page.updated|date_format: '%d %b %Y'}
		</small>
	</div>
	{/if}
	<div id="pageForm" class="row">
	<fieldset>
		<form id="page_edit" method="POST" action="" class="form-inline">
			<input type="hidden" name="field_fieldform_id" value="page_edit">
			<input type="hidden" name="pid" value="{$page.pid}" >
			<input type="hidden" name="sysname" value="{$page.sysname}" >
			<input type="hidden" name="authorId" value="{$page.authorId}" >
			<input type="hidden" name="created" value="{$page.created}" >
			<input type="hidden" name="updated" value="{$page.updated}" >

			<div class="row" >
				<a class="btn btn-primary float" href="#" onclick="$('page-trans').toggleClass('hidden');";> {t d='page' m='Translation'}</a>
				<div id="page-trans" class="hidden float">
					<label for="lang"><span>{t d='page' m='Lang'}:</span></label>
					<select name="lang" onchange="mypage.listIdLangReference('{$page.sysname}', this.value, 'page_reference');">
						<option value=""> {t d='page' m='Untranslated'}</option>	
						<option value="fr_FR" {if $page.lang == "fr_FR"} selected="selected"{/if}>{t d='page' m='French'}</option>	
						<option value="de_DE" {if $page.lang == "de_DE"} selected="selected"{/if}>{t d='page' m='Deutsch'}</option>	
					</select>
					<label for="lang"><span>{t d='page' m='Is translation of'}:</span></label>
					<select id="page_reference" name="id_lang_reference">
						<option value="">{t d='page' m='None'}</option>	
						{section name=i loop=$idRefs}
						<option value="{$idRefs[i].pid}" {if  $idRefs[i].pid == $page.id_lang_reference} selected="selected"{/if}>{$idRefs[i].name}</option>	
						{/section}
					</select>
				</div>
				<label for="name"><span>{t d='page' m='Page title'}:</span></label>
				<input class="xlarge" title="name" type="text" name="name" value="{$page.name}" />
				<label for="published"><span>{t d='page' m='Publish'}:</span></label>
				<input onclick="var c=this.get('value'); if (c==0) this.set('value', 1); else this.set('value', 0);" class="checkbox" title="published" type="checkbox" name="published" {if $page.published == 1} checked ="checked" {/if} value="{$page.published}" />
					<input class="btn btn.primary" id='page_edit_submit'  type="submit" name="submit" value="{t d='page' m='Save'}">
					<a class="btn" href="../list/">{t d='page' m='Cancel'}</a>
			</div>
			<div class="row" style="margin-top:20px;">
				<textarea id="editor1" name="content" style="visibility: hidden; display: none; ">{$page.content}</textarea>	
			</div>
		</form>
</fieldset>
	</div>

<script>
	var myeditor = new CHWysiwyg({ 'contentElement' : 'editor1',});
	var mypage = new Page();
	$('page_edit_submit').addEvent('click', function(event){
		event.stop(); //Prevents the browser from following the link.
		var content = myeditor.prepareToSave();
		 
		$('editor1').set('value', content);
		var params = $('page_edit'); 
		mypage.postForm('/ajax/call/page/savePage', 'page_edit', params);
	});
</script>
{/block}

