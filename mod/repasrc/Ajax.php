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
		return \mod\repasrc\Foodstuff::searchAll($familyId, $subFamilyId);
	}

	public static function showFoodstuffDetail($params) {
		$infos['id'] = $params['id'];
		$infos['synonym_id'] = $params['synonymId'];
    $page = new \mod\webpage\Main();
		if ($infos['synonym_id']) {
			$parent = \mod\repasrc\Foodstuff::search(NULL, NULL, NULL, array(array('id' => $params['id'], 'synonym_id' => NULL)), true);
			$page->smarty->assign('parent', $parent);
		}
		$foodstuff = \mod\repasrc\Foodstuff::search(NULL, NULL, NULL, array($infos), false);
		$page->smarty->assign(array('recipeId' => $params['recipeId'], 'foodstuff' => $foodstuff));
		$label = (isset($foodstuff[0]['synonym'])) ? $foodstuff[0]['synonym'] : $foodstuff[0]['label'];
		return array('title' => $label, 'content' => $page->smarty->fetch('repasrc/recipe/foodstuff_detail'));
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
		$page->smarty->assign(array('recipe' => $recipe, 'foodstuffList' => $foodstuffList));
		return array('title' => $recipe['label'], 'content' => $page->smarty->fetch('repasrc/recipe/detail'));
	}
}
