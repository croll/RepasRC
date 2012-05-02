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
		$recipeInfos = \mod\repasrc\Recipe::getInfos($params['recipeId']);
		$tmp = preg_split('#/#', $recipeInfos['consumptiondate']);
		if ($tmp)
			$recipeInfos['consumptionmonth'] = trim($tmp[1]-1, '0');
		$page->smarty->assign(
			array(
					'recipe' => $recipeInfos, 
					'foodstuff' => $foodstuff, 'modulesList' => $params['modulesList'], 
					'seasonality' => \mod\repasrc\Foodstuff::parseSeasonality($foodstuff[0]['seasonality']),
					'action' => $params['action']
			)
		);
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
		for($i=0;$i<sizeof($foodstuffList);$i++) {
			$foodstuffList[$i]['foodstuff'][0]['seasonality'] = \mod\repasrc\Foodstuff::parseSeasonality($foodstuffList[$i]['foodstuff'][0]['seasonality']);
		}
		$recipeInfos = \mod\repasrc\Recipe::getDetail($id);
		\core\Core::log($recipeInfos);
		$tmp = preg_split('#/#', $recipeInfos['consumptiondate']);
		if ($tmp)
			$recipeInfos['consumptionmonth'] = trim($tmp[1]-1, '0');
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
		$query="SELECT rrc_zv_id AS id, rrc_zv_label AS label FROM rrc_geo_zonevalue WHERE rrc_zv_rrc_geo_zonetype_id = 8 AND rrc_zv_label_caps ILIKE ? ORDER BY rrc_zv_label";
		return \core\Core::$db->fetchAll($query, array($name));
	}
}
