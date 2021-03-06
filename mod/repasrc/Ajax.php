<?php  //  -*- mode:php; tab-width:2; c-basic-offset:2; -*-

namespace mod\repasrc;

class Ajax {

	public static function getFamilies() {
		return \mod\repasrc\Foodstuff::getFamilies();
	}

	public static function getSubFamilies($params) {
		$id = (isset($params['id']) && !empty($params['id'])) ? $params['id'] : NULL;
		return \mod\repasrc\Foodstuff::getSubFamilies($id);
	}

	public static function searchFoodstuff($params) {
		$familyId = (!empty($params['familyId']) && $params['familyId'] != 
			 'null') ? $params['familyId'] : NULL;
		$subFamilyId = (!empty($params['subFamilyId'])) ? $params['subFamilyId'] : NULL;
		$label = (!empty($params['label'])) ? $params['label'] : NULL;
		$limit = (!empty($params['limit'])) ? $params['limit'] : NULL;
		$offset = (!empty($params['offset'])) ? $params['offset'] : 0;
		$allResults = \mod\repasrc\Foodstuff::searchAll($familyId, $subFamilyId, $label, NULL);
		$fsList = (!is_null($limit) && !is_null($offset)) ? array_splice($allResults, $offset, $limit) : $allResults;
		$numResults = sizeof($allResults);	
		return array('fsList' => $fsList, 'numResults' => $numResults);
	}

	public static function showFoodstuffDetail($params) {
		$infos['id'] = $params['id'];
		$infos['synonym_id'] = ((isset($params['synonymId'])) ? $params['synonymId'] : null);
    $page = new \mod\webpage\Main();
		if ($infos['synonym_id']) {
			$parent = \mod\repasrc\Foodstuff::search(NULL, NULL, NULL, array(array('id' => $params['id'], 'synonym_id' => NULL)), true);
			$page->smarty->assign('parent', $parent);
		}
		$foodstuff = \mod\repasrc\Foodstuff::search(NULL, NULL, NULL, array($infos), false);
		$recipeDetail = \mod\repasrc\Recipe::getDetail((int)$params['recipeId']);
		$page->smarty->assign(
			array(
					'recipe' => $recipeDetail, 
					'foodstuff' => $foodstuff[0], 
					'modulesList' => $params['modulesList']
			)
		);
		if (isset($params['recipeFoodstuffId'])) 
			$page->smarty->assign('recipeFoodstuffId', (int)$params['recipeFoodstuffId']);
		$label = (isset($foodstuff[0]['synonym'])) ? $foodstuff[0]['synonym'] : $foodstuff[0]['label'];
		$ret = array('title' => $label, 'content' => $page->smarty->fetch('repasrc/recipe/foodstuff_detail'));
		return $ret;
	}

	public static function searchRecipe($params) {
		$typeId = (!empty($params['typeId'])) ? $params['typeId'] : NULL;
		$componentId = (!empty($params['componentId'])) ? $params['componentId'] : NULL;
		$recipeLabel = (!empty($params['recipeLabel'])) ? $params['recipeLabel'] : NULL;
		$foodstuffName = (!empty($params['foodstuffName'])) ? $params['foodstuffName'] : NULL;
		$limit = (!empty($params['limit'])) ? $params['limit'] : 'ALL';
		$offset = (!empty($params['offset'])) ? $params['offset'] : 0;
		$recipeList = \mod\repasrc\Recipe::searchComputed($_SESSION['rc'], $typeId, $componentId, $recipeLabel, $foodstuffName, (\mod\user\Main::userHasRight('Voir toutes les recettes')), $limit, $offset);
		$numResults = \mod\repasrc\Recipe::search($_SESSION['rc'], $typeId, $componentId, $recipeLabel, $foodstuffName, (\mod\user\Main::userHasRight('Voir toutes les recettes')), false, 'ALL', 0, true);
		return array('recipeList' => $recipeList, 'numResults' => $numResults);
	}

	public static function showRecipeDetail($params) {
		$id = $params['id'];
		$comp = (isset($params['comparison'])) ? $params['comparison'] : false;
		$menuId = (isset($params['menuId'])) ? $params['menuId'] : null;
		$menuRecipeId = (isset($params['menuRecipeId'])) ? $params['menuRecipeId'] : null;
		$recipeDetail = \mod\repasrc\Recipe::getDetail($id);
 	   $page = new \mod\webpage\Main();
		$page->smarty->assign(
			array(
				'recipe' => $recipeDetail,
				'menuId' => $menuId,
				'menuRecipeId' => $menuRecipeId,
				'comparison' => $comp
			)
		);
		return array('title' => $recipeDetail['label'], 'content' => $page->smarty->fetch('repasrc/recipe/detail'));
	}

	public static function getCities($params) {
		$name='%'.\core\Tools::removeAccents(str_replace(' ', '_', $params['q'])).'%';
		\core\Core::log($name);
		$query="SELECT rrc_zv_id AS id, rrc_zv_label AS label, rrc_zv_label_caps as label_caps FROM rrc_geo_zonevalue WHERE UPPER(rrc_zv_label_caps) ILIKE UPPER(?) ORDER BY rrc_zv_label_caps";
		$ret = array();
		foreach(\core\Core::$db->fetchAll($query, array($name)) as $row) {
			$row['label_caps'] = ucfirst(strtolower(str_replace('_', ' ',$row['label_caps'])));
			$ret[] = $row;
		}
		return $ret;
	}

	public static function deleteRecipeFoodstuff($params) {
		if (isset($params['id'])) {
			\mod\repasrc\Foodstuff::deleteFromRecipe((int)$params['id']);
			return true;
		} else {
			return false;
		}
	}

	public static function deleteRecipe($params) {
		if (isset($params['id'])) {
			\mod\repasrc\Recipe::delete((int)$params['id']);
			return true;
		} else {
			return false;
		}
	}

	public static function duplicateRecipeModal($params) {
    $page = new \mod\webpage\Main();
		$page->smarty->assign('recipeId', (int)$params['id']);
		return array('content' => $page->smarty->fetch('repasrc/recipe/duplicate'));
	}

	public static function duplicateRecipe($params) {
		$form = new \mod\form\Form(array('mod' => 'repasrc', 'file' => 'templates/recipe/duplicate.json'));
		$validate = $form->validate();
		if ($validate) {
			$fields = $form->getFieldValues();
			$id = \mod\repasrc\Recipe::duplicate((int)$params['id'], $params['label']);
			$section = 'informations';
		}
		return $id;
	}

	/* MENU */

	public static function searchMenu($params) {
		$label = (!empty($params['label'])) ? $params['label'] : NULL;
		$typeId = (!empty($params['typeId'])) ? $params['typeId'] : NULL;
		$limit = (!empty($params['limit'])) ? $params['limit'] : 'ALL';
		$offset = (!empty($params['offset'])) ? $params['offset'] : 0;
		$menuList = \mod\repasrc\Menu::searchComputed($_SESSION['rc'], $label, (\mod\user\Main::userHasRight('Voir toutes les recettes')), $typeId, $limit, $offset);
		$numResults = \mod\repasrc\Menu::search($_SESSION['rc'], $label, (\mod\user\Main::userHasRight('Voir toutes les recettes')), $typeId, 'ALL', 0, true);

		return array('menuList' => $menuList, 'numResults' => $numResults);
	}

	public static function showMenuDetail($params) {
		$id = $params['id'];
		$comp = (isset($params['comparison'])) ? $params['comparison'] : false;
		$menuDetail = \mod\repasrc\Menu::getDetail($id);
    	$page = new \mod\webpage\Main();
		$page->smarty->assign(
			array(
				'menu' => $menuDetail,
				'comparison' => $comp
			)
		);
		return array('title' => $menuDetail['label'], 'content' => $page->smarty->fetch('repasrc/menu/detail'));
	}

	public static function deleteMenu($params) {
		if (isset($params['id'])) {
			\mod\repasrc\Menu::delete((int)$params['id']);
			return true;
		} else {
			return false;
		}
	}

	public static function deleteMenuRecipe($params) {
		if (isset($params['id'])) {
			\mod\repasrc\Menu::deleteRecipe((int)$params['id']);
			return true;
		} else {
			return false;
		}
	}

	public static function getMenuRecipeModal($params) {
		$menuId = (isset($params['menuId']) && !empty($params['menuId'])) ? (int)$params['menuId'] : NULL;
		$recipeId = (isset($params['recipeId']) && !empty($params['recipeId'])) ? (int)$params['recipeId'] : NULL;
		$menuRecipeId = (isset($params['menuRecipeId']) && !empty($params['menuRecipeId'])) ? (int)$params['menuRecipeId'] : NULL;
    $page = new \mod\webpage\Main();
		$page->smarty->assign(array(
			'recipeId' => $recipeId,
			'menuId' => $menuId,
			'menuRecipeId' => $menuRecipeId
		));
		return array('content' => $page->smarty->fetch('repasrc/menu/updateRecipe'));
	}

	public static function updateMenuRecipe($params) {
		$menuId = (isset($params['menuId']) && !empty($params['menuId'])) ? (int)$params['menuId'] : NULL;
		$recipeId = (isset($params['recipeId']) && !empty($params['recipeId'])) ? (int)$params['recipeId'] : NULL;
		$menuRecipeId = (isset($params['menuRecipeId']) && !empty($params['menuRecipeId'])) ? (int)$params['menuRecipeId'] : NULL;
		$portions = (int)$params['portions'];
		if ($recipeId) {
			\mod\repasrc\Menu::addRecipe($recipeId, $menuId, $portions);
		} else {
			\mod\repasrc\Menu::updateRecipe($menuRecipeId, $portions);
		}
		return true;
	}

	public static function getImage($params) {
		$hash = md5($params['img']);
		$dir1 = substr($hash, 0 , 2);
		$dir2 = substr($hash, 2, 2);
		$filename = substr($hash, 4, strlen($hash));
		$path = dirname(__FILE__).'/tmp/'.$dir1.'/'.$dir2;
		if (!is_dir($path)) {
			if (!mkdir($path, 0755, true)) {
				\core\Core::log('tmp directory not writable ?');
			}
			file_put_contents($path.'/'.$filename.'.png', base64_decode($params['img']));
		}
		return $dir1.'---'.$dir2.'---'.$filename;
	}

	public static function setHelpVisibility($params) {
		$display = (int)$params['displayHelp'];
		$_SESSION['displayHelp'] = $display;
	}
}
