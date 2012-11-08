<?php  //  -*- mode:php; tab-width:2; c-basic-offset:2; -*-

namespace mod\repasrc;

class Analyze {

	public static function seasonality($recipeDetail, $consumptiondate=null) {
		$seasonality = array('ok' => NULL, 'nok' => NULL, 'out' => NULL);
		if (!is_null($consumptiondate)) {
			$month = \mod\repasrc\Tools::getMonthLabel($consumptiondate);
		} else if (!empty($recipeDetail['consumptionmonth'])){
			$m = \mod\repasrc\Tools::getMonthLabel($recipeDetail['consumptionmonth']);
			if (!is_null($m) && !empty($m)) {
				$month = $m;
			} else {
				$month = null;
			}
		}
		foreach($recipeDetail['foodstuffList'] as $foodstuff) {
			$label = \mod\repasrc\Recipe::getFoodstuffLabel($foodstuff);
			if (($foodstuff['conservation'] == 'G1' || $foodstuff['conservation'] == '') && (in_array('Légumes', $foodstuff['families']) || in_array('Fruits', $foodstuff['families']))) {
				if (empty($foodstuff['foodstuff']['seasonality'])) {
					$seasonality['noinfo'][] = $label;
				} else {
					if (isset($month) && $foodstuff['foodstuff']['seasonality'][$month] > 0) {
						$seasonality['ok'][] = $label;
					} else {
						$seasonality['nok'][] = $label;
					}
				}
			} else {
				$seasonality['out'][] = $label;
			}
		}
		return $seasonality;
	}

	public static function menuSeasonality($menuDetail) {
		$seasonality = array('ok' => array(), 'nok' => array(), 'out' => array(), 'noinfo' => array());
		foreach($menuDetail['recipesList'] as $recipeDetail) {
			$consumptionmonth = isset($menuDetail['consumptionmonth']) ? $menuDetail['consumptionmonth'] : null;
			$recipeSeasonality = self::seasonality($recipeDetail, $consumptionmonth);
			foreach(array('ok','nok','out','noinfo') as $type) {
				if (isset($recipeSeasonality[$type]) &&is_array($recipeSeasonality[$type])) {
					foreach($recipeSeasonality[$type] as $recipeName) {
						if (!in_array($recipeName, $seasonality[$type])) {
							$seasonality[$type][] = $recipeName;
						}
					} 
				}
			}
		} 
		return $seasonality;
	}

	public static function transport($recipeDetail) {
		$transport = array();
		$rcInfos = \mod\repasrc\RC::getRcInfos($_SESSION['rc']);
		$rcGeo = \core\Core::$db->fetchRow('SELECT ST_X(rrc_zv_geom) AS x, ST_Y(rrc_zv_geom) AS y, rrc_zv_label AS zonelabel FROM rrc_geo_zonevalue WHERE rrc_zv_id = ?', array($rcInfos['zoneid']));
		$datas = array();
		$total = array('distance' => 0, 'footprint' => 0);
		$markers = array();
		$lines = array();
		$nodata = array();
		foreach($recipeDetail['foodstuffList'] as $foodstuff) {
			$id = $foodstuff['recipeFoodstuffId'];
			$foodstuff['transport'] = array('distance' => 0, 'footprint' => 0);
			$precise = false;
			// For each, store informations and calculate distance
			if (isset($foodstuff['origin']['nodata']) && ($foodstuff['origin']['nodata']) === true) {
				$nodata[] = $foodstuff['foodstuff']['label'];
				continue;
			}
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
				} else {
					$foodstuff['origin'][$i]['distance'] = self::getDistanceFromOrigin($foodstuff['origin'][$i]['location']);
					$total['distance'] +=  $foodstuff['origin'][$i]['distance'];
					$foodstuff['transport']['distance'] += $foodstuff['origin'][$i]['distance'];
					$markers[$rcGeo['zonelabel']][] = $foodstuff['foodstuff'];
				}
				$foodstuff['origin'][$i]['location_label'] = \mod\repasrc\Foodstuff::getOrigin($foodstuff['origin'][$i]['location']);
				if (!isset($foodstuff['origin'][$i]['location'])) continue;
				$foodstuff['origin'][$i]['footprint'] = self::getC($foodstuff['origin'][$i]['location'], ($foodstuff['quantity']/$recipeDetail['persons']), ((isset($foodstuff['origin'][$i]['distance']) ? $foodstuff['origin'][$i]['distance'] : null)));
			} 
			// Add RC as last step
			$num = sizeof($foodstuff['origin']);
			if ($precise == true) {
				$foodstuff['origin'][$num]['zonelabel'] = $rcInfos['zonelabel'];
				$foodstuff['origin'][$num]['x'] = $rcGeo['x'];
				$foodstuff['origin'][$num]['y'] = $rcGeo['y'];
				$foodstuff['origin'][$num]['location'] = 'LETMECHOOSE';
				$foodstuff['origin'][$num]['location_label'] = 'Précise';
				$foodstuff['origin'][$num]['distance'] = round($foodstuff['origin'][$num-1]['distance']+\mod\repasrc\Tools::getDistanceAlternate($foodstuff['origin'][$num-1]['x'], $foodstuff['origin'][$num-1]['y'], $rcGeo['x'], $rcGeo['y']));
				$foodstuff['transport']['distance'] += $foodstuff['origin'][$num]['distance'];
				$total['distance'] += $foodstuff['origin'][$num]['distance'];
				$foodstuff['origin'][$num]['footprint'] = self::getC($foodstuff['origin'][$num]['location'], ($foodstuff['quantity']/$recipeDetail['persons']), ((isset($foodstuff['origin'][$num]['distance']) ? $foodstuff['origin'][$num]['distance'] : null)));
				$foodstuff['transport']['footprint'] +=  $foodstuff['origin'][$num]['footprint'];
				$total['footprint'] += $foodstuff['origin'][$num]['footprint'];
				$markers[$rcGeo['zonelabel']][] = $foodstuff['foodstuff'];
			} else if ($num) {
				$total['footprint'] += $foodstuff['origin'][$num-1]['footprint'];
				$foodstuff['transport']['footprint'] += $foodstuff['origin'][$num-1]['footprint'];
			}
			if (isset($lines[$id]) && sizeof($lines[$id]))
				$lines[$id][] = $rcGeo['zonelabel'];

			$datas[$foodstuff['foodstuff']['label']] = $foodstuff;
		}
		return array('datas' => $datas, 'markers' => $markers, 'lines' => array_values($lines), 'total' => $total, 'nodata' => $nodata);
	}

	public static function menuTransportSummary($menuDetail) {
		$tr = array('distance' => 0, 'footprint' => 0);
		foreach($menuDetail['recipesList'] as $recipe) {
			$tr['distance'] += $recipe['transport']['total']['distance'];
			$tr['footprint'] += $recipe['transport']['total']['footprint'];
		}
		return $tr;
	}

	public static function getC($locationType, $quantity, $distance) {
		switch($locationType) {
			case 'LOCAL':
				$emi = 0.328;
				$distance = self::getDistanceFromOrigin('LOCAL');
				break;
			case 'REGIONAL':
				$emi = 0.074;
				$distance = self::getDistanceFromOrigin('REGIONAL');
				break;
			case 'FRANCE':
				$emi = 0.030;
				$distance = self::getDistanceFromOrigin('FRANCE');
				break;
			case 'EUROPE':
				$emi = 0.030;
				$distance = self::getDistanceFromOrigin('EUROPE');
				break;
			case 'WORLD':
				$emi = 0.00108;
				$distance = self::getDistanceFromOrigin('WORLD');
				break;
			case 'LETMECHOOSE':
				if ($distance <= 40) {
					$emi = 0.328;
				} else if ($distance <= 250) {
					$emi = 0.074;
				} else {
					$emi = 0.03;
				}
			break;
		}
		return round($quantity*0.001*$distance*0.001*$emi*0.964*10000,6);
	}

	public static function getDistanceFromOrigin($origin) {
		switch($origin) {
		case 'LOCAL':
			return 50;
			break;
		case 'REGIONAL':
			return 150;
			break;
		case 'FRANCE':
			return 500;
			break;
		case 'EUROPE':
			return 2000;
			break;
		case 'WORLD':
			return 6000;
			break;
		default:
			return null;
		}
	}

}
