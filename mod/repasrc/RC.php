<?php  //  -*- mode:php; tab-width:2; c-basic-offset:2; -*-

namespace mod\repasrc;

class RC {

	public static function getUserRC($uid) {
		$rcId = \core\Core::$db->fetchOne('SELECT rrc_rc_id FROM rrc_rc WHERE rrc_rc_user_id=?', array($uid));
		if (!$rcId) {
			$rcId = \core\Core::$db->exec_returning('INSERT INTO rrc_rc (rrc_rc_name,rrc_rc_user_id,rrc_rc_creation) VALUES ("",?,now())', array((int)$uid), 'rrc_rc_id');
		}
		return $rcId;
	}

	public static function getRcInfos($rc_id) {
		return \core\Core::$db->fetchRow('SELECT rrc_rc_id AS id, rrc_rc_name AS name, rrc_rc_type AS "type", rrc_rc_public AS public, rrc_rc_creation AS creation, rrc_rc_modification AS modification, rrc_zv_id AS zoneid, rrc_zv_label AS zonelabel FROM rrc_rc AS rc LEFT JOIN rrc_geo_zonevalue AS zv ON rc.rrc_rc_rrc_geo_zonevalue_id=zv.rrc_zv_id WHERE rrc_rc_id=?', array($rc_id));
	}

	public static function updateRcInfos($rc_id='', $name, $type, $public, $zoneid) {
		return \core\Core::$db->exec('UPDATE rrc_rc SET rrc_rc_name=?, rrc_rc_type=?, rrc_rc_public=?, rrc_rc_rrc_geo_zonevalue_id=?, rrc_rc_modification=now() WHERE rrc_rc_id=?', array($name, $type, $public, $zoneid, $_SESSION['rc']));
	}

	public static function isRecipeOwner($recipe_id) {
		return (\core\Core::$db->fetchOne('SELECT rrc_re_id FROM rrc_recipe WHERE rrc_re_id=? AND rrc_re_rrc_rc_id=?', array((int)$recipe_id, (int)$_SESSION['rc']))) ? true : false;
	}

	public static function isMenuOwner($menu_id) {
		return (\core\Core::$db->fetchOne('SELECT rrc_me_id FROM rrc_menu WHERE rrc_me_id=? AND rrc_me_rrc_rc_id=?', array((int)$recipe_id, (int)$_SESSION['rc']))) ? true : false;
	}

}

