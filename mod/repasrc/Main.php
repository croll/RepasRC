<?php  //  -*- mode:php; tab-width:; c-basic-offset:2; -*-

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
			} else {
				\core\Core::log($form->getValidationErrors());
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
	    if (isset($id) && !empty($id))
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
    $oldbrowser = (preg_match('/(?i)msie [1-8]/',$_SERVER['HTTP_USER_AGENT'])) ? 1 : 0;
    $page->smarty->assign('oldbrowser', $oldbrowser);

		if (!isset($section) || is_null($section)) $section = $params[1];

		if (!empty($id)) {
			$modules = \mod\repasrc\Recipe::getModulesList($id);
		} else {
			$modules = (isset($_SESSION['recipe']['modules'])) ? $_SESSION['recipe']['modules'] : 0;
		}

		$recipeDetail = \mod\repasrc\Recipe::getDetail($id);

		switch($section) {
			case 'resume':
				$graph = \mod\repasrc\Graph::recipeResume($recipeDetail);
				$page->smarty->assign(array(
					'colors' => $graph['colors'],
					'noData' => $graph['noData'],
					'dataFootprintPie' => $graph['pie']->getJSON(),
					'dataFootprintCol' => $graph['col']->getJSON(),
          'dataFootprintCol2' => $graph['col2']->getJSON(),
					'dataFootprintComp' => $graph['comp']->getJSON()
				));
			break;

			case 'transport':
				$rcInfos = \mod\repasrc\RC::getRcInfos($_SESSION['rc']);
				$rcGeo = \core\Core::$db->fetchRow('SELECT ST_X(rrc_zv_geom) AS x, ST_Y(rrc_zv_geom) AS y, rrc_zv_label AS label FROM rrc_geo_zonevalue WHERE rrc_zv_id = ?', array($rcInfos['zoneid']));
				$page->smarty->assign('rcGeo', $rcGeo);

				$graph = \mod\repasrc\Graph::recipeTransport($recipeDetail);
				$page->smarty->assign(array(
					'colors' => $graph['colors'],
					'dataFootprintCol1' => $graph['col1']->getJSON(),
					'dataFootprintCol2' => $graph['col2']->getJSON(),
					'dataFootprintPie' => $graph['comp']->getJSON()
				));
			break;

			case 'mode':
				$graph = \mod\repasrc\Graph::recipeProductionConservation($recipeDetail);
				$page->smarty->assign(array(
						'dataConservation' => $graph['pie1']->getJSON(),
						'dataProduction' => $graph['pie2']->getJSON()
					));
			break;

			case 'prix':
				if (empty($recipeDetail['totalPrice']['vatin']) && empty($recipeDetail['totalPrice']['vatin'])) {
					$page->smarty->assign('noprice', true);
				} else {
					$graph = \mod\repasrc\Graph::recipePrice($recipeDetail);
					if (isset($graph['col1'])) {
						$page->smarty->assign(array(
							'dataFootprintCol1' => $graph['col1']['graph']->getJSON(),
							'colors1' => $graph['col1']['colors']
							));
					}
					if (isset($graph['col2'])) {
						$page->smarty->assign(array(
							'dataFootprintCol2' => $graph['col2']['graph']->getJSON(),
							'colors2' => $graph['col2']['colors']
							));
					}
				}
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

    $page = new \mod\webpage\Main();
    $oldbrowser = (preg_match('/(?i)msie [1-8]/',$_SERVER['HTTP_USER_AGENT'])) ? 1 : 0;
    $page->smarty->assign('oldbrowser', $oldbrowser);

		// Remove recipe from comparison list
		$rid = (isset($params[1])) ? $params[1] : null;
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

		$recipes = array();
		foreach($_SESSION['recipe']['comp'] as $rid) {
			$recipeDetail = \mod\repasrc\Recipe::getDetail($rid);
			$recipes[] = $recipeDetail;
		}

		$noData = $families = array();

		$gctFootprintCol = new \mod\googlecharttools\Main();
		$gctPriceCol = new \mod\googlecharttools\Main();
		$gctTransportCol = new \mod\googlecharttools\Main();
		$gctFootprintCol->addColumn('Val', 'string');
		$gctFootprintCol->addRow('Empreinte écologique foncière des aliments');
		$gctTransportCol->addColumn('Val', 'string');
		$gctTransportCol->addRow('Empreinte écologique foncière des transports');
		foreach($recipes as $recipe) {
			// Foodstuff with no footprint value
			$gctFootprintCol->addColumn($recipe['label'], 'number');
			$gctFootprintCol->addRow($recipe['footprint']);
			$gctTransportCol->addColumn($recipe['label'], 'number');
			$gctTransportCol->addRow($recipe['transport']['total']['footprint']);
			if (isset($recipe['families']) && sizeof($recipe['families']) > 0) {
				$families[] = array_shift(array_keys($recipe['families']));
			}
		}
		$page->smarty->assign(array(
			'colors' => json_encode(\mod\repasrc\Tools::getColorsArray($families)),
			'noData' => $noData,
			'dataFootprintCol' => $gctFootprintCol->getJSON(),
			'dataTransportCol' => $gctTransportCol->getJSON(),
			'recipeList' => $recipes,
			'recipeCompareList' => $_SESSION['recipe']['comp']
		));
		$page->setLayout('repasrc/recipe/compare');
    $page->display();
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
    $page = new \mod\webpage\Main();
		$page->smarty->assign(array('menuList' => (isset($_SESSION['menu']['comp']) ? $_SESSION['menu']['comp'] : NULL)));
		$page->setLayout('repasrc/menu/list');
    $page->display();
	}

	public static function hook_mod_repasrc_menu_edit($hookname, $userdata, $params) {
    \mod\user\Main::redirectIfNotLoggedIn();
    $section = NULL;
    $page = new \mod\webpage\Main();

    if (isset($_REQUEST['menuId']) && !empty($_REQUEST['menuId'])) {
      $id = $_REQUEST['menuId'];
    } else if (isset($params[2]) && !empty($params[2])) {
      $id = $params[2];
    } else {
      $id = null;
    }

    /* Menu modules */
    if (isset($_POST['modules'])) {
      // Module selection posted, we store it in session
      $modules = array();
      foreach(explode(' ',$_POST['modules']) as $mod) {
        $modules[$mod] = 1;
      }
      $_SESSION['menu']['modules'] = $modules;
      \mod\repasrc\Menu::updateModules($id, $modules);
    } else {
      // If we got an recipe id, we take modules from recipe
      if (!empty($id)) {
        $modules = \mod\repasrc\Menu::getModulesList($id);
      } else {
        // Otherwise we get modules defined in session
        $modules = (isset($_SESSION['menu']['modules'])) ? $_SESSION['menu']['modules'] : 0;
      }
    }

    /* Menu informations */
    if (isset($_POST['action']) && $_POST['action'] == 'setMenuInformations') {
      $form = new \mod\form\Form(array('mod' => 'repasrc', 'file' => 'templates/menu/informations.json'));
      if ($form->validate()) {
        $fields = $form->getFieldValues();
        if (empty($id)) {
          $id = \mod\repasrc\Menu::add($_SESSION['rc'], $fields['label'], $fields['shared'], $fields['eaters'], $fields['type']);
        } else {
          \mod\repasrc\Menu::update($id, $fields['label'], $fields['shared'], $fields['eaters'], $fields['type']);
        }
        if (isset($fields['consumptiondate']) && !empty($fields['consumptiondate'])) {
          \mod\repasrc\Menu::setConsumptionDate($id, $fields['consumptiondate']);
        }
        if (isset($fields['price']) && !empty($fields['price'])) {
          \mod\repasrc\Menu::setPrice($id, $fields['price'], $fields['vat']);
        }
      } else {
        \core\Core::log($form->getValidationErrors());
      }
    }

    /* Menu recipes */
    if (isset($_POST['quantity'])) {
      $form = new \mod\form\Form(array('mod' => 'repasrc', 'file' => 'templates/menu/recipe.json'));
      if ($form->validate()) {
        $fields = $form->getFieldValues();
        if (isset($_POST['menuId']) && !empty($_POST['menuId'])) {
          \mod\repasrc\Menu::updateRecipe($fields['recipeId'], $fields['menuId'], $fields['quantity']);
        } else {
          \mod\repasrc\Menu::addRecipe($fields['recipeId'], $fields['menuId'], $fields['quantity']);
        }
      }
    }

    /* Menu comments */
    if (isset($_POST['comment'])) {
      $form = new \mod\form\Form(array('mod' => 'repasrc', 'file' => 'templates/menu/comments.json'));
      if ($form->validate()) {
        $fields = $form->getFieldValues();
          \mod\repasrc\Menu::setComments($id, $fields['comment']);
      }
    }

    /* Menu copy */
    if (isset($_POST['action']) && $_POST['action'] == 'duplicate') {
      $form = new \mod\form\Form(array('mod' => 'repasrc', 'file' => 'templates/menu/duplicate.json'));
      if ($form->validate()) {
        $fields = $form->getFieldValues();
        \mod\repasrc\Menu::duplicate($id, $fields['label']);
        $section = 'informations';
      }
    }

    // POST Treatment ok
    // Now check if recipe ID is valid
    if (!empty($_POST) && !is_null($id)) {
      $id = (\mod\repasrc\Menu::checkIfExists($id)) ? $id : null;
    }
    
    if (is_null($section)) $section = $params[1];

    switch($section) {
      case 'commentaires':
        $page->smarty->assign('formDefaultValues', array('comment' => \mod\repasrc\Menu::getComments($id)));
      break;
      case 'recettes':
      if (!empty($id)) {
        $page->smarty->assign('menuRecipeList', \mod\repasrc\Menu::getRecipeList($id));
      }
      break;
    }

    $tplTrans = array('recettes' => 'recipe', 'commentaires' => 'comments');
    $tpl = (isset($tplTrans[$section])) ? $tplTrans[$section] : $section;
      if (!empty($id)) {
        $modules = \mod\repasrc\Menu::getModulesList($id);
      } else {
        // Otherwise we get modules defined in session
        $modules = (isset($_SESSION['menu']['modules'])) ? $_SESSION['menu']['modules'] : 0;
      }
    if (isset($id) && !empty($id))
    	$me = \mod\repasrc\Menu::getDetail($id);
    if (isset($me) && !empty($me)) {
      $menu = $me;
    } else {
      $menu = array('id' => $id);
    }
    $page->smarty->assign(
    	array('section' => $section, 
    		'menu' => $menu,
    		'modulesList' => $modules
    	));
    $page->setLayout('repasrc/menu/'.$tpl);
    $page->display();
	}

	public static function hook_mod_repasrc_menu_compare($hookname, $userdata, $params) {
    \mod\user\Main::redirectIfNotLoggedIn();

    $page = new \mod\webpage\Main();
    $oldbrowser = (preg_match('/(?i)msie [1-8]/',$_SERVER['HTTP_USER_AGENT'])) ? 1 : 0;
    $page->smarty->assign('oldbrowser', $oldbrowser);

		// Remove menu from comparison list
		$mid = (isset($params[1])) ? $params[1] : null;
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

		$menus = array();
		foreach($_SESSION['menu']['comp'] as $mid) {
			$menuDetail = \mod\repasrc\Menu::getDetail($mid);
			$menuDetail['transport'] = \mod\repasrc\Analyze::menuTransportSummary($menuDetail);
			$menus[] = $menuDetail;
		}

		$noData = $families = array();

		$gctFootprintCol = new \mod\googlecharttools\Main();
		$gctTransportCol = new \mod\googlecharttools\Main();
		$gctMenuFootprint = new \mod\googlecharttools\Main();
		$gctFootprintCol->addColumn('Val', 'string');
		$gctFootprintCol->addRow('Empreinte écologique foncière des recettes');
		$gctTransportCol->addColumn('Val', 'string');
		$gctTransportCol->addRow('Empreinte écologique foncière des transports');
		$gctFootprintCol->addColumn('Val', 'string');
		$gctFootprintCol->addRow('Empreinte écologique des menus');
		foreach($menus as $menu) {
			foreach($menu['recipesList'] as $recipe) {
					// Foodstuff with no footprint value
				$gctFootprintCol->addColumn($recipe['label'], 'number');
				$gctFootprintCol->addRow($recipe['footprint']);
				$gctTransportCol->addColumn($recipe['label'], 'number');
				$gctTransportCol->addRow($recipe['transport']['total']['footprint']);
				$gctTransportCol->addColumn($menu['label'], 'number');
				$gctTransportCol->addRow($menu['footprint']);
				if (isset($recipe['families']) && sizeof($recipe['families']) > 0) {
					$families[] = array_shift(array_keys($recipe['families']));
				}
			}
		}
		$page->smarty->assign(array(
			'menuList' => $menus,
			'noData' => $noData,
			'dataFootprintCol' => $gctFootprintCol->getJSON(),
			'dataTransportCol' => $gctTransportCol->getJSON(),
			'dataMenuFootprint' => $gctTransportCol->getJSON(),
			'menuCompareList' => $_SESSION['menu']['comp']
		));
		$page->setLayout('repasrc/menu/compare');
    $page->display();
	}

	public static function hook_mod_repasrc_menu_analyze($hookname, $userdata, $params) {
    \mod\user\Main::redirectIfNotLoggedIn();
		if (isset($params[2]))
			$id = $params[2];
    $page = new \mod\webpage\Main();
    $oldbrowser = (preg_match('/(?i)msie [1-8]/',$_SERVER['HTTP_USER_AGENT'])) ? 1 : 0;
    $page->smarty->assign('oldbrowser', $oldbrowser);
		
		if (!isset($section) || is_null($section)) $section = $params[1];

		if (!empty($id)) {
			$modules = \mod\repasrc\Recipe::getModulesList($id);
		} else {
			$modules = (isset($_SESSION['menu']['modules'])) ? $_SESSION['menu']['modules'] : 0;
		}

		$menuDetail = \mod\repasrc\Menu::getDetail($id);

		$noData = array();

		switch($section) {
			case 'resume':
				$noData = $families = array();
				$gctPie = new \mod\googlecharttools\Main();
				$gctCol = new \mod\googlecharttools\Main();
				$gctPie->addColumn('Aliment', 'string');
				$gctPie->addColumn('', 'number');
				$gctCol->addColumn('Val', 'string');
				$gctCol->addRow('');
				foreach ($menuDetail['recipesList'] as $recipe) {
					$gctPie->addRow($recipe['label']);
					$gctPie->addRow($recipe['footprint']);
					$gctCol->addColumn($recipe['label'], 'number');
					$gctCol->addRow($recipe['footprint']);
				}
				$page->smarty->assign(array(
					'dataFootprintPie' => $gctPie->getJSON(),
					'dataFootprintCol' => $gctCol->getJSON()
				));
			break;
			case 'saisonnalite': 
				$menuDetail['seasonality'] = \mod\repasrc\Analyze::menuSeasonality($menuDetail);
			break;
			case 'transport':
				$rcInfos = \mod\repasrc\RC::getRcInfos($_SESSION['rc']);
				$rcGeo = \core\Core::$db->fetchRow('SELECT ST_X(rrc_zv_geom) AS x, ST_Y(rrc_zv_geom) AS y, rrc_zv_label AS label FROM rrc_geo_zonevalue WHERE rrc_zv_id = ?', array($rcInfos['zoneid']));
				$page->smarty->assign('rcGeo', $rcGeo);

				$graph = \mod\repasrc\Graph::menuTransport($menuDetail);
				$page->smarty->assign(array(
					'colors' => $graph['colors'],
					'dataFootprintCol1' => $graph['col1']->getJSON(),
					'dataFootprintCol2' => $graph['col2']->getJSON(),
					'dataFootprintPie' => $graph['comp']->getJSON()
				));
			break;
			case 'mode':
				$graph = \mod\repasrc\Graph::menuProductionConservation($menuDetail);
				$page->smarty->assign(array(
						'dataConservation' => $graph['pie1']->getJSON(),
						'dataProduction' => $graph['pie2']->getJSON()
					));
			break;
			case 'prix':
			$graph = \mod\repasrc\Graph::menuPrice($menuDetail);
			if (isset($graph['col1'])) {
				$page->smarty->assign(array(
					'dataFootprintCol1' => $graph['col1']['graph']->getJSON(),
					'colors1' => $graph['col1']['colors']
					));
			}
			if (isset($graph['col2'])) {
				$page->smarty->assign(array(
					'dataFootprintCol2' => $graph['col2']['graph']->getJSON(),
					'colors2' => $graph['col2']['colors']
					));
			}
		}

		if (!empty($id)) {
			$modules = \mod\repasrc\Menu::getModulesList($id);
		} else {
			$modules = (isset($_SESSION['menu']['modules'])) ? $_SESSION['menu']['modules'] : 0;
		}

		$tplTrans = array('saisonnalite' => 'seasonality', 'transport' => 'transport',  'prix' => 'price');
		$tpl = (isset($tplTrans[$section])) ? $tplTrans[$section] : $section;
		$page->setLayout('repasrc/menu/analyze/'.$tpl);
		$page->smarty->assign(array(
			'section' => $section,
			'menu' => $menuDetail,
			'modulesList' => $modules
		));
		$page->display();
	}

	/* ************** */
	/*    FOODPLAN    */
	/* *************  */

	public static function hook_mod_repasrc_foodplan($hookname, $userdata) {
    \mod\user\Main::redirectIfNotLoggedIn();
		$action = $params[1];
		if (isset($params[2]) && !empty($params[2])) {
			$num = $params[2];
		}
	}

	/* ************ */
	/*    IMPORT    */
	/* ***********  */

	public static function hook_mod_repasrc_import($hookname, $userdata, $urlmatches) {
		$page = new \mod\webpage\Main();
		$page->setLayout('arkeogis/import');
		$page->display();
	} 

	public static function hook_mod_arkeogis_repasrc_submit($hookname, $userdata, $urlmatches) {
		$params = array('mod' => 'repasrc', 'file' => 'templates/import.json');
		$form = new \mod\form\Form($params);
		if ($form->validate()) {
			$separator = $form->getValue('separator');
			$enclosure = $form->getValue('enclosure');
			$file = $form->getValue('dbfile');
			$skipline = $form->getValue('skipline');
			$description = $form->getValue('description');
			$result =	\mod\repasrc\Recipe::importCsv($file['tmp_name'], $separator, $enclosure, $skipline, $lang, $description);
			unlink($file['tmp_name']);
			$page = new \mod\webpage\Main();
			$page->smarty->assign("result", $result);
		}
		$page->setLayout('arkeogis/import');
		$page->display();
	}

  /* ************** */
  /*     Image      */
  /* ************** */

  public static function hook_mod_repasrc_get_image($hookname, $userdata, $urlmatches) {
    print_r($urlmatches);
    $filename = $urlmatches[1];
    $title = $urlmatches[2];
    $path = dirname(__FILE__).'/tmp/'.str_replace('---', '/', $filename).'.png'; 
    header("Pragma: public"); // required 
    header("Expires: 0"); 
    header("Cache-Control: must-revalidate, post-check=0, pre-check=0"); 
    header("Cache-Control: private",false); // required for certain browsers 
    header("Content-Type: image/png"); 
    header("Content-Disposition: attachment; filename=\"".urldecode($title)."\";" ); 
    header("Content-Transfer-Encoding: binary"); 
    header("Content-Length: ".filesize($path)); 
    ob_clean(); 
    flush(); 
    readfile($path); 
  } 

}
