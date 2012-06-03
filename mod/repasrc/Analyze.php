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

	public static function transport($recipeDetail) {
		$transport = array();
		$rcInfos = \mod\repasrc\RC::getRcInfos($_SESSION['rc']);
		$rcGeo = \core\Core::$db->fetchRow('SELECT ST_X(rrc_zv_geom) AS x, ST_Y(rrc_zv_geom) AS y, rrc_zv_label AS zonelabel FROM rrc_geo_zonevalue WHERE rrc_zv_id = ?', array($rcInfos['zoneid']));
		$outp = array();
		$markers = array();
		$lines = array();
		foreach($recipeDetail['foodstuffList'] as $foodstuff) {
			$id = $foodstuff['recipeFoodstuffId'];
			$precise = false;
			// For each store informations and calculate distance
			for($i=0; $i<sizeof($foodstuff['origin']);$i++) {
				if (!empty($foodstuff['origin'][$i]['zoneid'])) {
					$q = 'SELECT ST_X(rrc_zv_geom) AS x, ST_Y(rrc_zv_geom) AS y, rrc_zv_label AS label FROM rrc_geo_zonevalue WHERE rrc_zv_id = ?';
					$geoInfos = \core\Core::$db->fetchRow($q, array($foodstuff['origin'][$i]['zoneid']));
					$foodstuff['origin'][$i]['x'] = $geoInfos['x'];
					$foodstuff['origin'][$i]['y'] = $geoInfos['y'];
					if ($i == 0) {
						$foodstuff['origin'][$i]['distance'] = 0;
					} else {
						$foodstuff['origin'][$i]['distance'] = round($foodstuff['origin'][$i-1]['distance']+\mod\repasrc\Tools::getDistanceAlternate($foodstuff['origin'][$i-1]['x'], $foodstuff['origin'][$i-1]['y'], $foodstuff['origin'][$i]['x'], $foodstuff['origin'][$i]['y']));
					}
					$precise = true;
					$markers[$geoInfos['label']][] = $foodstuff['foodstuff'];
					$lines[$id][] = $geoInfos['label'];
					$foodstuff['origin'][$i]['location'] = \mod\repasrc\Foodstuff::getOrigin($foodstuff['origin'][$i]['location']);
				} else {
					$markers[$rcGeo['zonelabel']][] = $foodstuff['foodstuff'];
				}
			} 
			// Add RC as last step
			if ($precise == true) {
				$num = sizeof($foodstuff['origin']);
				$foodstuff['origin'][$num]['zonelabel'] = $rcInfos['zonelabel'];
				$foodstuff['origin'][$num]['x'] = $rcGeo['x'];
				$foodstuff['origin'][$num]['y'] = $rcGeo['y'];
				$foodstuff['origin'][$num]['location'] = 'Précise';
				$foodstuff['origin'][$num]['distance'] = round($foodstuff['origin'][$num-1]['distance']+\mod\repasrc\Tools::getDistanceAlternate($foodstuff['origin'][$num-1]['x'], $foodstuff['origin'][$num-1]['y'], $rcGeo['x'], $rcGeo['y']));
				$lines[$id][] = $rcGeo['zonelabel'];
			}

			$outp[$foodstuff['foodstuff']['label']] = $foodstuff['origin'];
		}
		return array('datas' => $outp, 'markers' => $markers, 'lines' => array_values($lines));
	}

}
