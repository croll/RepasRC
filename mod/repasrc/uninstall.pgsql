DROP INDEX IF EXISTS "rrc_family_label_caps_idx"; 
DROP INDEX IF EXISTS "rrc_family_label_idx"; 
DROP INDEX IF EXISTS "rrc_family_gid_idx"; 
DROP TABLE IF EXISTS "rrc_family";

DROP INDEX IF EXISTS "rrc_familygroup_rrc_fg_code_idx"; 
DROP TABLE IF EXISTS "rrc_family_group";

DROP INDEX IF EXISTS "rrc_foodstuff_label_caps_idx"; 
DROP INDEX IF EXISTS "rrc_foodstuff_conservation_type_idx"; 
DROP INDEX IF EXISTS "rrc_foodstuff_production_idx"; 
DROP TABLE IF EXISTS "rrc_foodstuff";
DROP TYPE IF EXISTS "rrc_fs_unit_type";
DROP TYPE IF EXISTS "rrc_fs_production_type";
DROP TYPE IF EXISTS "rrc_fs_conservation_type";

DROP TABLE IF EXISTS "rrc_foodstuff_datatype";

DROP INDEX IF EXISTS "rrc_foodstuffdatavalue_fid_idx"; 
DROP INDEX IF EXISTS "rrc_foodstuffdatavalue_fdid_idx";
DROP TABLE IF EXISTS "rrc_foodstuff_datavalue";

DROP INDEX IF EXISTS "rrc_foodstufffamily_fa_idx"; 
DROP INDEX IF EXISTS "rrc_foodstufffamily_fs_idx"; 
DROP TABLE IF EXISTS "rrc_foodstuff_family";

DROP INDEX IF EXISTS "rrc_foodstufsynonym_fs_idx"; 
DROP TABLE IF EXISTS "rrc_foodstuff_synonym";

DROP INDEX IF EXISTS "rrc_geozonetype_rrc_id_idx"; 
DROP TABLE IF EXISTS "rrc_geo_zonetype";

DROP INDEX IF EXISTS "rrc_geozonevalue_rrc_zv_idx"; 
DROP INDEX IF EXISTS "rrc_geozonevalue_lc_idx"; 
DROP TABLE IF EXISTS "rrc_geo_zonevalue";

DROP INDEX IF EXISTS "rrc_menu_rid_idx"; 
DROP TABLE IF EXISTS "rrc_menu";

DROP INDEX IF EXISTS "rrc_menurecipe_re_idx"; 
DROP INDEX IF EXISTS "rrc_menurecipe_me_idx"; 
DROP TABLE IF EXISTS "rrc_menu_recipe";

DROP INDEX IF EXISTS "rrc_origin_zo_idx"; 
DROP INDEX IF EXISTS "rrc_origin_fs_idx"; 
DROP TABLE IF EXISTS "rrc_origin";
DROP TYPE IF EXISTS "rrc_or_location_type";

DROP INDEX IF EXISTS "rrc_rc_zv_idx"; 
DROP INDEX IF EXISTS "rrc_rc_us_idx"; 
DROP TABLE IF EXISTS "rrc_rc";
DROP TYPE IF EXISTS "rrc_rc_type_type";
DROP TYPE IF EXISTS "rrc_rc_public_type";
DROP TYPE IF EXISTS "rrc_rc_age_type";
DROP TYPE IF EXISTS "rrc_rc_regime_type";

DROP INDEX IF EXISTS "rrc_rc_rc_idx"; 
DROP TABLE IF EXISTS "rrc_recipe";
DROP TYPE IF EXISTS "rrc_re_component_type";

DROP INDEX IF EXISTS "rrc_rf_fs_idx"; 
DROP INDEX IF EXISTS "rrc_rf_fss_idx"; 
DROP TABLE IF EXISTS "rrc_recipe_foodstuff";
DROP TYPE IF EXISTS "rrc_rf_conservation_type";
DROP TYPE IF EXISTS "rrc_rf_production_type";
DROP TYPE IF EXISTS "rrc_rf_quantity_unit_type";
