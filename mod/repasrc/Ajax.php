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
		$foodstuffName = (!empty($params['foodstuffName'])) ? $params['foodstuffName'] : NULL;
		return \mod\repasrc\Foodstuff::search($familyId, $subFamilyId, $foodstuffName);
	}
}
