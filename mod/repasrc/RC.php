<?php  //  -*- mode:php; tab-width:2; c-basic-offset:2; -*-

namespace mod\repasrc;

class RC {

	public static function getUserRC($uid) {
		return \core\Core::$db->fetchOne('SELECT rrc_rc_id FROM rrc_rc WHERE rrc_rc_user_id=?', array($uid));
	}

}

