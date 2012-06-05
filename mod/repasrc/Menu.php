<?php  //  -*- mode:php; tab-width:2; c-basic-offset:2; -*-

namespace mod\repasrc;

class Menu {

	function menuHasRecipe($menuId) {
		return \core\Core::$db->fetchOne('SELECT count(*) as nb FROM rrc_menu_recipe WHERE rrc_mr_rrc_menu_id=?', array((int)$menuId));
	}

	function getInfos($menuId) {
		$menuInfos = \core\Core::$db->fetchRow('SELECT rrc_me_id AS "id", rrc_me_label AS "label", rrc_me_public AS shared, rrc_me_eaters AS "eaters", rrc_me_rrc_rc_id AS owner, rrc_me_creation AS creation, rrc_me_modification AS modification, rrc_me_price AS price, rrc_me_vat AS vat, rrc_me_consumptiondate AS consumptiondate FROM rrc_menu WHERE rrc_me_id=?', array($menuId));
		$menuInfos['recipes'] = array();
		$q = "SELECT rrc_mr_rrc_recipe_id AS recipe_id FROM rrc_menu_recipe WHERE rrc_mr_rrc_menu_id = ?";
		foreach (\core\Core::$db->fetchAll($q, array($menuId)) as $recipeId) {
			\mod\repasrc\Recipe::getInfos($recipeId);
			$menuInfos['recipes'][] = $recipeInfos;
		}
		return $menuInfos;
	}

	function add($label, $shared, $eaters) {
		return \core\Core::$db->exec_returning('INSERT INTO rrc_menu (rrc_me_rrc_rc_id, rrc_me_label, rrc_me_public, rrc_me_eaters, rrc_me_creation) VALUES (?,?,?,?,now()) ', array($_SESSION['rc'], $label, $shared, $eaters), 'rrc_me_id');
	}

	function update($menuId, $label, $shared, $eaters) {
		\core\Core::$db->exec('UPDATE rrc_menu SET rrc_me_label=?, rrc_me_public=?, rrc_me_eaters=?, rrc_me_modification=now() WHERE rrc_me_id=?', array((int)$menuId, $label, $shared, $eaters));
	}
	
	function delete($menuIdd) {
		// Delete menu
		\core\Core::$db->exec('DELETE FROM rrc_menu where rrc_me_id=?', array($menuId));
		// Delete recipe assignation
		\core\Core::$db->exec('DELETE FROM rrc_menu_recipe where rrc_mr_rrc_menu_id=?', array($menuId));
	}

	function addRecipe($recipeId, $menuId, $portions) {
		return $this->getDb()->exec_returning('INSERT INTO rrc_menu_recipe (rrc_mr_rrc_recipe_id, rrc_mr_rrc_menu_id, rrc_mr_portions) VALUES (?,?,?)', array((int)$recipeId, (int)$menuId, $portions), 'rrc_mr_id');
	}

	function updateRecipe($menuRecipeId, $portions) {
		$this->getDb()->execute('UPDATE rrc_menu_recipe SET rrc_mr_portions=? WHERE rrc_mr_id=?', array($portions, $menuRecipeId));
	}

	function deleteRecipe($menuId) {
		\core\Core::$db->exec('DELETE FROM rrc_menu_recipe WHERE rrc_mr_id=?', array($menuId));
	}

	function searchMenu($rcId='', $label='', $shared='', $owner='') {
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
			$dbParam->add($rc_id, SKELAX_INT);
			$w.= ' AND rrc_me_rrc_rc_id=?';	
		} else if ($owner) {
			switch($owner) {
				case "me":
					$dbParam->add($rc_id, SKELAX_INT);
					$w.= ' AND rrc_me_rrc_rc_id=?';	
				break;
				// Other menus
				case "other":
					$dbParam->add($this->_rcid, SKELAX_INT);
					$w.= ' AND rrc_me_rrc_rc_id != ? AND rrc_me_public=1';
				break;
			}
		}
		$o = " ORDER BY label";
		$query = $q.$w.$o;
		$res = $this->getDb()->execute($query, $dbParam);
		if (SK_Exception::isError($res)) return $res;
		while($row = $res->fetch_assoc()) {
			if (strstr($row['modification'], '0000')) $row['modification'] = '-';
			$row['hasRecipe'] = (int)$this->menuHasRecipe($row['id']);
			$menus[] = $row;
		}
		return $menus;
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
		return \core\Core::$db->fetchOne("SELECT rrc_me_comment AS comment FROM  rrc_menu WHERE rrc_me_id=?", array((int)$menuId));
	}
	

}
