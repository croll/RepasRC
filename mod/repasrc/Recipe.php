<?php  //  -*- mode:php; tab-width:2; c-basic-offset:2; -*-

namespace mod\repasrc;

class Recipe {

	function __construct() {
	}

	public static function search($rc_id, $owner=NULL, $component=NULL, $label=NULL, $foodstuff=NULL, $shared=NULL, $getFoodstuff=false) {

		$params = array();
		$q = 'SELECT DISTINCT rrc_re_id AS id, rrc_re_public AS shared, rrc_re_label AS label, rrc_re_component AS component, rrc_re_persons AS persons, rrc_re_rrc_rc_id AS owner, rrc_re_creation AS creation, rrc_re_modification AS modification ';
		$q.= 'FROM rrc_recipe AS re ';
		$w = ' WHERE 1=1';
		if ($label) {
			$params[] = $label;
			$w.= " AND UPPER(rrc_re_label) LIKE UPPER(?)";	
	}
		if ($component) {
			$params[] = $component;
			$w.= ' AND rrc_re_component=?';	
		}
		if ($foodstuff) {
			$params[] = $foodstuff;
			$q.= 'LEFT JOIN rrc_recipe_foodstuff AS rf ON re.rrc_re_id=rf.rrc_rf_rrc_recipe_id LEFT JOIN rrc_foodstuff AS fs ON rf.rrc_rf_rrc_foodstuff_id=fs.rrc_fs_id ';
			$w.= " AND rrc_fs_label_caps LIKE UPPER(?) ";	
		}
		if ($shared && is_null($owner)) {
			$w.= ' AND rrc_re_public=\'1\' ';	
		} else if (is_null($shared) && is_null($owner)) {
			$params[] = $rc_id;
			$w.= ' AND rrc_re_rrc_rc_id=? ';	
		} else if ($owner) {
			switch($owner) {
				// Recipe flagged as admin
				case "me":
					$params[] = $rc_id;
					$w.= ' AND rrc_re_rrc_rc_id=? ';	
				break;
				// Recipe flagged as admin
				case "admin":
					$w.= ' AND rrc_re_byadmin=1 ';
				break;
				// Other recipes
				case "other":
					$params[] = $rc_id;
					$w.= ' AND rrc_re_rrc_rc_id != ? AND rrc_re_byadmin!=1 AND rrc_re_public=\'1\' ';
				break;
			}
		}
		$o = "ORDER BY label ";
		$query = $q.$w.$o;

		return \core\Core::$db->fetchAll($query, $params);
	}

	public static function searchComputed($rc_id, $owner=NULL, $component=NULL, $label=NULL, $foodstuff=NULL, $shared=NULL) {

		$recipes = self::search($rc_id, $owner, $component, $label, $foodstuff, $shared, true);

		$conservation['G1'] = 1;
		$conservation['G2'] = 0.83333;
		$conservation['G3'] = 0.83333;
		$conservation['G4'] = 0.83333;
		$conservation['G5'] = 0.83333;
		$conservation['G6'] = 0.3;
		$conservation['G7'] = 0.15;
		$conservation['G8'] = 1;
		$conservation['G9'] = 1;
		$conservation['10'] = 1;
		$conservation['11'] = 1;

		$result = array();
		
		foreach ($recipes as $recipe) {
			$recipe['families'] = $recipe['foodstuff'] = array();
			switch($recipe['component']) {
				case 'STARTER':
					$recipe['component'] = 'Entrée';
				break;	
				case 'MEAL':
					$recipe['component'] = 'Plat';
				break;	
				case 'CHEESE/DESSERT':
					$recipe['component'] = 'Fromage ou dessert';
				break;	
				case 'BREAD':
					$recipe['component'] = 'Pain';
				break;	
			}
			$recipe['shared'] = (!empty($recipe['shared'])) ? 'Partagée' : 'Privée';
			$recipe['label'] = str_replace("''", "'", $recipe['label']);
			$foodstuffList = self::getFoodstuffList($recipe['id']);
			$numFs = sizeof($foodstuffList);
			$recipe['footprint'] = 0;
			foreach($foodstuffList as $fs) {
				/* CHECK THAT */
				/* CHECK THAT */
				/* CHECK THAT */
				if (sizeof($fs['foodstuff']) == 0) {
					continue;
				}
				$footprint = $fs['foodstuff'][0]['footprint']*$fs['quantity'];
				if ($fs['conservation']) {
					$footprint = $footprint*$conservation[$fs['conservation']];
				}
				$recipe['footprint'] += $footprint;
				$fam = $fs['foodstuff'][0]['infos'][0]['family_group_id'].'_'.str_replace('_', ' ', $fs['foodstuff'][0]['infos'][0]['family_group']);
				if (!in_array($fam, $recipe['families'])) {
					$recipe['families'][] = $fam;  
				}
				$fs_label = (isset($fs['foodstuff'][0]['synonym'])) ? $fs['foodstuff'][0]['synonym'] : $fs['foodstuff'][0]['label'];
				if (!in_array($fs_label, $recipe['foodstuff'])) {
					$recipe['foodstuff'][] = $fs_label;  
				}
			}

			$result[] = $recipe;
		\core\Core::log($result);

		}
		/*
		$fp = fopen('/tmp/test.txt', 'w');
		fputs($fp, json_encode($recipes));
		fclose($fp);
		 */

		return $result;
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
