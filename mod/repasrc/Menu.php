<?php  //  -*- mode:php; tab-width:2; c-basic-offset:2; -*-

namespace mod\repasrc;

class Menu {

	public static function getNameFromId($menuId) {
		return \core\Core::$db->fetchOne('SELECT rrc_me_label FROM rrc_menu WHERE rrc_me_id=?', array($menuId));
	}

	public static function hasRecipe($menuId) {
		return \core\Core::$db->fetchOne('SELECT count(*) as nb FROM rrc_menu_recipe WHERE rrc_mr_rrc_menu_id=?', array((int)$menuId));
	}

	public static function getInfos($id) {
		if (empty($id)) return null;
		 return \core\Core::$db->fetchRow("SELECT rrc_me_id AS id, rrc_me_label AS label, rrc_me_eaters AS eaters, rrc_me_modules AS modules, rrc_me_comment AS comment, rrc_me_public AS shared, TO_CHAR(rrc_me_consumptiondate, 'DD/MM/YYYY') AS consumptiondate, TO_CHAR(rrc_me_consumptiondate, 'MM') AS consumptionmonth, rrc_me_type AS \"type\", rrc_me_price AS price, rrc_me_vat AS vat FROM rrc_menu WHERE rrc_me_id=?", array($id));
	}

	public static function getDetail($menuId) {
		$menuInfos = \core\Core::$db->fetchRow('SELECT rrc_me_id AS "id", rrc_me_label AS "label", rrc_me_public AS shared, rrc_me_eaters AS "eaters", rrc_me_rrc_rc_id AS owner, rrc_me_creation AS creation, rrc_me_modification AS modification, rrc_me_price AS price, rrc_me_vat AS vat, rrc_me_consumptiondate AS consumptiondate FROM rrc_menu WHERE rrc_me_id=?', array($menuId));
		$menuInfos['recipesList'] = array();
		$q = "SELECT rrc_mr_rrc_recipe_id AS recipeid, rrc_mr_portions AS portions FROM rrc_menu_recipe WHERE rrc_mr_rrc_menu_id = ?";
		$menuInfos['footprint'] = 0;
		$menuInfos['totalPrice'] = array('vatin' => 0, 'vatout' => 0);
		foreach (\core\Core::$db->fetchAll($q, array($menuId)) as $infos) {
			$recipeInfos = \mod\repasrc\Recipe::getDetail($infos['recipeid']);
			// Recipe does not exist anymore
			if (is_null($recipeInfos)) {
				continue;
			}
			$recipeInfos['menuRecipeId'] = self::getMenuRecipeId($menuId, $infos['recipeid']);
			$recipeInfos['portions'] = $infos['portions'];
			if (isset($recipeInfos['footprint']) && !empty($recipeInfos['footprint'])) { 
				$menuInfos['footprint'] += $recipeInfos['footprint'];
			}
			if (isset($recipeInfos['totalPrice']['vatin']) && !empty($recipeInfos['totalPrice']['vatin'])) { 
				$menuInfos['totalPrice']['vatin'] += $recipeInfos['totalPrice']['vatin'];
			}
			if (isset($recipeInfos['totalPrice']['vatout']) && !empty($recipeInfos['totalPrice']['vatout'])) { 
				$menuInfos['totalPrice']['vatout'] += $recipeInfos['totalPrice']['vatout'];
			}
			$menuInfos['recipesList'][] = $recipeInfos;
		}
		return $menuInfos;
	}

	public static function add($rcId, $label, $shared, $eaters, $type) {
		return \core\Core::$db->exec_returning('INSERT INTO rrc_menu (rrc_me_rrc_rc_id, rrc_me_label, rrc_me_public, rrc_me_eaters, rrc_me_creation, rrc_me_type) VALUES (?,?,?,?,now(),?) ', array($rcId, $label, $shared, $eaters, $type), 'rrc_me_id');
	}

	public static function update($menuId, $label, $shared, $eaters, $type) {
		\core\Core::$db->exec('UPDATE rrc_menu SET rrc_me_label=?, rrc_me_public=?, rrc_me_eaters=?, rrc_me_modification=now(), rrc_me_type=? WHERE rrc_me_id=?', array($label, $shared, $eaters, $type, (int)$menuId));
	}
	
	public static function delete($menuId) {
		// Delete menu
		\core\Core::$db->exec('DELETE FROM rrc_menu where rrc_me_id=?', array($menuId));
		// Delete recipe assignation
		\core\Core::$db->exec('DELETE FROM rrc_menu_recipe where rrc_mr_rrc_menu_id=?', array($menuId));
	}

	public static function addRecipe($recipeId, $menuId, $portions) {
		return \core\Core::$db->exec_returning('INSERT INTO rrc_menu_recipe (rrc_mr_rrc_recipe_id, rrc_mr_rrc_menu_id, rrc_mr_portions) VALUES (?,?,?)', array((int)$recipeId, (int)$menuId, $portions), 'rrc_mr_id');
	}

	public static function updateRecipe($menuRecipeId, $portions) {
		return \core\Core::$db->exec('UPDATE rrc_menu_recipe SET rrc_mr_portions=? WHERE rrc_mr_id=?', array($portions, $menuRecipeId));
	}

	public static function deleteRecipe($menuId) {
		\core\Core::$db->exec('DELETE FROM rrc_menu_recipe WHERE rrc_mr_id=?', array($menuId));
	}

	public static function search($rcId='', $label='', $shared='', $owner='', $limit='ALL', $offset=0) {
		$params = array();
		$q = 'SELECT DISTINCT rrc_me_id AS id, rrc_me_public AS shared, rrc_me_label AS label, rrc_me_eaters AS eaters, rrc_me_rrc_rc_id AS owner, rrc_me_creation AS creation, rrc_me_modification AS modification FROM rrc_menu AS me';
		$w = ' WHERE 1=1';
		if ($label) {
			$params[] = $label;
			$w.= " AND UPPER(rrc_me_label) LIKE UPPER('%?%')";	
		}
		if ($shared && !$owner) {
			$w.= ' AND rrc_me_public=\'1\'';	
		} else if (!$shared && !$owner) {
			$params[] = $rc_id;
			$w.= ' AND rrc_me_rrc_rc_id=?';	
		} else if ($owner) {
			switch($owner) {
				case "me":
					$params[] = $rcId;
					$w.= ' AND rrc_me_rrc_rc_id=? ';	
				break;
				// Other menus
				case "other":
					$params[] = $rcId;
					$w.= ' AND rrc_me_rrc_rc_id != ? AND rrc_me_public=1';
				break;
			}
		}
		$o = " ORDER BY label";
		$o = "LIMIT $limit OFFSET $offset";
		$query = $q.$w.$o;
		return \core\Core::$db->fetchAll($query, $params);
	}

	public static function searchComputed($rcId, $label=NULL, $shared=NULL, $owner='') {
		$menus = self::search($rcId, $label, $shared, $owner);
		foreach ($menus as $menu) {
			$result[] = self::getDetail($menu['id']);
		}
		return $result;
	}

	public static function setPrice($menuId, $price, $vat) {
		$price = str_replace(',', '.', $price);
		if (!preg_match("#[0-9]+\.?[0-9]{0,}#", $price)) {
			throw new \Exception('Invalid price');
		}
		\core\Core::$db->exec('UPDATE rrc_menu SET rrc_me_price=?, rrc_me_vat=? WHERE rrc_me_id=?', array($price, $vat, (int)$menuId));
	}

	public static function getPrice($menuId) {
		return \core\Core::$db->fetchRow("SELECT rrc_me_price AS price, rrc_me_vat AS vat FROM rrc_menu WHERE rrc_me_id=?", array((int)$menuId));
	}

	public static function setComments($menuId, $comments) {
		\core\Core::$db->exec('UPDATE rrc_menu SET rrc_me_comment=? WHERE rrc_me_id=?', array($comments, (int)$menuId));
	}

	public static function getComments($menuId) {
		return \core\Core::$db->fetchOne("SELECT rrc_me_comment AS comment FROM rrc_menu WHERE rrc_me_id=?", array((int)$menuId));
	}

	public static function setConsumptionDate($menuId, $date) {
		if (!preg_match("#([0-9]+)/([0-9]+)/([0-9]+)#", $date, $m)) {
			throw new \Exception('Invalid date');
		}
		$d = "$m[3] $m[2] $m[1] 00:00:00";
		\core\Core::$db->exec('UPDATE rrc_menu SET rrc_me_consumptiondate=? WHERE rrc_me_id=?', array($d, (int)$menuId));
	}

	public static function getConsumptionDate($menuId) {
		return \core\Core::$db->fetchOne("SELECT TO_CHAR(rrc_me_consumptiondate, 'DD/MM/YYYY') FROM rrc_menu WHERE rrc_me_id=?", array((int)$menuId));
	}

	public static function updateModules($menuId, $modules) {
		\core\Core::$db->exec('UPDATE rrc_menu SET rrc_me_modules=? WHERE rrc_me_id=?', array(\mod\repasrc\Tools::getBitsFromModulesList($modules), (int)$menuId));
	}

	public static function getModulesList($menuId) {
		$num = \core\Core::$db->fetchOne('SELECT rrc_me_modules FROM rrc_menu WHERE rrc_me_id = ?', array($menuId));
		$val = (is_null($num)) ? 15 : $num;
		return \mod\repasrc\Tools::getModulesListFromBits($val);
	}

	public static function checkIfExists($menuId) {
		return (\core\Core::$db->fetchOne('SELECT count(*) FROM rrc_menu WHERE rrc_me_id = ?', array($menuId))) ? true : false;
	}

	public static function getRecipeList($menuId) {
		return \core\Core::$db->fetchAll("SELECT rrc_mr_id AS menurecipeid, rrc_mr_rrc_recipe_id AS recipeid, rrc_mr_portions AS portions FROM rrc_menu_recipe WHERE rrc_mr_rrc_menu_id = ?", array($menuId));
	}

	public static function getMenuRecipeId($menuId, $recipeId) {
		return \core\Core::$db->fetchOne('SELECT rrc_mr_id FROM rrc_menu_recipe WHERE rrc_mr_rrc_menu_id = ? AND rrc_mr_rrc_recipe_id = ?', array((int)$menuId, (int)$recipeId));
	}

}
