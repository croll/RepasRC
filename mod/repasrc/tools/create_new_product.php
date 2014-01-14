<?php

$filename = "aliments.csv";
$start = 213;

if (!is_file($filename)) {
    die ("File $filename not found");
}
foreach(file($filename) as $l) {
    $line = str_getcsv($l, ';');
    if (is_array($line) && isset($line[1])) {
      if (preg_match("/^a([0-9]+)$/", $line[1], $m)) {
        if ($m && isset($m[1]) && $m[1] >= $start) {
            echo "INSERT INTO rrc_foodstuff (rrc_fs_label, rcc_fs_label_en, rrc_fs_label_caps, rrc_fs_code, rrc_fs_unit, rrc_fs_creation, rrc_fs_modification, rrc_fs_comment) VALUES ('".str_replace("'", "''",$line[2])."', '$line[0]', '".strtoupper(str_replace("'", "''",$line[2]))."', '$line[1]', 'KG', now(), now(), 'Credit: Celine Warnery 2014');\n";
            echo "INSERT INTO rrc_foodstuff_datavalue (rrc_dv_value, rrc_dv_rrc_foodstuff_id, rrc_dv_rrc_foodstuff_datatype_id, rrc_dv_source, rrc_dv_year, rrc_dv_creation, rrc_dv_modification) VALUES (".preg_replace('/,/','.',$line[5]).", (SELECT rrc_fs_id FROM rrc_foodstuff WHERE rrc_fs_code='$line[1]'), 1, '$line[6]', '$line[7]', now(), now());\n";
            echo "INSERT INTO rrc_foodstuff_family (rrc_ff_rrc_foodstuff_id, rrc_ff_rrc_family_id) VALUES ((SELECT rrc_fs_id FROM rrc_foodstuff WHERE rrc_fs_code='$line[1]'), (SELECT rrc_fa_id FROM rrc_family WHERE rrc_fa_code='45'));\n\n";
            echo "INSERT INTO rrc_foodstuff_family (rrc_ff_rrc_foodstuff_id, rrc_ff_rrc_family_id) VALUES ((SELECT rrc_fs_id FROM rrc_foodstuff WHERE rrc_fs_code='$line[1]'), (SELECT rrc_fa_id FROM rrc_family WHERE rrc_fa_code='311'));\n\n";
        }
    }      
    }
}

echo "\n";

$filename = "synonymes.csv";
$start = 211;
$done = [];

if (!is_file($filename)) {
    die ("File $filename not found");
}

foreach(file($filename) as $l) {
    $line = str_getcsv($l, ';');
    if (is_array($line) && isset($line[0])) {
      if (preg_match("/^a([0-9]+)$/", $line[0], $m)) {
        if ($m && isset($m[1]) && $m[1] >= $start) {
            if (in_array($m[1], $done)) {
                $id=end($done)+1;
                $done[] = $id;
            } else {
                $id = $m[1];
                $done[] = $m[1];
            }
            echo "INSERT INTO rrc_foodstuff_synonym (rrc_ss_id, rrc_ss_label, rrc_ss_label_caps, rrc_ss_code, rrc_ss_rrc_foodstuff_id) VALUES ($id, '".str_replace("'", "''",$line[1])."', '".strtoupper(str_replace("'", "''",$line[1]))."', 's$id', (SELECT rrc_fs_id FROM rrc_foodstuff WHERE rrc_fs_code='$line[0]'));\n";
        }
    }      
    }
}


?>