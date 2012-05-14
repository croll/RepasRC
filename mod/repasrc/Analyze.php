<?php  //  -*- mode:php; tab-width:2; c-basic-offset:2; -*-

namespace mod\repasrc;

class Analyze {

	public static function seasonality($recipeDetail) {
		$seasonality = array();
		$month = \mod\repasrc\Tools::getMonthLabel($recipeDetail['consumptionmonth']);
		foreach($recipeDetail['foodstuffList'] as $foodstuff) {
			if (($foodstuff['conservation'] == 'Frais' || $foodstuff['conservation'] == '') && (in_array('Légumes', $foodstuff['families']) || in_array('Fruits', $foodstuff['families']))) {
				if (empty($foodstuff['foodstuff']['seasonality'])) {
					$seasonality['noinfo'][] = $foodstuff['foodstuff']['label'];
				} else {
					if ($foodstuff['foodstuff']['seasonality'][$month] > 0) {
						$seasonality['ok'][] = $foodstuff['foodstuff']['label'];
					} else {
						$seasonality['nok'][] = $foodstuff['foodstuff']['label'];
					}
				}
			} else {
				$seasonality['out'][] = $foodstuff['foodstuff']['label'];
			}
		}
		return $seasonality;
	}

}
