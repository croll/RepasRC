<?php  //  -*- mode:php; tab-width:2; c-basic-offset:2; -*-

namespace mod\repasrc;

class DatabaseImport {

	private static $_processingErrors = array();
	private static $_lineNumber = 0;

	public static function importCsv($filepath, $separator=';', $enclosure='"', $skipline=0, $description='') {

		$numProcessed = 0;

		if (!is_file($filepath) || !is_readable($filepath)) {
			// Check if filename is in current directory (for tests)
			$moduleDir = dirname(__FILE__);
			if (is_file("$moduleDir/$filepath") && is_readable("$moduleDir/$filepath")) {
				$filepath = "$moduleDir/$filepath";
			} else {
				throw new \Exception("File does not exist or is not readable");
			}
		}

		if ($separator == '\t') $separator="\t";
		$os = '';
		if (($handle = fopen($filepath, "r")) !== FALSE) {
			while (($content = fgetcsv($handle, 1000, $separator, $enclosure)) !== FALSE) {
				$lines[] = $content;
				$os .= implode($content, '');
			}
		}

		foreach($lines as $datas) {

			self::$_lineNumber++;
			self::$_current = array();

			if (self::$_lineNumber != 0 && self::$_lineNumber <= $skipline) {
				continue;
			}
			$datas = array_map(array('self', '_cleanString'), $datas);

			// Skip blank lines
			if (!isset($datas[1])) continue;

			# 1 : Code
			# 0 : Description 
	}
}

	private static function _cleanString($str) {
		$detected = mb_detect_encoding($str, array('utf-8', 'latin1', 'windows-1251'), true);
		if ($detected != 'UTF-8') {
			$str = iconv($detected, 'UTF-8', $str);
		}
		return trim(str_replace(array('"',';','NULL','null'), array('',"\n",NULL,NULL),$str));
	}

}

