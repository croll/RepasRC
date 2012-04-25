<?php  //  -*- mode:php; tab-width:2; c-basic-offset:2; -*-

namespace mod\repasrc;

class Foodstuff {

	/*
	public static function search($familyGroup=NULL, $family=NULL, $label=NULL) {
		$done = $params = array();
		$q = "SELECT rrc_fs_id AS id, rrc_fs_label AS label, rrc_fs_conservation as conservation, rrc_fs_production as production, ";
    $q.= "array_agg((SELECT rrc_ss_id FROM rrc_foodstuff_synonym WHERE rrc_ss_rrc_foodstuff_id=rrc_fs_id)) AS synonym_id ";
		$q.= "FROM rrc_foodstuff AS fs LEFT JOIN rrc_foodstuff_datavalue as dv ON fs.rrc_fs_id=dv.rrc_dv_rrc_foodstuff_id ";
		$q.= "WHERE 1=1 ";
		\core\Core::log($q);
		if ($label != NULL) {
			$params[] = "%$label%";
			$params[] = "%$label%";
			$q .= " AND UPPER(fs.rrc_fs_label) LIKE ? OR UPPER(ss.rrc_ss_label) LIKE ?";
		}
		if ($familyGroup != NULL) {
			$params[] =  $familyGroup;
			$q .= ' AND fg.rrc_fg_code=?';
		}
		if ($family != NULL) {
			$params[] = $family;
			$q .= ' AND fa.rrc_fa_id=?';
		}

		$o = ' GROUP BY rrc_fs_id ORDER BY rrc_fs_label ASC';
		$query = $q.$o;
		// Do not store duplicate foostuff, for example because it's defined with multiple families
		$num = 0;
		foreach(\core\Core::$db->fetchAll($query, $params) as $row) {
		}
		\core\Core::log($fs);
		return $fs;
	}
	 */
	public static function search($familyGroup=NULL, $family=NULL, $label=NULL, $fsIds=NULL, $searchSynonyms=true) {
		$params = $tmpParams = $fs = array();
		$tmpWhere = '';
		if ($fsIds != NULL) {
			foreach($fsIds as $aID) {
				$tmp = '';
				if (isset($aID['synonym_id']) && !is_null($aID['synonym_id'])) {
					$tmp .= "(fs.rrc_fs_id = ? AND ss.rrc_ss_id = ?) OR ";
					$tmpParams[] = $aID['id'];
					$tmpParams[] = $aID['synonym_id'];
					$searchSynonyms = true;
				} else {
					$tmp .= "(fs.rrc_fs_id = ?) OR ";
					$tmpParams[] = $aID['id'];
				}
				$tmpWhere .= 'AND ('.substr($tmp, 0, -4).') ';
			}
		}
		$q = "SELECT DISTINCT rrc_fs_id AS id, rrc_fs_label AS label, rrc_fs_conservation as conservation, rrc_fs_production as production, fa.rrc_fa_label AS family, fa.rrc_fa_id as family_id, fg.rrc_fg_id as family_group_id, fg.rrc_fg_name as family_group, dv.rrc_dv_value as footprint ";
		if ($searchSynonyms) {
			$q .= ', rrc_ss_id AS synonym_id, rrc_ss_label AS synonym ';
		}
		$q .= "FROM rrc_foodstuff AS fs ";
		$q .= "LEFT JOIN rrc_foodstuff_family AS ff ON fs.rrc_fs_id=ff.rrc_ff_rrc_foodstuff_id ";
		$q .= "LEFT JOIN rrc_family AS fa ON ff.rrc_ff_rrc_family_id=fa.rrc_fa_id ";
		$q .= "LEFT JOIN rrc_family_group AS fg ON fa.rrc_fa_rrc_family_group_id=fg.rrc_fg_code ";
		if ($searchSynonyms) {
			$q .= "LEFT JOIN rrc_foodstuff_synonym AS ss ON fs.rrc_fs_id=ss.rrc_ss_rrc_foodstuff_id ";
		}
		$q .= "LEFT JOIN rrc_foodstuff_datavalue AS dv ON fs.rrc_fs_id=dv.rrc_dv_rrc_foodstuff_id ";
		// Get EE values
		$w = "WHERE dv.rrc_dv_rrc_foodstuff_datatype_id=1 ";
		if ($label != NULL) {
			$params[] = "%$label%";
			$params[] = "%$label%";
			$q .= "AND UPPER(fs.rrc_fs_label) ILIKE ? OR UPPER(ss.rrc_ss_label) ILIKE ? ";
		}
		if ($familyGroup != NULL) {
			$params[] =  $familyGroup;
			$q .= 'AND fg.rrc_fg_code=? ';
		}
		if ($family != NULL) {
			$params[] = $family;
			$q .= 'AND fa.rrc_fa_id=? ';
		}

		$o = 'ORDER BY label ASC';
		if ($searchSynonyms) {
		  $o .= ', synonym ASC';
		}
		$query = $q.$w.$tmpWhere.$o;

		// Do not store duplicate foostuff, for example because it's defined with multiple families
		foreach(\core\Core::$db->fetchAll($query, array_merge($params, $tmpParams)) as $row) {
			if (isset($row['synonym_id']))
					$currentId = $row['id'].'-'.$row['synonym_id'];
			else
					$currentId = $row['id'];
			if (!isset($fs[$currentId])) {
				$num = 0;
				$tmp = array();
				$tmp['id'] = $row['id'];
				$tmp['label'] = $row['label'];
				$tmp['conservation'] = $row['conservation'];
				$tmp['production'] = $row['production'];
				$tmp['footprint'] = round($row['footprint'], 3);
				if (isset($row['synonym_id']) && !is_null($row['synonym_id'])) {
					$tmp['synonym_id'] = $row['synonym_id'];
					$tmp['synonym'] = $row['synonym'];
				}
				if (!is_null($row['family_id'])) {
					$tmp['infos'][$num]['family_id'] = $row['family_id'];
					$tmp['infos'][$num]['family'] = $row['family'];
					$tmp['infos'][$num]['family_group_id'] = $row['family_group_id'];
					$tmp['infos'][$num]['family_group'] = $row['family_group'];
				}
				$fs[$currentId] = $tmp;
			} else {
				$num = sizeof($fs[$currentId]['infos']);
				if (!empty($row['synonym'])) {
					$fs[$currentId]['infos'][$num]['synonym_id'] = $row['synonym_id'];
					$fs[$currentId]['infos'][$num]['synonym'] = $row['synonym'];
				}
				if (!empty($row['family'])) {
					$fs[$currentId]['infos'][$num]['family_id'] = $row['family_id'];
					$fs[$currentId]['infos'][$num]['family'] = $row['family'];
					$fs[$currentId]['infos'][$num]['family_group_id'] = $row['family_group_id'];
					$fs[$currentId]['infos'][$num]['family_group'] = $row['family_group'];
				}
			}
		}
		return array_values($fs);
	}

	public static function searchAll($familyGroup=NULL, $family=NULL, $label=NULL, $fsIds=NULL) {
		$r1 = self::search($familyGroup, $family, $label, $fsIds, false);
		$r2 = self::search($familyGroup, $family, $label, $fsIds, true);
		return array_merge($r1, $r2);
	}

	public static function getInfos($id, $synonym_id) {
		$params = array($id);
		if ($synonym_id) {
			$query = "SELECT rrc_fs_id AS id, rrc_fs_label AS label, rrc_ss_id AS synonym_id, rrc_ss_label AS synonym FROM rrc_foodstuff AS fs LEFT JOIN rrc_foodstuff_synonym AS ss ON fs.rrc_fs_id=ss.rrc_ss_rrc_foodstuff_id WHERE rrc_fs_id=?";
			$params[] = $synonym_id;
			$query.= " AND rrc_ss_id = ?";
		} else {
			$query = "SELECT rrc_fs_id AS id, rrc_fs_label AS label FROM rrc_foodstuff AS fs WHERE rrc_fs_id=?";
		}
		return array_values(\core\Core::$db->fetchAll($query, $params));
	}

	public static function getFamilies() {
		return \core\Core::$db->fetchAll('SELECT rrc_fg_code AS id, rrc_fg_level AS level, rrc_fg_name AS label, rrc_fg_code AS code FROM rrc_family_group');
	}

	public static function getSubFamilies($familyId=NULL) {
		$params = array();
		$query = 'SELECT rrc_fa_id AS id, rrc_fa_label AS label, rrc_fa_code AS code, rrc_fa_rrc_family_group_id AS "group" FROM rrc_family';
		if ($familyId) {
			$query .= ' WHERE rrc_fa_rrc_family_group_id = ?';
			$params[] = $familyId;
		}
		return \core\Core::$db->fetchAll($query, $params);
	}

	public static function getFromRecipe($recipeId, $foodstuffId, $synonymId) {
		$q = 'SELECT rrc_rf_quantity_value AS quantity, rrc_rf_price AS price, rrc_rf_vat AS vat, rrc_rf_conservation AS conservation, rrc_rf_production AS production, rrc_zv_label FROM rrc_recipe_foodstuff rf ';
		$q .= 'LEFT JOIN rrc_origin ori ON rf.rrc_rf_id=ori.rrc_or_rrc_recipe_foodstuff_id ';
		$q .= 'LEFT JOIN rrc_geo_zonevalue zv ON ori.rrc_or_rrc_geo_zonevalue_id=zv.rrc_zv_id ';
		$q .= 'WHERE rf.rrc_rf_rrc_recipe_id=? AND rf.rrc_rf_rrc_foodstuff_id=? AND rrc_rf_rrc_foodstuff_synonym_id=?';
		\core\Core::log($q);
		return \core\Core::$db->fetchOne($q, array($recipeId, $foodstuffId, $synonymId));
	}

}
