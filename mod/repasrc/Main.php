<?php  //  -*- mode:php; tab-width:2; c-basic-offset:2; -*-

namespace mod\repasrc;

class Main {

	public static function hook_core_init_http($hookname, $userdata) {
		if (\mod\user\Main::userIsLoggedIn() && (!isset($_SESSION['rc']) || empty($_SESSION['rc']))) {
			$uid = \mod\user\Main::getUserId($_SESSION['login']);
			$_SESSION['rc'] = \mod\repasrc\RC::getUserRC($uid);
			if (!isset($_SESSION['recipe']))
				$_SESSION['recipe'] = array();
			if (!isset($_SESSION['menu']))
				$_SESSION['menu'] = array();
			if (!isset($_SESSION['recipe']['comp']))
				$_SESSION['recipe']['comp'] = array();
			if (!isset($_SESSION['menu']['comp']))
				$_SESSION['menu']['comp'] = array();
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
				if (isset($fields['price']) && !empty($fields['price'])) {
					\mod\repasrc\Recipe::setPrice($id, $fields['price'], $fields['vat']);
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

		$noData = array();

		switch($section) {
			case 'resume':
				$noData = $families = array();
				$gctPie = new \mod\googlecharttools\Main();
				$gctCol = new \mod\googlecharttools\Main();
				$gctComp = new \mod\googlecharttools\Main();
				$gctPie->addColumn('Aliment', 'string');
				$gctPie->addColumn('Empreinte écologique foncière pour la recette', 'number');
				$gctCol->addColumn('Val', 'string');
				$gctCol->addRow('Empreinte écologique foncière pour une personne');
				$gctComp->addColumn('Aliment', 'string');
				$gctComp->addColumn('Empreinte écologique foncière', 'number');
				$gctComp->addColumn('Quantité', 'number');
				foreach($recipeDetail['foodstuffList'] as $fs) {
				// Foodstuff with no footprint value
					if ($fs['foodstuff']['fake'] || empty($fs['foodstuff']['footprint'])) {
						$noData[] = $fs['foodstuff']['label'];
					} else {
						$gctPie->addRow($fs['foodstuff']['label']);
						$gctPie->addRow($fs['foodstuff']['footprint']*$fs['quantity']);
						$gctCol->addColumn($fs['foodstuff']['label'], 'number');
						$gctCol->addRow($fs['foodstuff']['footprint']*($fs['quantity']/$recipeDetail['persons']));
						$gctComp->addRow($fs['foodstuff']['label']);
						$gctComp->addRow(round(($fs['foodstuff']['footprint']*($fs['quantity'])*100)/$recipeDetail['footprint'],2));
						$gctComp->addRow(round(((float)$fs['quantity']*100)/($recipeDetail['totalWeight']/$recipeDetail['persons'])),2);
						if (isset($fs['families']) && sizeof($fs['families']) > 0) {
							$families[] = array_shift(array_keys($fs['families']));
						}
					}
				}
				$page->smarty->assign(array(
					'colors' => json_encode(\mod\repasrc\Tools::getColorsArray($families)),
					'noData' => $noData,
					'dataFootprintPie' => $gctPie->getJSON(),
					'dataFootprintCol' => $gctCol->getJSON(),
					'dataFootprintComp' => $gctComp->getJSON()
				));
			break;

			case 'saisonnalite':
				if (empty($recipeDetail['consumptionmonth'])) continue;
				$recipeDetail['seasonality'] = \mod\repasrc\Analyze::seasonality($recipeDetail);
			break;

			case 'transport':
				$rcInfos = \mod\repasrc\RC::getRcInfos($_SESSION['rc']);
				$rcGeo = \core\Core::$db->fetchRow('SELECT ST_X(rrc_zv_geom) AS x, ST_Y(rrc_zv_geom) AS y, rrc_zv_label AS label FROM rrc_geo_zonevalue WHERE rrc_zv_id = ?', array($rcInfos['zoneid']));
				$page->smarty->assign('rcGeo', $rcGeo);
				
				$analyze =  \mod\repasrc\Analyze::transport($recipeDetail);
				$recipeDetail['transport'] = $analyze;
				$gctCol1 = new \mod\googlecharttools\Main();
				$gctCol1->addColumn('Val', 'string');
				$gctCol1->addRow('Empreinte écologique du transport');
				$gctCol2 = new \mod\googlecharttools\Main();
				$gctCol2->addColumn('Val', 'string');
				$gctCol2->addRow('Empreinte écologique du transport');
				$gctComp = new \mod\googlecharttools\Main();
				$gctComp->addColumn('Aliment', 'string');
				$gctComp->addColumn('Empreinte écologique foncière', 'number');
				$gctComp->addColumn('Distance', 'number');
				foreach($recipeDetail['transport']['datas'] as $fs) {
					$gctCol1->addColumn($fs['foodstuff']['label'], 'number');
					$gctCol1->addRow($fs['transport']['distance']);
					$gctCol2->addColumn($fs['foodstuff']['label'], 'number');
					$gctCol2->addRow($fs['transport']['footprint']);
					$gctComp->addRow($fs['foodstuff']['label']);
					$gctComp->addRow(round($fs['transport']['distance'],3));
					$gctComp->addRow(round($fs['transport']['footprint'],3));
					if (isset($fs['families']) && sizeof($fs['families']) > 0) {
						$families[] = @array_shift(array_keys($fs['families']));
					}
				}
				$page->smarty->assign(array(
					'colors' => json_encode(\mod\repasrc\Tools::getColorsArray($families)),
					'dataFootprintCol1' => $gctCol1->getJSON(),
					'dataFootprintCol2' => $gctCol2->getJSON(),
					'dataFootprintComp' => $gctComp->getJSON()
				));
			break;

			case 'prix':
				if (empty($recipeDetail['totalPrice']['vatin']) && empty($recipeDetail['totalPrice']['vatin'])) {
					$page->smarty->assign('noprice', true);
				} else {
					if (!empty($recipeDetail['totalPrice']['vatin'])) {
						$families = array();
						$gctCol1 = new \mod\googlecharttools\Main();
						$gctCol1->addColumn('Val', 'string');
						$gctCol1->addRow('Prix des aliments HT');
						foreach($recipeDetail['foodstuffList'] as $fs) {
							if ($fs['vat'] && !empty($fs['price'])) {
								$gctCol1->addColumn($fs['foodstuff']['label'], 'number');
								$gctCol1->addRow($fs['price']);
								if (isset($fs['families']) && sizeof($fs['families']) > 0) {
									$families[] = @array_shift(array_keys($fs['families']));
								}
							}
						}
						$page->smarty->assign(array(
							'dataFootprintCol1' => $gctCol1->getJSON(),
							'colors1' => json_encode(\mod\repasrc\Tools::getColorsArray($families))
						));
					}
					if (!empty($recipeDetail['totalPrice']['vatout'])) {
						$families = array();
						$gctCol2 = new \mod\googlecharttools\Main();
						$gctCol2->addColumn('Val', 'string');
						$gctCol2->addRow('Prix des aliments TTC');
						foreach($recipeDetail['foodstuffList'] as $fs) {
							if (!$fs['vat'] && !empty($fs['price'])) {
								$gctCol2->addColumn($fs['foodstuff']['label'], 'number');
								$gctCol2->addRow($fs['price']);
								if (isset($fs['families']) && sizeof($fs['families']) > 0) {
									$families[] = @array_shift(array_keys($fs['families']));
								}
							}
						}
						$page->smarty->assign(array(
							'dataFootprintCol2' => $gctCol2->getJSON(),
							'colors2' => json_encode(\mod\repasrc\Tools::getColorsArray($families))
						));
					}
				}
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

	/* ************* */
	/*     MENUS     */
	/* ************* */

	public static function hook_mod_repasrc_menu_list($hookname, $userdata, $params) {

    \mod\user\Main::redirectIfNotLoggedIn();

		// Add menu for comparison
		$mid = (isset($params[1])) ? $params[1] : null;
		if (strstr($params[0], 'add') && !empty($mid)) {
			if (isset($mid) && !in_array($mid, $_SESSION['menu']['comp'])) {
				$_SESSION['menu']['comp'][] = (int)$mid;
			}
		}
		// Remove recipe from comparison list
		if (strstr($params[0], 'del') && !empty($mid)) {
			if (isset($_SESSION['menu']['comp']) && is_array($_SESSION['menu']['comp'])) {
				$tmp = array();
				foreach($_SESSION['menu']['comp'] as $tmpid) {
					if ($tmpid != $mid)
						$tmp[] = (int)$tmpid;
				}
				$_SESSION['menu']['comp'] = $tmp;
			}
		}
		// Display
		$menus = NULL;
    $page = new \mod\webpage\Main();
		$page->smarty->assign(array('menuList' => $_SESSION['menu']['comp']));
		$page->setLayout('repasrc/menu/list');
    $page->display();
	}

	public static function hook_mod_repasrc_menu_edit($hookname, $userdata, $params) {
    \mod\user\Main::redirectIfNotLoggedIn();
		$action = $params[1];
		if (isset($params[2]) && !empty($params[2])) {
			$num = $params[2];
		}
	}

	public static function hook_mod_repasrc_menu_compare($hookname, $userdata, $params) {
    \mod\user\Main::redirectIfNotLoggedIn();
		$action = $params[1];
		if (isset($params[2]) && !empty($params[2])) {
			$num = $params[2];
		}
	}

	public static function hook_mod_repasrc_menu_analyze($hookname, $userdata, $params) {
    \mod\user\Main::redirectIfNotLoggedIn();
		$action = $params[1];
		if (isset($params[2]) && !empty($params[2])) {
			$num = $params[2];
		}
	}

	/* ************* */
	/*     MENUS     */
	/* ************  */

	public static function hook_mod_repasrc_foodplan($hookname, $userdata) {
    \mod\user\Main::redirectIfNotLoggedIn();
		$action = $params[1];
		if (isset($params[2]) && !empty($params[2])) {
			$num = $params[2];
		}
	}

}
