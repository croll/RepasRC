<?php  //  -*- mode:php; tab-width:2; c-basic-offset:2; -*-

namespace mod\repasrc;

class Recipe {

	function __construct() {
	}

	public static function search($rc_id='', $label='', $type='', $foodstuff='', $shared='', $owner='') {

		if (empty($rc_id) && isset($_SESSION['login'])) $rc_id = \mod\repasrc\RC::getUserRC($_SESSION['login']);

		$params = array();
		$q = 'SELECT DISTINCT rrc_re_id AS id, rrc_re_public AS shared, rrc_re_label AS label, rrc_re_component AS component, rrc_re_persons AS persons, rrc_re_rrc_rc_id AS owner, rrc_re_creation AS creation, rrc_re_modification AS modification FROM rrc_recipe AS re';
		$w = ' WHERE 1=1';
		if ($label) {
			$params[] = $label;
			$w.= " AND UPPER(rrc_re_label) LIKE UPPER(?)";	
	}
		if ($type) {
			$params[] = $type;
			$w.= ' AND rrc_re_component=?';	
		}
		if ($foodstuff) {
			$params[] = $foodstuff;
			$q.= ' LEFT JOIN rrc_recipe_foodstuff AS rf ON re.rrc_re_id=rf.rrc_rf_rrc_recipe_id LEFT JOIN rrc_foodstuff AS fs ON rf.rrc_rf_rrc_foodstuff_id=fs.rrc_fs_id';
			$w.= " AND rrc_fs_label_caps LIKE UPPER(?)";	
		}
		if ($shared && !$owner) {
			$w.= ' AND rrc_re_public=\'1\'';	
		} else if (!$shared && !$owner) {
			$params[] = $rc_id;
			$w.= ' AND rrc_re_rrc_rc_id=?';	
		} else if ($owner) {
			switch($owner) {
				// Recipe flagged as admin
				case "me":
					$params[] = $rc_id;
					$w.= ' AND rrc_re_rrc_rc_id=?';	
				break;
				// Recipe flagged as admin
				case "admin":
					$w.= ' AND rrc_re_byadmin=1';
				break;
				// Other recipes
				case "other":
					$params[] = $rc_id;
					$w.= ' AND rrc_re_rrc_rc_id != ? AND rrc_re_byadmin!=1 AND rrc_re_public=1';
				break;
			}
		}
		$o = " ORDER BY label";
		$query = $q.$w.$o;
		$recipes = array();	
		$recipes['STARTER'] = array();
		$recipes['MEAL'] = array();
		$recipes['CHEESE/DESSERT'] = array();
		$recipes['BREAD'] = array();
		foreach(\core\Core::$db->fetchAll($query, $params) as $row) {
			if (strstr($row['modification'], '0000')) $row['modification'] = '-';
			$row['hasFoodstuff'] = (int)self::recipeHasFoodstuff($row['id']);
			$recipes[$row['component']][] = $row;
		}
		return array_merge($recipes['STARTER'], $recipes['MEAL'], $recipes['CHEESE/DESSERT'], $recipes['BREAD']);
	}

	public static function recipeHasFoodstuff($id) {
		$num = \core\Core::$db->fetchOne('SELECT count(*) as nb FROM rrc_recipe_foodstuff WHERE rrc_rf_rrc_recipe_id=?', array($id));
		return ($num > 0) ? true : false;
	}

	public static function getFoodstuffList($id) {
		$params = array($id);
		$q = "SELECT rrc_rf_id AS foodstuff_recipe_id, rrc_rf_quantity_unit AS unit, rrc_rf_quantity_value AS quantity, rrc_rf_price AS price, rrc_rf_conservation as conservation, rrc_rf_production AS production, rrc_rf_rrc_foodstuff_synonym_id AS synonym_id, rrc_rf_rrc_foodstuff_id AS foodstuff_id, rrc_zv_label AS zone, rrc_zt_label as zone_type ";
		$q.= "FROM rrc_recipe_foodstuff AS rf ";
		$q.= "LEFT JOIN rrc_origin AS ori ON rf.rrc_rf_id=ori.rrc_or_rrc_recipe_foodstuff_id "; 
		$q.= "LEFT JOIN rrc_geo_zonevalue AS zv ON ori.rrc_or_rrc_geo_zonevalue_id=zv.rrc_zv_id "; 
		$q.= "LEFT JOIN rrc_geo_zonetype AS zt ON zv.rrc_zv_rrc_geo_zonetype_id=zt.rrc_zt_id ";
		$q.= "WHERE rrc_rf_rrc_recipe_id=? ORDER BY rrc_rf_id";
		$fs = array();
		foreach(\core\Core::$db->fetchAll($q, $params) as $row) {
			$tmp = array();
			if (!empty($row['synonym_id'])) {
				$infos = \mod\repasrc\Foodstuff::search(NULL, NULL, NULL, array(array('id' => $row['foodstuff_id'], 'synonym_id' => $row['synonym_id'])));
			} else {
				$infos = \mod\repasrc\Foodstuff::search(NULL, NULL, NULL, array(array('id' => $row['foodstuff_id'])), false);
			}
			$tmp['foodstuff_recipe_id'] = $row['foodstuff_recipe_id'];
			$tmp['unit'] = $row['unit'];
			$tmp['quantity'] = $row['quantity'];
			$tmp['price'] = $row['price'];
			$tmp['conservation'] = $row['conservation'];
			$tmp['production'] = $row['production'];
			$tmp['foodstuff'] = $infos;
			$fs[] = $tmp;
		}
		return $fs;
	}

}
