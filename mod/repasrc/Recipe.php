<?php  //  -*- mode:php; tab-width:2; c-basic-offset:2; -*-

namespace mod\repasrc;

class Recipe {

	public static function search($rc_id, $owner=NULL, $component=NULL, $label=NULL, $foodstuff=NULL, $shared=NULL, $getFoodstuff=false, $limit='ALL', $offset=0, $onlyNumResults=false) {

		$params = array();
		$f = 'SELECT DISTINCT rrc_re_id AS id, rrc_re_public AS shared, rrc_re_label AS label, rrc_re_component AS component, rrc_re_persons AS persons, rrc_re_rrc_rc_id AS owner, rrc_re_creation AS creation, rrc_re_modification AS modification ';
		$q = 'FROM rrc_recipe AS re ';
		$w = ' WHERE 1=1';
		if ($label) {
			$params[] = '%'.$label.'%';
			$w.= " AND UPPER(rrc_re_label) LIKE UPPER(?)";	
	}
		if ($component) {
			$params[] = $component;
			$w.= ' AND rrc_re_component=?';	
		}
		if ($foodstuff) {
			$params[] = '%'.$foodstuff.'%';
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
				case "ADMIN":
					$w.= " AND rrc_re_byadmin=1 OR rrc_re_type='ADMIN' ";
					if (!\mod\user\Main::userBelongsToGroup('admin')) {
						$w.= ' AND rrc_re_public=\'1\' ';
					}
				break;
				// Light footprint 
				case "LIGHTFOOTPRINT":
					$params[] = $owner;
					$w.= ' AND rrc_re_type = ? ';
					if (!\mod\user\Main::userBelongsToGroup('admin')) {
						$w.= ' AND rrc_re_public=\'1\' ';
					}
				break;
				// Stallion 
				case "STALLION":
					$params[] = $owner;
					$w.= ' AND rrc_re_type = ? AND rrc_re_public=\'1\' ';
					if (!\mod\user\Main::userBelongsToGroup('admin')) {
						$w.= ' AND rrc_re_public=\'1\' ';
					}
				break;
				// Other recipes
				case "OTHER":
					$params[] = $rc_id;
					$w.= " AND rrc_re_rrc_rc_id != ? AND rrc_re_byadmin!=1 AND rrc_re_public='1' AND rrc_re_type = 'STANDARD' ";
					if (!\mod\user\Main::userBelongsToGroup('admin')) {
						$w.= ' AND rrc_re_public=\'1\' ';
					}
				break;
				
			}
		}
		$g = " GROUP BY rrc_re_id, rrc_re_label ORDER BY rrc_re_label ";
		$o = " LIMIT $limit OFFSET $offset";
		if ($onlyNumResults == false) {
			$query = $f.$q.$w.$g.$o;
			return \core\Core::$db->fetchAll($query, $params);
		} else {
			$query = 'SELECT count(*) '.$q.$w.$o;
			return (int)\core\Core::$db->fetchOne($query, $params);
		}

	}

	public static function searchComputed($rc_id, $owner=NULL, $component=NULL, $label=NULL, $foodstuff=NULL, $shared=NULL, $limit='ALL', $offset=0) {
		$result = array();
		$recipes = self::search($rc_id, $owner, $component, $label, $foodstuff, $shared, true, $limit, $offset);
		foreach ($recipes as $recipe) {
			$result[] = self::getDetail($recipe['id']);
		}
		return $result;
	}

	public static function hasFoodstuff($id) {
		$num = \core\Core::$db->fetchOne('SELECT count(*) as nb FROM rrc_recipe_foodstuff WHERE rrc_rf_rrc_recipe_id=?', array($id));
		return ($num > 0) ? true : false;
	}

	public static function getInfos($id) {
		if (empty($id)) return null;
		 return \core\Core::$db->fetchRow("SELECT rrc_re_id AS id, rrc_re_label AS label, rrc_re_component AS component, rrc_re_persons AS persons, rrc_re_byadmin AS admin, rrc_re_modules AS modules, rrc_re_hash AS hash, rrc_re_comment AS comment, rrc_re_public AS shared, TO_CHAR(rrc_re_consumptiondate, 'DD/MM/YYYY') AS consumptiondate, TO_CHAR(rrc_re_consumptiondate, 'MM') AS consumptionmonth, rrc_re_type AS \"type\", rrc_re_price AS price, rrc_re_vat AS vat FROM rrc_recipe WHERE rrc_re_id=?", array($id));
	}

	public static function getFoodstuffList($id) {
		$params = array($id);
		$q = "SELECT rrc_rf_id AS foodstuff_recipe_id, rrc_rf_quantity_unit AS unit, rrc_rf_quantity_value AS quantity, rrc_rf_price AS price, rrc_rf_vat AS vat, rrc_rf_conservation as conservation, rrc_rf_production AS production, rrc_rf_custom_label AS custom_label, rrc_rf_rrc_foodstuff_synonym_id AS synonym_id, rrc_rf_rrc_foodstuff_id AS foodstuff_id ";
		$q.= "FROM rrc_recipe_foodstuff AS rf ";
		$q.= "WHERE rrc_rf_rrc_recipe_id=? ORDER BY rrc_rf_id";
		$fs = array();
		foreach(\core\Core::$db->fetchAll($q, $params) as $row) {
			$tmp = array();
			if (!empty($row['synonym_id'])) {
				$infos = \mod\repasrc\Foodstuff::search(NULL, NULL, NULL, array(array('id' => $row['foodstuff_id'], 'synonym_id' => $row['synonym_id'])));
			} else {
				$infos = \mod\repasrc\Foodstuff::search(NULL, NULL, NULL, array(array('id' => $row['foodstuff_id'])), false);
			}
			$tmp['custom_label'] = $row['custom_label'];
			$tmp['recipeFoodstuffId'] = $row['foodstuff_recipe_id'];
			$tmp['unit'] = $row['unit'];
			$tmp['quantity'] = $row['quantity'];
			$tmp['price'] = $row['price'];
			$tmp['vat'] = $row['vat'];
			$tmp['conservation'] = $row['conservation'];
			$tmp['conservation_label'] = \mod\repasrc\Foodstuff::getConservation($row['conservation']);
			$tmp['production'] = $row['production'];
			$tmp['production_label'] = \mod\repasrc\Foodstuff::getProduction($row['production']);
			$tmp['foodstuff'] = $infos[0];
			$tmp['origin'] = \mod\repasrc\Foodstuff::getOriginFromRecipe($tmp['recipeFoodstuffId']);

			$families = array();
			if (isset($infos[0]['infos'])) {
				foreach($infos[0]['infos'] as $info) {
					if (isset($info['family_group']))
						$families[$info['family_group_id']] = $info['family_group'];
				}
			}
			$tmp['families'] = $families;
			$fs[] = $tmp;
		}
		return $fs;
	}

	public static function getDetail($id, $nocache=false) {

		if ($nocache === false) {
			$hash = self::decodeRecipeHash($id);
			if (!is_null($hash)) {
				//\Core\core::log("getting recipe $id cache");
				return $hash;
			}
		}

		//\Core\core::log("Building recipe $id cache");

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

		// Recipe does not exist
		if (!is_array($recipe))
			return null;

		$recipe['families'] = array();

		$recipe['component'] = \mod\repasrc\Foodstuff::$component[$recipe['component']];

		$recipe['shared'] = (!empty($recipe['shared'])) ? 'Partagée' : 'Privée';

		$recipe['label'] = str_replace("''", "'", $recipe['label']);

		$recipe['foodstuffList'] = self::getFoodstuffList($recipe['id']);

		$recipe['footprint'] = 0;

		$recipe['totalWeight'] = 0;

		$recipe['totalPrice'] = array('vatin' => 0, 'vatout' => 0);

		$recipe['foodstuff'] = array();

		foreach($recipe['foodstuffList'] as $fs) {

			$fs_label = (isset($fs['foodstuff']['synonym'])) ? $fs['foodstuff']['synonym'] : $fs['foodstuff']['label'];

			// Footprint
			$footprint = ($fs['foodstuff']['footprint']*($fs['quantity']/$recipe['persons']));
			if (!empty($footprint)) {
				if ($fs['conservation']) {
					if (isset($conservation[$fs['conservation']])) {
						$footprint = $footprint*$conservation[$fs['conservation']];
					}
				}
				$recipe['footprint'] += $footprint;
			}

			// Foodstuff families
			if (isset($fs['foodstuff']['infos'])) {
				$fam = $fs['foodstuff']['infos'][0]['family_group_id'].'_'.str_replace('_', ' ', $fs['foodstuff']['infos'][0]['family_group']);
				if (!in_array($fam, $recipe['families'])) {
					$recipe['families'][$fs['foodstuff']['infos'][0]['family_group_id']] = $fam;  
				}
			}

			// Simple foodstuff list
			if (!in_array($fs_label, $recipe['foodstuff'])) {
				$recipe['foodstuff'][$fs['foodstuff']['id']] = $fs_label;
			}

			// Foodstuff weight (for graphs)
			$recipe['totalWeight'] += $fs['quantity'];

			// Price
			if (!empty($fs['price']) && $fs['vat']) {
				$recipe['totalPrice']['vatin'] += $fs['price'];
			} else {
				$recipe['totalPrice']['vatout'] += $fs['price'];
			}

		}
		$recipe['footprint'] = round($recipe['footprint'], 3);
				
		$recipe['transport'] = \mod\repasrc\Analyze::transport($recipe);
		
		$recipe['seasonality'] = \mod\repasrc\Analyze::seasonality($recipe);

		self::updateRecipeHash($id, serialize($recipe));
		return $recipe;
	}

	public static function add($rc_id, $label, $shared, $component, $persons, $type, $comment='') {
		$params = array((int)$rc_id, $label, (int)$shared, $component, $persons, $type, $comment);
		$params[] = \mod\repasrc\Tools::getBitsFromModulesList($_SESSION['recipe']['modules']);
		return \core\Core::$db->exec_returning('INSERT INTO rrc_recipe (rrc_re_rrc_rc_id, rrc_re_label, rrc_re_public, rrc_re_component, rrc_re_persons, rrc_re_type, rrc_re_comment, rrc_re_modules, rrc_re_creation) VALUES (?,?,?,?,?,?,?,?,now()) ', $params, 'rrc_re_id');
		self::updateRecipeHash($recipeId);
	}

	public static function update($recipeId, $label, $shared, $component, $persons, $type, $comment='') {
		$params = array($label, (int)$shared, $component, $persons, $type, $comment, (int)$recipeId);
		$q = 'UPDATE rrc_recipe SET rrc_re_label=?, rrc_re_public=?, rrc_re_component=?, rrc_re_persons=?, rrc_re_type=?, rrc_re_comment=?, rrc_re_modification=now() WHERE rrc_re_id=?';
		$res = \core\Core::$db->exec($q, $params);
		self::updateRecipeHash($recipeId);
	}

	public static function duplicate($recipeId, $newName) {
		// Get infos
		$infos = \core\Core::$db->fetchRow('SELECT * FROM rrc_recipe WHERE rrc_re_id=?', array((int)$recipeId));
		if (!is_array($infos)) {
			throw new \Exception('Unable to duplicate recipe '.$recipeId);
		}
		// Create new recipe
		$q = 'INSERT INTO rrc_recipe (rrc_re_rrc_rc_id, rrc_re_public, rrc_re_label, rrc_re_component, rrc_re_persons, rrc_re_byadmin, rrc_re_modules, rrc_re_comment, rrc_re_hash, rrc_re_type, rrc_re_vat, rrc_re_price, rrc_re_consumptiondate, rrc_re_creation) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)';
		$params = array($_SESSION['rc'], $infos['rrc_re_public'], $newName, $infos['rrc_re_component'], $infos['rrc_re_persons'],  $infos['rrc_re_byadmin'], $infos['rrc_re_modules'], $infos['rrc_re_comment'], $infos['rrc_re_hash'], $infos['rrc_re_type'], $infos['rrc_re_vat'], $infos['rrc_re_price'], $infos['rrc_re_consumptiondate'], 'now()');
		$newRecipeId = \core\Core::$db->exec_returning($q, $params, 'rrc_re_id');
		if (empty($newRecipeId)) {
			throw new \Exception('Unable to duplicate recipe: recipe infos insertion failed '.$recipeId);
		}
		// Duplicate foodstuff
		$q = 'SELECT rrc_rf_rrc_foodstuff_id, rrc_rf_rrc_foodstuff_synonym_id, rrc_rf_quantity_unit, rrc_rf_quantity_value, rrc_rf_price, rrc_rf_vat, rrc_rf_conservation, rrc_rf_production, rrc_rf_custom_code FROM rrc_recipe_foodstuff WHERE rrc_rf_rrc_recipe_id = ?';
		foreach(\core\Core::$db->fetchAssoc($q, array($recipeId)) as $fs) {
			// Get foodstuff info
			$q = 'INSERT INTO rrc_recipe_foodstuff (rrc_rf_rrc_foodstuff_id, rrc_rf_rrc_foodstuff_synonym_id, rrc_rf_quantity_unit, rrc_rf_quantity_value, rrc_rf_price, rrc_rf_vat, rrc_rf_conservation, rrc_rf_production, rrc_rf_custom_code, rrc_rf_rrc_recipe_id) VALUES (?,?,?,?,?,?,?,?,?,?)';
			// Create new one
			//$args = array($fs['rrc_rf_rrc_foodstuff_id,'], $fs['rrc_rf_rrc_foodstuff_synonym_id,'], $fs['rrc_rf_quantity_unit,'], $fs['rrc_rf_quantity_value,'], $fs['rrc_rf_price,'], $fs['rrc_rf_vat,'], $fs['rrc_rf_conservation,'], $fs['rrc_rf_production']);
			$fs['rrc_rf_rrc_recipe_id'] = $newRecipeId;
			$newFoodstuffId = \core\Core::$db->exec_returning($q, array_values($fs), 'rrc_rf_id');
			// Get foodstuff origin info
			foreach(\core\Core::$db->fetchAssoc('SELECT rrc_or_default_location, rrc_or_rrc_geo_zonevalue_id, rrc_or_rrc_supply_item_id, rrc_or_step FROM rrc_origin WHERE rrc_or_rrc_recipe_foodstuff_id = ?', array($recipeId)) as $or) {
				$q = 'INSERT INTO rrc_origin (rrc_or_default_location, rrc_or_rrc_geo_zonevalue_id, rrc_or_rrc_supply_item_id, rrc_or_step, rrc_or_rrc_recipe_foodstuff_id) VALUES (?,?,?,?,?)';
				$or['rrc_or_rrc_recipe_foodstuff_id'] = $newFoodstuffId;
				$newFoodstuffId = \core\Core::$db->exec($q, array_values($or));
			}
		}
		return $newRecipeId;
	}

	public static function updateModules($recipeId, $modules) {
		\core\Core::$db->exec('UPDATE rrc_recipe SET rrc_re_modules=? WHERE rrc_re_id=?', array(\mod\repasrc\Tools::getBitsFromModulesList($modules), (int)$recipeId));
	}

	public static function setConsumptionDate($recipeId, $date) {
		if (!preg_match("#([0-9]+)/([0-9]+)/([0-9]+)#", $date, $m)) {
			throw new \Exception('Invalid date');
		}
		$d = "$m[3] $m[2] $m[1] 00:00:00";
		\core\Core::$db->exec('UPDATE rrc_recipe SET rrc_re_consumptiondate=? WHERE rrc_re_id=?', array($d, (int)$recipeId));
		self::updateRecipeHash($recipeId);
	}

	public static function getConsumptionDate($recipeId) {
		return \core\Core::$db->fetchOne("SELECT TO_CHAR(rrc_re_consumptiondate, 'DD/MM/YYYY') FROM rrc_recipe WHERE rrc_re_id=?", array((int)$recipeId));
	}

	public static function setPrice($recipeId, $price, $vat) {
		$price = str_replace(',', '.', $price);
		if (!preg_match("#[0-9]+\.?[0-9]{0,}#", $price)) {
			throw new \Exception('Invalid price');
		}
		\core\Core::$db->exec('UPDATE rrc_recipe SET rrc_re_price=?, rrc_re_vat=? WHERE rrc_re_id=?', array($price, $vat, (int)$recipeId));
		self::updateRecipeHash($recipeId);
	}

	public static function getPrice($recipeId) {
		return \core\Core::$db->fetchRow("SELECT rrc_re_price AS price, rrc_re_vat AS vat FROM rrc_recipe WHERE rrc_re_id=?", array((int)$recipeId));
	}

	public static function setComments($recipeId, $comments) {
		\core\Core::$db->exec('UPDATE rrc_recipe SET rrc_re_comment=? WHERE rrc_re_id=?', array($comments, (int)$recipeId));
		self::updateRecipeHash($recipeId);
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

	public static function getModulesList($recipeId) {
		$num = \core\Core::$db->fetchOne('SELECT rrc_re_modules FROM rrc_recipe WHERE rrc_re_id = ?', array($recipeId));
		$val = (is_null($num)) ? 15 : $num;
		return \mod\repasrc\Tools::getModulesListFromBits($val);
	}

	public static function checkIfExists($recipeId) {
		return (\core\Core::$db->fetchOne('SELECT count(*) FROM rrc_recipe WHERE rrc_re_id = ?', array($recipeId))) ? true : false;
	}

	public static function getNameFromId($id) {
		return \core\Core::$db->fetchOne('SELECT rrc_re_label FROM rrc_recipe WHERE rrc_re_id = ?', array($id));
	}

	public static function updateRecipeHash($id, $hash=NULL) {
		if (is_null($hash)) {
			$hash = serialize(self::getDetail($id, true));
		}
		\core\Core::$db->exec('UPDATE rrc_recipe SET rrc_re_hash=? WHERE rrc_re_id=?', array($hash, $id));	
	}

	public static function decodeRecipeHash($id) {
		$hash = \core\Core::$db->fetchOne('SELECT rrc_re_hash FROM rrc_recipe WHERE rrc_re_id=?', array($id));
		if (empty($hash)) return NULL;
			else return unserialize($hash);
	}

	public static function export($id) {
		$infos = self::getDetail($id);
		$priceHT = (isset($infos['vat']) && $infos['vat'] === 0) ? $infos['price'] : '';
		$priceTTC = (isset($infos['vat']) && $infos['vat'] === 1) ? $infos['price'] : '';
		if ($priceHT == 0) $priceHT = '';
		if ($priceTTC == 0) $priceTTC = '';
		$type = ($infos['type'] == 'STANDARD') ? 'Standard' : 'Recette étalon';
		$outp = "Nom de la recette;Type de composante;Type de partage;Type de recette;Prix HT;Prix TTC\n";
		$outp .= $infos['label'].';'.$infos['component'].';'.$infos['shared'].';'.$type.';'.$priceHT.';'.$priceTTC."\n";
		$outp .= ";Code de l'aliment;Nom de l'aliment;Quantité;Type de production;Moyen de conservation;Provenance approximative;Itineraire;Prix HT;Prix TTC\n";
		foreach($infos['foodstuffList'] as $fs) {
			$origin_type = '';
			$origin = '';
			$label = self::getFoodstuffLabel($fs);
			$fsPriceHT = (isset($fs['vat']) && $fs['vat'] === 0) ? $fs['price'] : '';
			$fsPriceTTC = (isset($fs['vat']) && $fs['vat'] === 1) ? $fs['price'] : '';
			if ($fsPriceHT == 0) $fsPriceHT = '';
			if ($fsPriceTTC == 0) $fsPriceTTC = '';
			if (is_array($fs['origin']) && sizeof($fs['origin']) > 0) {
				$origin_type = \mod\repasrc\Foodstuff::$origin[$fs['origin'][0]['location']];
				foreach($fs['origin'] as $ori) {
					$origin .= $ori['zonelabel'].',';
				}
				$origin = substr($origin, 0, -1);
			}
			$outp.= ';'.$fs['code'].';'.$label.';'.$fs['quantity'].$fs['unit'].';'.$fs['production_label'].';'.$fs['conservation_label'].';'.$origin_type.';'.$origin.';'.$fsPriceHT.';'.$fsPriceTTC."\n";
		}
		$filename = '/tmp/recipe_'.$id.'csv';
		file_put_contents($filename, $outp);
		return $filename;
	}

	public static function getFoodstuffLabel($fs) {
		if (($fs['foodstuff']['code'] == 'CUSTOMLABEL') && !empty($fs['custom_label'])) {
			return ucfirst($fs['custom_label']);
		}
		return (substr($fs['foodstuff']['code'],0, 1) == 's') ? ucfirst($fs['foodstuff']['synonym']) : ucfirst($fs['foodstuff']['label']);
	}

}
