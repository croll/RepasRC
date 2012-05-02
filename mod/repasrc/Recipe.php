<?php  //  -*- mode:php; tab-width:2; c-basic-offset:2; -*-

namespace mod\repasrc;

class Recipe {

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
				$recipe['footprint'] = round($recipe['footprint'], 3);
			}

			$result[] = $recipe;

		}
		/*
		$fp = fopen('/tmp/test.txt', 'w');
		fputs($fp, json_encode($recipes));
		fclose($fp);
		 */

		return $result;
	}

	public static function hasFoodstuff($id) {
		$num = \core\Core::$db->fetchOne('SELECT count(*) as nb FROM rrc_recipe_foodstuff WHERE rrc_rf_rrc_recipe_id=?', array($id));
		return ($num > 0) ? true : false;
	}

	public static function getInfos($id) {
		if (empty($id)) return null;
		 return \core\Core::$db->fetchRow("SELECT rrc_re_id AS id, rrc_re_label AS label, rrc_re_component AS component, rrc_re_persons AS persons, rrc_re_byadmin AS admin, rrc_re_modules AS modules, rrc_re_hash AS hash, rrc_re_comment AS comment, rrc_re_public AS shared, TO_CHAR(rrc_re_consumptiondate, 'DD/MM/YYYY') AS consumptiondate, rrc_re_type AS \"type\" FROM rrc_recipe WHERE rrc_re_id=?", array($id));
	}

	public static function getFoodstuffList($id) {
		$params = array($id);
		$q = "SELECT rrc_rf_id AS foodstuff_recipe_id, rrc_rf_quantity_unit AS unit, rrc_rf_quantity_value AS quantity, rrc_rf_price AS price, rrc_rf_vat AS vat, rrc_rf_conservation as conservation, rrc_rf_production AS production, rrc_rf_rrc_foodstuff_synonym_id AS synonym_id, rrc_rf_rrc_foodstuff_id AS foodstuff_id, rrc_zv_label AS zone, rrc_zt_label as zone_type ";
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
			$tmp['vat'] = $row['vat'];
			$tmp['conservation'] = $row['conservation'];
			$tmp['production'] = $row['production'];
			$tmp['foodstuff'] = $infos;
			$fs[] = $tmp;
		}
		return $fs;
	}

	public static function getDetail($id) {
		$params = array($id);

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
		$recipe = self::getInfos($id);
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
				$recipe['footprint'] = round($recipe['footprint'], 3);
			}
		return $recipe;
	}

	public static function add($rc_id, $label, $shared, $component, $persons, $type, $comment='') {
		$params = array((int)$rc_id, $label, (int)$shared, $component, $persons, $type, $comment);
		$params[] = self::getBitsFromModulesList($_SESSION['recipe']['modules']);
		return \core\Core::$db->exec_returning('INSERT INTO rrc_recipe (rrc_re_rrc_rc_id, rrc_re_label, rrc_re_public, rrc_re_component, rrc_re_persons, rrc_re_type, rrc_re_comment, rrc_re_modules, rrc_re_creation) VALUES (?,?,?,?,?,?,?,?,now()) ', $params, 'rrc_re_id');
	}

	public static function update($recipeId, $label, $shared, $component, $persons, $type, $comment='') {
		$params = array($label, (int)$shared, $component, $persons, $type, $comment, (int)$recipeId);
		$q = 'UPDATE rrc_recipe SET rrc_re_label=?, rrc_re_public=?, rrc_re_component=?, rrc_re_persons=?, rrc_re_type=?, rrc_re_comment=?, rrc_re_modification=now() WHERE rrc_re_id=?';
		$res = \core\Core::$db->exec($q, $params);
	}

	public static function updateModules($recipeId, $modules) {
		\core\Core::$db->exec('UPDATE rrc_recipe SET rrc_re_modules=? WHERE rrc_re_id=?', array(self::getBitsFromModulesList($modules), (int)$recipeId));
	}

	public static function setConsumptionDate($recipeId, $date) {
		if (!preg_match("#([0-9]+)/([0-9]+)/([0-9]+)#", $date, $m)) {
			throw new \Exception('Invalid date');
		}
		$d = "$m[3] $m[2] $m[1] 00:00:00";
		\core\Core::$db->exec('UPDATE rrc_recipe SET rrc_re_consumptiondate=? WHERE rrc_re_id=?', array($d, (int)$recipeId));
	}

	public static function getConsumptionDate($recipeId) {
		return \core\Core::$db->fetchOne("SELECT TO_CHAR(rrc_re_consumptiondate, 'DD/MM/YYYY') FROM  rrc_recipe WHERE rrc_re_id=?", array((int)$recipeId));
	}

	public static function setComments($recipeId, $comments) {
		\core\Core::$db->exec('UPDATE rrc_recipe SET rrc_re_comment=? WHERE rrc_re_id=?', array($comments, (int)$recipeId));
	}

	public static function getComments($recipeId) {
		return \core\Core::$db->fetchOne("SELECT rrc_re_comment AS comment FROM  rrc_recipe WHERE rrc_re_id=?", array((int)$recipeId));
	}
	
	public static function delete($rid) {
		$params = array($rid);
		\core\Core::$db->exec('DELETE FROM rrc_recipe where rrc_re_id=?', $params);
		// Delete recipe foodstuff
		\core\Core::$db->exec('DELETE FROM rrc_recipe_foodstuff where rrc_rf_rrc_recipe_id=?', $params);
		// Delete recipe assignation to menu
		\core\Core::$db->exec('DELETE FROM rrc_menu_recipe where rrc_mr_rrc_recipe_id=?', $params);
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

	public static function getModulesList($recipeId) {
		$num = \core\Core::$db->fetchOne('SELECT rrc_re_modules FROM rrc_recipe WHERE rrc_re_id = ?', array($recipeId));
		$val = (is_null($num)) ? 15 : $num;
		return self::getModulesListFromBits($val);
	}

	public static function checkIfExists($recipeId) {
		return (\core\Core::$db->fetchOne('SELECT count(*) FROM rrc_recipe WHERE rrc_re_id = ?', array($recipeId))) ? true : false;
	}

	public static function getNameFromId($id) {
		return \core\Core::$db->fetchOne('SELECT rrc_re_label FROM rrc_recipe WHERE rrc_re_id = ?', array($id));
	}

}
