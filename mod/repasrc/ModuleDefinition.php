<?php  //  -*- mode:php; tab-width:2; c-basic-offset:2; -*-

namespace mod\repasrc;

class ModuleDefinition extends \core\ModuleDefinition {

	function __construct() {
		$this->description = 'RepasRC Application';
		$this->name = 'repasrc';
		$this->version = '1.0';
		$this->dependencies = array('ajax', 'cssjs', 'regroute', 'smarty', 'webpage', 'user', 'map', 'form');
		parent::__construct();
	}

	function install() {
		parent::install();
		\mod\regroute\Main::registerRoute($this->id, '#^/$#', 'mod_repasrc_index');
		\mod\regroute\Main::registerRoute($this->id, '#^/compte/?$#', 'mod_repasrc_account');
		\mod\regroute\Main::registerRoute($this->id, '#^/recette/edition/?([a-z]*)/?([0-9]*)/?$#', 'mod_repasrc_recipe_edit');
		\mod\regroute\Main::registerRoute($this->id, '#^/recette/liste$#', 'mod_repasrc_recipe_list');
		\mod\regroute\Main::registerRoute($this->id, '#^/recette/comparer/?([a-z-]*)/?$#', 'mod_repasrc_recipe_compare');
		\mod\regroute\Main::registerRoute($this->id, '#^/recette/envoyer/?([a-z-]*)/?$#', 'mod_repasrc_recipe_submit');
		\mod\regroute\Main::registerRoute($this->id, '#^/recette/analyse/?([a-z]*)/?([0-9]*)$#', 'mod_repasrc_recipe_analyze');
		\mod\user\Main::addRight("Import RepasRC datas", "User can import datas");			
		\mod\user\Main::assignRight('View page', 'Anonymous');
	}

	function uninstall() {
		\mod\user\Main::delRight('Import RepasRC datas');
		\mod\user\Main::delRightAssignation('View page');
   	\mod\regroute\Main::unregister($this->id);
		parent::uninstall();
	}
}
