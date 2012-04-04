<?php  //  -*- mode:php; tab-width:2; c-basic-offset:2; -*-

namespace mod\repasrc;

class Main {

  public static function hook_mod_repasrc_index($hookname, $userdata) {
    $page = new \mod\webpage\Main();
		$content = \mod\page\Main::getPageBySysname('accueil');
		$page->smarty->assign('title', $title['title']);
		$page->smarty->assign('content', $content['content']);
		$page->setLayout('repasrc/repasrc');
    $page->display();
  }

	public static function hook_mod_repasrc_recipe_list($hookname, $userdata) {
    \mod\user\Main::redirectIfNotLoggedIn();
		$recipes = NULL;

		if (isset($_POST['label'])) {
			$recipes = \mod\repasrc\Recipe::search(7);
		}

		// Display
    $page = new \mod\webpage\Main();
		$section = $params[1];
		$page->smarty->assign('recipes', $recipes);
		$page->setLayout('repasrc/recipe/list');
    $page->display();
	}

	public static function hook_mod_repasrc_recipe_edit($hookname, $userdata, $params) {
    \mod\user\Main::redirectIfNotLoggedIn();
		$section = NULL;
    $page = new \mod\webpage\Main();
		if (isset($params[2]))
			$id = $params[2];
		
		// POST ?
		if (isset($_POST['modules'])) {
			$_SESSION['recipe']['modules'] = array();
			foreach(explode(' ',$_POST['modules']) as $mod) {
				$_SESSION['recipe']['modules'][$mod] = 1;
			}
			$section = 'informations';
		}

		// VERIF
		if (isset($_POST['select_component'])) {
			$section = 'aliments';
		}
		
		if (is_null($section)) $section = $params[1];

		if ($section == 'aliments') {
			if (!empty($id))
				$page->smarty->assign('recipeFoodstuffList', \mod\repasrc\Recipe::getFoodstuffList($id));
		}

		$tplTrans = array('aliments' => 'foodstuff');
		$tpl = (isset($tplTrans[$section])) ? $tplTrans[$section] : $section;
		$page->setLayout('repasrc/recipe/'.$tpl);
		$page->smarty->assign(array('section' => $section, 'recipe_id' => $id));
    $page->display();
	}

	public static function hook_mod_repasrc_account($hookname, $userdata, $params) {
    \mod\user\Main::redirectIfNotLoggedIn();
    $page = new \mod\webpage\Main();
		$page->setLayout('repasrc/account/account');
    $page->display();
	}

	public static function hook_mod_repasrc_recipe_submit($hookname, $userdata, $params) {
	}

	public static function hook_mod_repasrc_recipe_compare($hookname, $userdata, $params) {
    \mod\user\Main::redirectIfNotLoggedIn();
		$section = $params[1];
	}

	public static function hook_mod_repasrc_menu($hookname, $userdata) {
    \mod\user\Main::redirectIfNotLoggedIn();
		$action = $params[1];
		if (isset($params[2]) && !empty($params[2])) {
			$num = $params[2];
		}
	}

	public static function hook_mod_repasrc_foodplan($hookname, $userdata) {
    \mod\user\Main::redirectIfNotLoggedIn();
		$action = $params[1];
		if (isset($params[2]) && !empty($params[2])) {
			$num = $params[2];
		}
	}

}
