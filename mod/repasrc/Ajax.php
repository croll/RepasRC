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
		return \mod\repasrc\Foodstuff::search($familyId, $subFamilyId);
	}

	public static function searchRecipe($params) {
		$typeId = (!empty($params['typeId'])) ? $params['typeId'] : NULL;
		$componentId = (!empty($params['componentId'])) ? $params['componentId'] : NULL;
		return \mod\repasrc\Recipe::searchComputed(12, $typeId, $componentId, NULL, NULL, (\mod\user\Main::userHasRight('Voir toutes les recettes')));
	}

	public static function showRecipeDetail($params) {
		$id = $params['id'];
		$foodstuffList = \mod\repasrc\Recipe::getFoodstuffList($id);
		$recipe = \mod\repasrc\Recipe::getDetail($id);
    $page = new \mod\webpage\Main();
		$page->smarty->assign('recipe', $recipe);
		$page->smarty->assign('foodstuffList', $foodstuffList);
		\core\Core::log($detail);
		\core\Core::log($foodstuffList);
		return array('title' => $recipe['label'], 'content' => $page->smarty->fetch('repasrc/recipe/detail'));
	}
}
