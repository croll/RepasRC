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
		$familyId = (!empty($params['familyId'])) ? $params['familyId'] : NULL;
		$subFamilyId = (!empty($params['subFamilyId'])) ? $params['subFamilyId'] : NULL;
		$fsList = \mod\repasrc\Foodstuff::searchAll($familyId, $subFamilyId);
		return $fsList;
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
		$ret = \mod\repasrc\Recipe::searchComputed($_SESSION['rc'], $typeId, $componentId, NULL, NULL, (\mod\user\Main::userHasRight('Voir toutes les recettes')));
		return $ret;
	}

	public static function showRecipeDetail($params) {
		$id = $params['id'];
		$menuId = (isset($params['menuId'])) ? $params['menuId'] : null;
		$menuRecipeId = (isset($params['menuRecipeId'])) ? $params['menuRecipeId'] : null;
		$recipeDetail = \mod\repasrc\Recipe::getDetail($id);
 	   $page = new \mod\webpage\Main();
		$page->smarty->assign(
			array(
				'recipe' => $recipeDetail,
				'menuId' => $menuId,
				'menuRecipeId' => $menuRecipeId
			)
		);
		return array('title' => $recipeDetail['label'], 'content' => $page->smarty->fetch('repasrc/recipe/detail'));
	}

	public static function getCities($params) {
		$name=$params['q'].'%';
		$query="SELECT rrc_zv_id AS id, rrc_zv_label AS label FROM rrc_geo_zonevalue WHERE rrc_zv_label_caps ILIKE ? ORDER BY rrc_zv_label";
		return \core\Core::$db->fetchAll($query, array($name));
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

	/* MENU */

	public static function searchMenu($params) {
		$label = (!empty($params['label'])) ? $params['label'] : NULL;
		$typeId = (!empty($params['typeId'])) ? $params['typeId'] : NULL;
		$ret = \mod\repasrc\Menu::searchComputed($_SESSION['rc'], $label, 1, $typeId);
		return $ret;
	}

	public static function showMenuDetail($params) {
		$id = $params['id'];
		$menuDetail = \mod\repasrc\Menu::getDetail($id);
    	$page = new \mod\webpage\Main();
		$page->smarty->assign(
			array(
				'menu' => $menuDetail,
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

}
