<?php  //  -*- mode:php; tab-width:2; c-basic-offset:2; -*-

namespace mod\repasrc;

class Main {

	public static function hook_core_init_http($hookname, $userdata) {
		if (\mod\user\Main::userIsLoggedIn() && (!isset($_SESSION['rc']) || empty($_SESSION['rc']))) {
			$uid = \mod\user\Main::getUserId($_SESSION['login']);
			$_SESSION['rc'] = \mod\repasrc\RC::getUserRC($uid);
			if (!isset($_SESSION['recipe']['comp']))
				$_SESSION['recipe']['comp'] = array();
		}
	}

  public static function hook_mod_repasrc_index($hookname, $userdata) {
    $page = new \mod\webpage\Main();
		$content = \mod\page\Main::getPageBySysname('accueil');
		$page->smarty->assign('content', $content['content']);
		$page->setLayout('repasrc/repasrc');
    $page->display();
  }

	public static function hook_mod_repasrc_recipe_list($hookname, $userdata, $params) {
    \mod\user\Main::redirectIfNotLoggedIn();
		// Add recipe for comparison
		$rid = (isset($params[1])) ? $params[1] : null;
		if (strstr($params[0], 'add') && !empty($rid)) {
			if (isset($rid) && !in_array($rid, $_SESSION['recipe']['comp'])) {
				$_SESSION['recipe']['comp'][] = (int)$rid;
			}
		}
		// Remove recipe from comparison list
		if (strstr($params[0], 'del') && !empty($rid)) {
			if (isset($_SESSION['recipe']['comp']) && is_array($_SESSION['recipe']['comp'])) {
				$tmp = array();
				foreach($_SESSION['recipe']['comp'] as $tmpid) {
					if ($tmpid != $rid)
						$tmp[] = (int)$tmpid;
				}
				$_SESSION['recipe']['comp'] = $tmp;
			}
		}
		// Display
		$recipes = NULL;
    $page = new \mod\webpage\Main();
		$page->smarty->assign(array('recipeList' => $_SESSION['recipe']['comp']));
		$page->setLayout('repasrc/recipe/list');
    $page->display();
	}

	public static function hook_mod_repasrc_recipe_edit($hookname, $userdata, $params) {

    \mod\user\Main::redirectIfNotLoggedIn();
		$section = NULL;
    $page = new \mod\webpage\Main();

		if (isset($_REQUEST['recipeId']) && !empty($_REQUEST['recipeId'])) {
			$id = $_REQUEST['recipeId'];
		} else if (isset($params[2]) && !empty($params[2])) {
			$id = $params[2];
		} else {
			$id = null;
		}

		/* Recipe modules */
		if (isset($_POST['modules'])) {
			// Module selection posted, we store it in session
			$modules = array();
			foreach(explode(' ',$_POST['modules']) as $mod) {
				$modules[$mod] = 1;
			}
			$_SESSION['recipe']['modules'] = $modules;
			\mod\repasrc\Recipe::updateModules($id, $modules);
		} else {
			// If we got an recipe id, we take modules from recipe
			if (!empty($id)) {
				$modules = \mod\repasrc\Recipe::getModulesList($id);
			} else {
				// Otherwise we get modules defined in session
				$modules = (isset($_SESSION['recipe']['modules'])) ? $_SESSION['recipe']['modules'] : 0;
			}
		}

		/* Recipe informations */
		if (isset($_POST['component'])) {
			$form = new \mod\form\Form(array('mod' => 'repasrc', 'file' => 'templates/recipe/informations.json'));
			if ($form->validate()) {
				$fields = $form->getFieldValues();
				if (empty($id)) {
					$id = \mod\repasrc\Recipe::add($_SESSION['rc'], $fields['label'], $fields['shared'], $fields['component'], $fields['persons'], $fields['type']);
				} else {
					\mod\repasrc\Recipe::update($id, $fields['label'], $fields['shared'], $fields['component'], $fields['persons'], $fields['type']);
				}
				if (isset($fields['consumptiondate']) && !empty($fields['consumptiondate'])) {
					\mod\repasrc\Recipe::setConsumptionDate($id, $fields['consumptiondate']);
				}
			}
		}

		/* Recipe foodstuff */
		if (isset($_POST['quantity'])) {
			$form = new \mod\form\Form(array('mod' => 'repasrc', 'file' => 'templates/recipe/foodstuff.json'));
			if ($form->validate()) {
				$fields = $form->getFieldValues();
				$foodstuffId = (int)$_POST['foodstuffId'];
				$recipeId = (int)$_POST['recipeId'];
				$synonymId = (isset($_POST['synonymId'])) ? (int)$_POST['synonymId'] : null;
				$steps = array();
				\core\Core::log($_POST);
				if (!empty($_POST['origin_steps'])) {
					$steps = explode(' ', trim($_POST['origin_steps']));
				}
				if (isset($_POST['recipeFoodstuffId']) && !empty($_POST['recipeFoodstuffId'])) {
					\mod\repasrc\Foodstuff::updateForRecipe((int)$_POST['recipeFoodstuffId'], $fields['quantity'], $fields['conservation'], $fields['production'], $fields['price'], $fields['vat'], $fields['location'], $steps);
				} else {
					\mod\repasrc\Foodstuff::addToRecipe($recipeId, $foodstuffId, $synonymId, $fields['quantity'], $fields['conservation'], $fields['production'], $fields['price'], $fields['vat'], $fields['location'], $steps);
				}
			}
		}

		/* Recipe comments */
		if (isset($_POST['comment'])) {
			$form = new \mod\form\Form(array('mod' => 'repasrc', 'file' => 'templates/recipe/comments.json'));
			if ($form->validate()) {
				$fields = $form->getFieldValues();
					\mod\repasrc\Recipe::setComments($id, $fields['comment']);
			}
		}

		/* Recipe copy */
		if (isset($_POST['action']) && $_POST['action'] == 'duplicate') {
			$form = new \mod\form\Form(array('mod' => 'repasrc', 'file' => 'templates/recipe/duplicate.json'));
			if ($form->validate()) {
				$fields = $form->getFieldValues();
				\mod\repasrc\Recipe::duplicate($id, $fields['label']);
				$section = 'informations';
			}
		}

		// POST Treatment ok
		// Now check if recipe ID is valid
		if (!empty($_POST) && !is_null($id)) {
			$id = (\mod\repasrc\Recipe::checkIfExists($id)) ? $id : null;
		}
		
		if (is_null($section)) $section = $params[1];

		switch($section) {
			case 'commentaires':
				$page->smarty->assign('formDefaultValues', array('comment' => \mod\repasrc\Recipe::getComments($id)));
			break;
			case 'aliments':
			if (!empty($id)) {
				$page->smarty->assign('recipeFoodstuffList', \mod\repasrc\Recipe::getFoodstuffList($id));
			}
			break;
		}

		$tplTrans = array('aliments' => 'foodstuff', 'commentaires' => 'comments');
		$tpl = (isset($tplTrans[$section])) ? $tplTrans[$section] : $section;
		$page->smarty->assign(array('section' => $section, 'recipeId' => $id, 'modulesList' => $modules));
			if (!empty($id)) {
				$modules = \mod\repasrc\Recipe::getModulesList($id);
			} else {
				// Otherwise we get modules defined in session
				$modules = (isset($_SESSION['recipe']['modules'])) ? $_SESSION['recipe']['modules'] : 0;
			}
		$re = \mod\repasrc\Recipe::getDetail($id);
		if (isset($re) && !empty($re)) {
			$recipe = $re;
		} else {
			$recipe = array('id' => $id);
		}
		$page->smarty->assign('recipe', $recipe);
		$page->setLayout('repasrc/recipe/'.$tpl);
    $page->display();
	}

	public static function hook_mod_repasrc_account($hookname, $userdata, $params) {
    \mod\user\Main::redirectIfNotLoggedIn();
		if (isset($_POST['name'])) {
			$form = new \mod\form\Form(array('mod' => 'repasrc', 'file' => 'templates/account/account.json'));
			if ($form->validate()) {
				$fields = $form->getFieldValues();
				\mod\repasrc\RC::updateRcInfos($_SESSION['rc'], $fields['name'], $fields['type'], $fields['public'], $fields['zoneid']);
			}
		}
    $page = new \mod\webpage\Main();
		$page->setLayout('repasrc/account/account');
    $page->display();
	}

	public static function hook_mod_repasrc_recipe_import($hookname, $userdata, $params) {
    \mod\user\Main::redirectIfNotLoggedIn();
    $page = new \mod\webpage\Main();
		$page->setLayout('repasrc/recipe/import');
    $page->display();
	}

	public static function hook_mod_repasrc_recipe_compare($hookname, $userdata, $params) {
    \mod\user\Main::redirectIfNotLoggedIn();
		$section = $params[1];
	}

	public static function hook_mod_repasrc_recipe_analyze($hookname, $userdata, $params) {
    \mod\user\Main::redirectIfNotLoggedIn();
		if (isset($params[2]))
			$id = $params[2];
    $page = new \mod\webpage\Main();
		
		if (!isset($section) || is_null($section)) $section = $params[1];

		if (!empty($id)) {
			$modules = \mod\repasrc\Recipe::getModulesList($id);
		} else {
			$modules = (isset($_SESSION['recipe']['modules'])) ? $_SESSION['recipe']['modules'] : 0;
		}

		$recipeDetail = \mod\repasrc\Recipe::getDetail($id);
		$colors = \mod\repasrc\Tools::getColorsArray($recipeDetail['foodstuffList']);
		$noData = array();

		switch($section) {
			case 'resume':
				// Footprint Pie
				$dataFootprintPie = array();
				$dataFootprintPie['cols'] = array(
					array('label' => 'Aliment', 'type' => 'string'),
					array('label' => 'Empreinte écologique foncière', 'type' => 'number')
				);
				foreach($recipeDetail['foodstuffList'] as $foodstuff) {
					if (empty($foodstuff['foodstuff']['footprint'])) {
						$noData[] = $foodstuff['foodstuff']['label'];
					}
					$dataFootprintPie['rows'][]['c'] = array(
						array('v' => $foodstuff['foodstuff']['label']),
						array('v' => $foodstuff['foodstuff']['footprint']*$foodstuff['quantity'])
					);
					$dataFootprintBar[][$foodstuff['foodstuff']['label']] = $foodstuff['quantity']*$foodstuff['foodstuff']['footprint'];
				}
				$page->smarty->assign(array(
					'colors' => json_encode($colors),
					'dataFootprintPie' => json_encode($dataFootprintPie)
				));
				\core\Core::log(json_encode($dataFootprintPie));
			break;

			case 'saisonnalite':
				if (empty($recipeDetail['consumptionmonth'])) continue;
				$recipeDetail['seasonality'] = \mod\repasrc\Analyze::seasonality($recipeDetail);
			break;
		}

		$recipes = array($recipeDetail);

		$tplTrans = array('saisonnalite' => 'seasonality', 'transport' => 'transport',  'prix' => 'price');
		$tpl = (isset($tplTrans[$section])) ? $tplTrans[$section] : $section;
		$page->setLayout('repasrc/recipe/analyze/'.$tpl);
		$page->smarty->assign(array(
			'section' => $section,
			'recipe' => $recipeDetail, 
			'recipes' => $recipes,
			'modulesList' => $modules
		));
    $page->display();
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
