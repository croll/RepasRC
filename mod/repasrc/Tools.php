<?php  //  -*- mode:php; tab-width:2; c-basic-offset:2; -*-

namespace mod\repasrc;

class Tools {

	public static function getCityInfos($name=NULL, $code=NULL) {
		$q = "SELECT ci_id AS id, ST_X(ci_geom) AS x, ST_Y(ci_geom) AS y FROM ark_city ";
		$args = array();
		if (!empty($name)) {
			$q .= "WHERE ci_nameupper ILIKE ?";
			$args[] = str_replace('?','_',strtoupper(iconv("utf-8", "ascii//TRANSLIT", $name)));
		}
		if (!empty($code)) {
			$q .= ((sizeof($args) == 1) ? 'AND' : 'WHERE')." ci_code = ?";
			$args[] = (string)$code;
		}
		if (sizeof($args) == 0) {
			throw new \Exception("City name and code are empty");
		}
		$res = \core\Core::$db->fetchAll($q, $args);
		if (sizeof($res) > 1) {
			throw new \Exception("More than one city found.");
		}
		return $res[0];
	}
	public static function getSquareCentroid($x0, $y0, $x1, $y1) {
		return array('x' => ($x0+($x1-$x0)/2), 'y' => ($y0+($y1-$y0)/2));
	}

	public static function getDistance($id1, $id2) {
		$q = "SELECT cast(ST_Distance_sphere((sELECT rrc_zv_geom FROM rrc_geo_zonevalue WHERE rrc_zv_id=?), (SELECT rrc_zv_geom FROM rrc_geo_zonevalue WHERE rrc_zv_id=?)) as decimal(15,2)) as distance;";
		$args = array((int)$id1, (int)$id2);
		return \core\Core::$db->fetchOne($q, $args);
	}

	public static function getDistanceAlternate($latitude1, $longitude1, $latitude2, $longitude2) {
		$earth_radius = 6371;
		$dLat = deg2rad($latitude2 - $latitude1);
		$dLon = deg2rad($longitude2 - $longitude1);
		$a = sin($dLat/2) * sin($dLat/2) + cos(deg2rad($latitude1)) * cos(deg2rad($latitude2)) * sin($dLon/2) * sin($dLon/2);
		$c = 2 * asin(sqrt($a));
		$d = $earth_radius * $c;
		return $d;
	}

	public static function transformPoint($point, $from, $to) {
		$args = array($from, $to);
		$p = \core\Core::$db->fetchOne("SELECT ST_AsText(ST_Transform(ST_GeomFromText('POINT(".(float)$point['x']." ".(float)$point['y'].")', ?), ?)) AS geom", $args);
		if (!preg_match("/POINT\((-?[0-9\.]+) +(-?[0-9\.]+)\)/", $p, $m)) 
			return NULL;
		return array('x' => $m[1], 'y' => $m[2]);
	}

	public static function getMonthLabel($num) {
		$months = array('Jan', 'Fev', 'Mar', 'Avr', 'Mai', 'Juin', 'Jui', 'Aout', 'Sep', 'Oct', 'Nov', 'Dec');
		return $months[(int)$num-1];
	}

	public static function gradient($startColor,$endColor, $stepNumber) {
		$colors = array($startColor);
		$sColor = str_split($startColor,2);
		$eColor = str_split($endColor,2);
		for($i = 0 ;$i< 3 ;$i++)
		{
			$diff [$i] = (hexdec($sColor[$i])-hexdec($eColor[$i]))/($stepNumber-2);
		}
		for ($i = 1;$i<$stepNumber-1;$i++)
		{
			$c = str_split($colors[$i-1],2);
			$colors[$i] = sprintf('%02X',max(0,min(255,(hexdec($c[0])-$diff[0])))).
				sprintf('%02X',max(0,min(255,(hexdec($c[1])-$diff[1])))).
				sprintf('%02X',max(0,min(255,(hexdec($c[2])-$diff[2]))));
		}
		$colors[$i] = $endColor;
		return $colors;
	}

	public static function getColorsArray($families) {
		$colors = array();
		foreach($families as $familyNum) {
			$done = false;
			if (!$familyNum) {
				$colors[] = '#000';
			} else {
				$co = \mod\repasrc\Foodstuff::$familyColors[$familyNum];
				foreach(self::gradient($co, 'ffffff', 9) as $c) {
					if (!in_array($c, $colors) && !$done) {
						$colors[] = $c;
						$done = true;
					}
				}
			}
		}
		return $colors;
	}

	public static function getBitsFromModulesList($modules) {
		$num = 0;
		$val = array('seasonality' => 1, 'production' => 2, 'transport' => 4, 'price' => 8);
		foreach($val as $k=>$v) {
			if ($modules[$k] == 1)
				$num+=$v;
		}
		return $num;
	}

	public static function getModulesListFromBits($num) {
		$modules = array();
		$val = array(1 => 'seasonality', 2 => 'production', 4 => 'transport', 8 => 'price');
		foreach($val as $k=>$v) {
			if ($k & $num)
				$modules[$v] = 1;
		}
		return $modules;
	}

}
