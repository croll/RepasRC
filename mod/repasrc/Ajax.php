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
			$parent = \mod\repasrc\Foodstuff::search(NULL, NULL, NULL, array(array('id' => $params['id'], 'synonym_id' => NULL)), false);
			$page->smarty->assign('parent', $parent);
		}
		$foodstuff = \mod\repasrc\Foodstuff::search(NULL, NULL, NULL, array($infos), true);
		$recipeInfos = \mod\repasrc\Recipe::getDetail((int)$params['recipeId']);
		$page->smarty->assign(
			array(
					'recipe' => $recipeInfos, 
					'foodstuff' => $foodstuff, 'modulesList' => $params['modulesList']
			)
		);
		if (isset($params['recipeFoodstuffId'])) 
			$page->smarty->assign('recipeFoodstuffId', (int)$params['recipeFoodstuffId']);
		$label = (isset($foodstuff[0]['synonym'])) ? $foodstuff[0]['synonym'] : $foodstuff[0]['label'];
		return array('title' => $label, 'content' => $page->smarty->fetch('repasrc/recipe/foodstuff_detail'));
	}

	public static function searchRecipe($params) {
		$typeId = (!empty($params['typeId'])) ? $params['typeId'] : NULL;
		$componentId = (!empty($params['componentId'])) ? $params['componentId'] : NULL;
		return \mod\repasrc\Recipe::searchComputed($_SESSION['rc'], $typeId, $componentId, NULL, NULL, (\mod\user\Main::userHasRight('Voir toutes les recettes')));
	}

	public static function showRecipeDetail($params) {
		$id = $params['id'];
		$foodstuffList = \mod\repasrc\Recipe::getFoodstuffList($id);
		$recipeInfos = \mod\repasrc\Recipe::getDetail($id);
    $page = new \mod\webpage\Main();
		$page->smarty->assign(
			array(
				'recipe' => $recipeInfos, 
				'foodstuffList' => $foodstuffList
			)
		);
		return array('title' => $recipeInfos['label'], 'content' => $page->smarty->fetch('repasrc/recipe/detail'));
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

}
