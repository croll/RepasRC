<?php  //  -*- mode:php; tab-width:2; c-basic-offset:2; -*-

namespace mod\repasrc;

class HelpToImport {

	public function __construct($filepath, $separator=';', $enclosure='"', $skipline=0) {

		$lineNumber = 0;
		$outp = array();

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
			$lineNumber++;
			if ($lineNumber != 0 && $lineNumber <= $skipline) {
				continue;
			}
			$datas = array_map(array('self', '_cleanString'), $datas);
			// Skip blank lines
			if (!isset($datas[1])) continue;
			# 0 : Code
			# 1 : Message
			# 2 ; Type 
			//$outp .= $datas[0].'":{"message": "'.$datas[1].'", "type": "'.$datas[2].'"},';
			$outp[$datas[0]] = array("message" => $datas[1], "type" => $datas[2]);
		}
		//file_put_contents(dirname(__FILE__).'/../messages.json', substr($outp, 0, -1).'}');
		file_put_contents(dirname(__FILE__).'/../messages.json', json_encode($outp));
	}

	private static function _cleanString($str) {
		$detected = mb_detect_encoding($str, array('utf-8', 'latin1', 'windows-1251'), true);
		if ($detected != 'UTF-8') {
			$str = iconv($detected, 'UTF-8', $str);
		}
		$str = preg_replace("/\[b\](.*)\[\/b\]/Usi", "<b>\\1</b>", $str);
		$str = preg_replace("/\[g\](.*)\[\/g\]/Usi", "\"\\1\"", $str);
		$str = preg_replace("/\[i\](.*)\[\/i\]/Usi", "<i>\\1</i>", $str);
		$str = preg_replace("/\[u\](.*)\[\/u\]/Usi", "<u>\\1</u>", $str);
		$str = preg_replace("/\[v\](.*)\[\/v\]/Usi", "<a href=\"javascript=void(0)\" onclick=\"showVideo('\\1')\">\\1</v>", $str);
		$str = preg_replace("/\[l (.*)\](.*)\[\/l\]/Us", "<a href=\"/page/\\1\">\\2</span>", $str);
		$str = preg_replace("/\[L (.*)\](.*)\[\/L\]/Us", "<a href=\"/page/\\1\" target=\"_blank\">\\2</span>", $str);
		return nl2br($str);
	}

}

$import = new HelpToImport(dirname(__FILE__).'/messages.csv', ';', '"', 1);