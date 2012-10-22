<?php  //  -*- mode:php; tab-width:2; c-basic-offset:2; -*-

namespace mod\repasrc;

class Graph {

  public static function recipeResume($recipeDetail) {
    $noData = $families = array();
    $gctPie = new \mod\googlecharttools\Main();
    $gctCol = new \mod\googlecharttools\Main();
    $gctComp = new \mod\googlecharttools\Main();
    $gctPie->addColumn('Aliment', 'string');
    $gctPie->addColumn('Empreinte écologique foncière pour la recette', 'number');
    $gctCol->addColumn('Val', 'string');
    $gctCol->addRow('Empreinte écologique foncière pour une personne');
    $gctComp->addColumn('Aliment', 'string');
    $gctComp->addColumn('Empreinte écologique foncière', 'number');
    $gctComp->addColumn('Quantité', 'number');
    foreach($recipeDetail['foodstuffList'] as $fs) {
        // Foodstuff with no footprint value
      if ($fs['foodstuff']['fake'] || empty($fs['foodstuff']['footprint'])) {
        $noData[] = $fs['foodstuff']['label'];
      } else {
        $gctPie->addRow($fs['foodstuff']['label']);
        $gctPie->addRow($fs['foodstuff']['footprint']*$fs['quantity']);
        $gctCol->addColumn($fs['foodstuff']['label'], 'number');
        $gctCol->addRow($fs['foodstuff']['footprint']*($fs['quantity']/$recipeDetail['persons']));
        $gctComp->addRow($fs['foodstuff']['label']);
        $gctComp->addRow(round(($fs['foodstuff']['footprint']*($fs['quantity'])*100)/$recipeDetail['footprint'],2));
        $gctComp->addRow(round(((float)$fs['quantity']*100)/($recipeDetail['totalWeight']/$recipeDetail['persons'])),2);
        if (isset($fs['families']) && sizeof($fs['families']) > 0) {
          $families[] = array_shift(array_keys($fs['families']));
        }
      }
    }
    return array(
      'pie' => $gctPie, 
      'col' => $gctCol, 
      'comp' => $gctComp, 
      'colors' => json_encode(\mod\repasrc\Tools::getColorsArray($families)), 
      'noData' => $noData
      );
  }

  public static function recipeTransport($recipeDetail) {
    $families = array();
    $gctCol1 = new \mod\googlecharttools\Main();
    $gctCol1->addColumn('Val', 'string');
    $gctCol1->addRow('Empreinte écologique du transport');
    $gctCol2 = new \mod\googlecharttools\Main();
    $gctCol2->addColumn('Val', 'string');
    $gctCol2->addRow('Empreinte écologique du transport');
    $gctComp = new \mod\googlecharttools\Main();
    $gctComp->addColumn('Aliment', 'string');
    $gctComp->addColumn('Empreinte écologique foncière', 'number');
    $gctComp->addColumn('Distance', 'number');
    foreach($recipeDetail['transport']['datas'] as $fs) {
      $gctCol1->addColumn($fs['foodstuff']['label'], 'number');
      $gctCol1->addRow($fs['transport']['distance']);
      $gctCol2->addColumn($fs['foodstuff']['label'], 'number');
      $gctCol2->addRow($fs['transport']['footprint']);
      $gctComp->addRow($fs['foodstuff']['label']);
      $gctComp->addRow(round($fs['transport']['distance'],3));
      $gctComp->addRow(round($fs['transport']['footprint'],3));
      if (isset($fs['families']) && sizeof($fs['families']) > 0) {
        $families[] = @array_shift(array_keys($fs['families']));
      }
    }
    return array(
      'col1' => $gctCol1, 
      'col2' => $gctCol2, 
      'comp' => $gctComp, 
      'colors' => json_encode(\mod\repasrc\Tools::getColorsArray($families))
      );
  }

  public static function menuTransport($menuDetail) {
    $families = array();
    $gctCol1 = new \mod\googlecharttools\Main();
    $gctCol1->addColumn('Val', 'string');
    $gctCol1->addRow('Empreinte écologique du transport');
    $gctCol2 = new \mod\googlecharttools\Main();
    $gctCol2->addColumn('Val', 'string');
    $gctCol2->addRow('Empreinte écologique du transport');
    $gctComp = new \mod\googlecharttools\Main();
    $gctComp->addColumn('Aliment', 'string');
    $gctComp->addColumn('Empreinte écologique foncière', 'number');
    $gctComp->addColumn('Distance', 'number');
    foreach($menuDetail['recipesList'] as $recipeDetail) {
      foreach($recipeDetail['transport']['datas'] as $fs) {
        $gctCol1->addColumn($fs['foodstuff']['label'], 'number');
        $gctCol1->addRow($fs['transport']['distance']);
        $gctCol2->addColumn($fs['foodstuff']['label'], 'number');
        $gctCol2->addRow($fs['transport']['footprint']);
        $gctComp->addRow($fs['foodstuff']['label']);
        $gctComp->addRow(round($fs['transport']['distance'],3));
        $gctComp->addRow(round($fs['transport']['footprint'],3));
        if (isset($fs['families']) && sizeof($fs['families']) > 0) {
          $families[] = @array_shift(array_keys($fs['families']));
        }
      }
    }
    return array(
      'col1' => $gctCol1, 
      'col2' => $gctCol2, 
      'comp' => $gctComp, 
      'colors' => json_encode(\mod\repasrc\Tools::getColorsArray($families))
      );
  }

  public static function recipeProductionConservation($recipeDetail) {
    $conservation = array();
    $production = array();
    $gctPie1 = new \mod\googlecharttools\Main();
    $gctPie2 = new \mod\googlecharttools\Main();
    $gctPie1->addColumn('Mode de conservation', 'string');
    $gctPie1->addColumn('Mode de conservation', 'number');
    $gctPie2->addColumn('Mode de production', 'string');
    $gctPie2->addColumn('Mode de production', 'number');
    foreach($recipeDetail['foodstuffList'] as $fs) {
      $label = (isset($fs['foodstuff']['synonym'])) ? $fs['foodstuff']['synonym'] : $fs['foodstuff']['label'];
          // Conservation
      if (empty($fs['production'])) {
        $conservation['Non renseigné'] = $label;
      } else {
        $conservation[$fs['conservation_label']][] = $label;
      }
      // Production
      if (empty($fs['production'])) {
        $production['Non renseigné'][] = $label;
      } else {
        $production[$fs['production_label']][] = $label;
      }
    }
    foreach($production as $type=>$fslabel) {
      $gctPie1->addRow($type);
      $gctPie1->addRow(sizeof($fslabel));
    }
    foreach($conservation as $type=>$fslabel) {
      $gctPie2->addRow($type);
      $gctPie2->addRow(sizeof($fslabel));
    }
    return array(
     'pie1' => $gctPie1, 
     'pie2' => $gctPie2
    );
  }

  public static function menuProductionConservation($menuDetail) {
    $conservation = array();
    $production = array();
    $gctPie1 = new \mod\googlecharttools\Main();
    $gctPie2 = new \mod\googlecharttools\Main();
    $gctPie1->addColumn('Mode de conservation', 'string');
    $gctPie1->addColumn('Mode de conservation', 'number');
    $gctPie2->addColumn('Mode de production', 'string');
    $gctPie2->addColumn('Mode de production', 'number');
    foreach($menuDetail['recipesList'] as $recipeDetail) {
      foreach($recipeDetail['foodstuffList'] as $fs) {
        $label = (isset($fs['foodstuff']['synonym'])) ? $fs['foodstuff']['synonym'] : $fs['foodstuff']['label'];
          // Conservation
        if (empty($fs['production'])) {
          $conservation['Non renseigné'] = $label;
        } else {
          $conservation[$fs['conservation_label']][] = $label;
        }
      // Production
        if (empty($fs['production'])) {
          $production['Non renseigné'][] = $label;
        } else {
          $production[$fs['production_label']][] = $label;
        }
      }
    }
    foreach($production as $type=>$fslabel) {
      $gctPie1->addRow($type);
      $gctPie1->addRow(sizeof($fslabel));
    }
    foreach($conservation as $type=>$fslabel) {
      $gctPie2->addRow($type);
      $gctPie2->addRow(sizeof($fslabel));
    }
    return array(
     'pie1' => $gctPie1, 
     'pie2' => $gctPie2
    );
  }

  public static function recipePrice($recipeDetail) {
    $vatin = array();
    $vatout = array();
    $gctCol1 = null;
    $gctCol2 = null;
    $ret = array();
    if (!empty($recipeDetail['totalPrice']['vatout'])) {
      $families = array();
      $gctCol1 = new \mod\googlecharttools\Main();
      $gctCol1->addColumn('Val', 'string');
      $gctCol1->addRow('Prix des aliments HT');
      foreach($recipeDetail['foodstuffList'] as $fs) {
        $label = (isset($fs['foodstuff']['synonym'])) ? $fs['foodstuff']['synonym'] : $fs['foodstuff']['label'];
        if ($fs['vat'] == 0 && !empty($fs['price'])) {
          $gctCol1->addColumn($label, 'number');
          $gctCol1->addRow($fs['price']);
          if (isset($fs['families']) && sizeof($fs['families']) > 0) {
            $families[] = @array_shift(array_keys($fs['families']));
          }
        }
      }
      $colors1 = json_encode(\mod\repasrc\Tools::getColorsArray($families));
      $ret['col1'] = array('graph' => $gctCol1, 'colors' => $colors1);
    }
    if (!empty($recipeDetail['totalPrice']['vatin'])) {
      $families = array();
      $gctCol2 = new \mod\googlecharttools\Main();
      $gctCol2->addColumn('Val', 'string');
      $gctCol2->addRow('Prix des aliments TTC');
      foreach($recipeDetail['foodstuffList'] as $fs) {
        $label = (isset($fs['foodstuff']['synonym'])) ? $fs['foodstuff']['synonym'] : $fs['foodstuff']['label'];
        if ($fs['vat'] == 1 && !empty($fs['price'])) {
          $gctCol2->addColumn($label, 'number');
          $gctCol2->addRow($fs['price']);
          if (isset($fs['families']) && sizeof($fs['families']) > 0) {
            $families[] = @array_shift(array_keys($fs['families']));
          }
        }
      }
      $colors2 = json_encode(\mod\repasrc\Tools::getColorsArray($families));
      $ret['col2'] = array('graph' => $gctCol2, 'colors' => $colors2);
    }
    return $ret;
  }

  public static function menuPrice($menuDetail) {
    $vatin = array();
    $vatout = array();
    $gctCol1 = new \mod\googlecharttools\Main();
    $gctCol2 = new \mod\googlecharttools\Main();
    $ret = array();
    foreach($menuDetail['recipesList'] as $recipeDetail) {
      if (!empty($recipeDetail['totalPrice']['vatout'])) {
        $families = array();
        $gctCol1->addColumn('Val', 'string');
        $gctCol1->addRow('Prix des aliments HT');
        foreach($recipeDetail['foodstuffList'] as $fs) {
          $label = (isset($fs['foodstuff']['synonym'])) ? $fs['foodstuff']['synonym'] : $fs['foodstuff']['label'];
          if ($fs['vat'] == 0 && !empty($fs['price'])) {
            $gctCol1->addColumn($label, 'number');
            $gctCol1->addRow($fs['price']);
            if (isset($fs['families']) && sizeof($fs['families']) > 0) {
              $families[] = @array_shift(array_keys($fs['families']));
            }
          }
        }
        $colors1 = json_encode(\mod\repasrc\Tools::getColorsArray($families));
        $ret['col1'] = array('graph' => $gctCol1, 'colors' => $colors1);
      }
      if (!empty($recipeDetail['totalPrice']['vatin'])) {
        $families = array();
        $gctCol2->addColumn('Val', 'string');
        $gctCol2->addRow('Prix des aliments TTC');
        foreach($recipeDetail['foodstuffList'] as $fs) {
          $label = (isset($fs['foodstuff']['synonym'])) ? $fs['foodstuff']['synonym'] : $fs['foodstuff']['label'];
          if ($fs['vat'] == 1 && !empty($fs['price'])) {
            $gctCol2->addColumn($label, 'number');
            $gctCol2->addRow($fs['price']);
            if (isset($fs['families']) && sizeof($fs['families']) > 0) {
              $families[] = @array_shift(array_keys($fs['families']));
            }
          }
        }
        $colors2 = json_encode(\mod\repasrc\Tools::getColorsArray($families));
        $ret['col2'] = array('graph' => $gctCol2, 'colors' => $colors2);
      }
    }
    return $ret;
  }

}

?>