--
-- Table structure for table "rrc_family"
--

CREATE TABLE "rrc_family" (
  "rrc_fa_id" SERIAL PRIMARY KEY,
  "rrc_fa_label" VARCHAR(255) DEFAULT NULL,
  "rrc_fa_label_caps" VARCHAR(255) NOT NULL,
  "rrc_fa_code" VARCHAR(50) NOT NULL,
  "rrc_fa_rrc_family_group_id" INTEGER DEFAULT NULL,
  "rrc_fa_creation" TIMESTAMP NOT NULL,
  "rrc_fa_modification" TIMESTAMP
);
CREATE INDEX rrc_family_label_caps_idx ON "rrc_family" ("rrc_fa_label_caps");
CREATE INDEX rrc_family_label_idx ON "rrc_family" ("rrc_fa_label");
CREATE INDEX rrc_family_gid_idx ON "rrc_family" ("rrc_fa_rrc_family_group_id");
ALTER SEQUENCE rrc_family_rrc_fa_id_seq RESTART WITH 500; 

--
-- Table structure for table "rrc_family_group"
--

CREATE TABLE "rrc_family_group" (
  "rrc_fg_id" SERIAL PRIMARY KEY,
  "rrc_fg_level" INTEGER NOT NULL,
  "rrc_fg_name" VARCHAR(255) NOT NULL,
  "rrc_fg_code" INTEGER NOT NULL
);
CREATE INDEX rrc_familygroup_rrc_fg_code_idx ON "rrc_family_group" ("rrc_fg_code");
ALTER SEQUENCE rrc_family_group_rrc_fg_id_seq RESTART WITH 500; 

--
-- Table structure for table "rrc_foodstuff"
--

CREATE TYPE "rrc_fs_unit_type" AS ENUM ('KG','L','ONE_PIECE');
CREATE TYPE "rrc_fs_conservation_type" AS ENUM ('', 'F','Su','Co','D','G1','G2','G3','G4','G5');
CREATE TYPE "rrc_fs_production_type" AS ENUM ('', 'Conv','AB','Dur','Lab','AOC','IGP', 'BBC', 'COHERENCE', 'COMMERCEEQUITABLE');

CREATE TABLE "rrc_foodstuff" (
  "rrc_fs_id" SERIAL PRIMARY KEY,
  "rrc_fs_label" VARCHAR(255) DEFAULT NULL,
  "rcc_fs_label_en" VARCHAR(255) DEFAULT NULL,
  "rrc_fs_label_caps" VARCHAR(255) DEFAULT NULL,
  "rrc_fs_code" VARCHAR(50) DEFAULT NULL,
  "rrc_fs_unit" rrc_fs_unit_type DEFAULT 'KG',
  "rrc_fs_conservation" rrc_fs_conservation_type DEFAULT NULL,
  "rrc_fs_production" rrc_fs_production_type DEFAULT NULL,
  "rrc_fs_creation" TIMESTAMP NOT NULL,
  "rrc_fs_modification" TIMESTAMP
);
CREATE INDEX rrc_foodstuff_label_caps_idx ON "rrc_foodstuff" ("rrc_fs_label_caps");
CREATE INDEX rrc_foodstuff_conservation_type_idx ON "rrc_foodstuff" ("rrc_fs_conservation");
CREATE INDEX rrc_foodstuff_production_idx ON "rrc_foodstuff" ("rrc_fs_production");
ALTER SEQUENCE rrc_foodstuff_rrc_fs_id_seq RESTART WITH 500; 

--
-- Table structure for table "rrc_foodstuff_datatype"
--

CREATE TABLE "rrc_foodstuff_datatype" (
  "rrc_ft_id" SERIAL PRIMARY KEY,
  "rrc_ft_label" VARCHAR(255) NOT NULL,
  "rrc_ft_code" VARCHAR(50) DEFAULT NULL,
  "rrc_ft_comment" VARCHAR(255) DEFAULT NULL,
  "rrc_ft_unit" VARCHAR(50) NOT NULL,
  "rrc_ft_creation" TIMESTAMP NOT NULL,
  "rrc_ft_modification" TIMESTAMP
);
ALTER SEQUENCE rrc_foodstuff_datatype_rrc_ft_id_seq RESTART WITH 500; 

--
-- Table structure for table "rrc_foodstuff_datavalue"
--

CREATE TABLE "rrc_foodstuff_datavalue" (
  "rrc_dv_id" SERIAL PRIMARY KEY ,
  "rrc_dv_value" DECIMAL(18,9) DEFAULT NULL,
  "rrc_dv_rrc_foodstuff_id" INTEGER DEFAULT NULL,
  "rrc_dv_rrc_foodstuff_datatype_id" INTEGER DEFAULT NULL,
  "rrc_dv_source" VARCHAR(255) DEFAULT NULL,
  "rrc_dv_comment" VARCHAR(255) DEFAULT NULL,
  "rrc_dv_year" INTEGER DEFAULT NULL,
  "rrc_dv_creation" TIMESTAMP NOT NULL,
  "rrc_dv_modification" TIMESTAMP
);
CREATE INDEX rrc_foodstuffdatavalue_fid_idx ON "rrc_foodstuff_datavalue" ("rrc_dv_rrc_foodstuff_id");
CREATE INDEX rrc_foodstuffdatavalue_fdid_idx ON "rrc_foodstuff_datavalue" ("rrc_dv_rrc_foodstuff_datatype_id");
ALTER SEQUENCE rrc_foodstuff_datavalue_rrc_dv_id_seq RESTART WITH 500; 

--
-- Table structure for table "rrc_foodstuff_family"
--

CREATE TABLE "rrc_foodstuff_family" (
  "rrc_ff_id" SERIAL PRIMARY KEY,
  "rrc_ff_rrc_foodstuff_id" INTEGER NOT NULL,
  "rrc_ff_rrc_family_id" INTEGER NOT NULL
);
CREATE INDEX rrc_foodstufffamily_fs_idx ON "rrc_foodstuff_family" ("rrc_ff_rrc_foodstuff_id");
CREATE INDEX rrc_foodstufffamily_fa_idx ON "rrc_foodstuff_family" ("rrc_ff_rrc_family_id");
ALTER SEQUENCE rrc_foodstuff_family_rrc_ff_id_seq RESTART WITH 1000; 

--
-- Table structure for table "rrc_foodstuff_synonym"
--

CREATE TABLE "rrc_foodstuff_synonym" (
  "rrc_ss_id" SERIAL PRIMARY KEY,
  "rrc_ss_label" varchar(255) NOT NULL DEFAULT 'NULL',
  "rrc_ss_rrc_foodstuff_id" INTEGER DEFAULT NULL
);
CREATE INDEX rrc_foodstufsynonym_fs_idx ON "rrc_foodstuff_synonym" ("rrc_ss_rrc_foodstuff_id");
ALTER SEQUENCE rrc_foodstuff_synonym_rrc_ss_id_seq RESTART WITH 500; 

--
-- Table structure for table "rrc_geo_zonetype"
--

CREATE TABLE "rrc_geo_zonetype" (
  "rrc_zt_id" SERIAL PRIMARY KEY,
  "rrc_zt_label" VARCHAR(255) NOT NULL,
  "rrc_zt_label_caps" VARCHAR(255) NOT NULL,
  "rrc_zt_code" VARCHAR(50) DEFAULT NULL,
  "rrc_zt_public" INTEGER DEFAULT 0,
  "rrc_zt_rrc_rc_id" INTEGER DEFAULT NULL
);
CREATE INDEX rrc_geozonetype_rrc_id_idx ON "rrc_geo_zonetype" ("rrc_zt_rrc_rc_id");
ALTER SEQUENCE rrc_geo_zonetype_rrc_zt_id_seq RESTART WITH 500; 

--
-- Table structure for table "rrc_geo_zonevalue"
--

CREATE TABLE "rrc_geo_zonevalue" (
  "rrc_zv_id" SERIAL PRIMARY KEY,
  "rrc_zv_label" VARCHAR(255) NOT NULL,
  "rrc_zv_label_caps" VARCHAR(255) NOT NULL,
  "rrc_zv_code" VARCHAR(50) NOT NULL,
  "rrc_zv_rrc_geo_zonetype_id" INTEGER NOT NULL,
  "rrc_zv_lat" DECIMAL(16,7) DEFAULT NULL,
  "rrc_zv_lon" DECIMAL(16,7) DEFAULT NULL
);
CREATE INDEX rrc_geozonevalue_rrc_zv_idx ON "rrc_geo_zonevalue" ("rrc_zv_rrc_geo_zonetype_id");
CREATE INDEX rrc_geozonevalue_lc_idx ON "rrc_geo_zonevalue" ("rrc_zv_label_caps");
SELECT AddGeometryColumn('rrc_geo_zonevalue', 'rrc_zv_geom', 4326, 'POINT', 2);
ALTER SEQUENCE rrc_geo_zonevalue_rrc_zv_id_seq RESTART WITH 50000; 

--
-- Table structure for table "rrc_menu"
--

CREATE TABLE "rrc_menu" (
  "rrc_me_id" SERIAL PRIMARY KEY,
  "rrc_me_eaters" INTEGER DEFAULT NULL,
  "rrc_me_label" VARCHAR(255) NOT NULL DEFAULT 'NULL',
  "rrc_me_rrc_rc_id" INTEGER NOT NULL,
  "rrc_me_price" INTEGER DEFAULT NULL,
  "rrc_me_vat" INTEGER DEFAULT 1,
  "rrc_me_creation" TIMESTAMP NOT NULL,
  "rrc_me_modification" TIMESTAMP,
  "rrc_me_public" INTEGER DEFAULT NULL,
	"rrc_me_consumptiondate" TIMESTAMP
);
CREATE INDEX rrc_menu_rid_idx ON "rrc_menu" ("rrc_me_rrc_rc_id");
ALTER SEQUENCE rrc_menu_rrc_me_id_seq RESTART WITH 500; 

--
-- Table structure for table "rrc_menu_recipe"
--

CREATE TABLE "rrc_menu_recipe" (
  "rrc_mr_id" SERIAL PRIMARY KEY,
  "rrc_mr_rrc_recipe_id" INTEGER DEFAULT NULL,
  "rrc_mr_rrc_menu_id" INTEGER DEFAULT NULL,
  "rrc_mr_portions" INTEGER DEFAULT NULL
);
CREATE INDEX rrc_menurecipe_re_idx ON "rrc_menu_recipe" ("rrc_mr_rrc_recipe_id");
CREATE INDEX rrc_menurecipe_me_idx ON "rrc_menu_recipe" ("rrc_mr_rrc_menu_id");
ALTER SEQUENCE rrc_menu_recipe_rrc_mr_id_seq RESTART WITH 1000; 

--
-- Table structure for table "rrc_origin"
--
CREATE TYPE "rrc_or_location_type" AS ENUM ('LOCAL','REGIONAL','FRANCE','EUROPE','WORLD');
CREATE TABLE "rrc_origin" (
  "rrc_or_id" SERIAL PRIMARY KEY,
  "rrc_or_default_location" rrc_or_location_type DEFAULT NULL,
  "rrc_or_rrc_geo_zonevalue_id" INTEGER DEFAULT NULL,
  "rrc_or_rrc_recipe_foodstuff_id" INTEGER,
  "rrc_or_rrc_supply_item_id" INTEGER,
  "rrc_or_step" INTEGER NOT NULL DEFAULT 0
);
CREATE INDEX rrc_origin_zo_idx ON "rrc_origin" ("rrc_or_rrc_geo_zonevalue_id");
CREATE INDEX rrc_origin_fs_idx ON "rrc_origin" ("rrc_or_rrc_recipe_foodstuff_id");
ALTER SEQUENCE rrc_origin_rrc_or_id_seq RESTART WITH 3000; 

--
-- Table structure for table "rrc_rc"
--

CREATE TYPE "rrc_rc_type_type" AS ENUM ('SELF_MANAGEMENT','CONCEDED');
CREATE TYPE "rrc_rc_public_type" AS ENUM ('SCHOLASTIC','SICKS','ELDERIES','WORKERS','OTHER');
CREATE TYPE "rrc_rc_age_type" AS ENUM ('NURSERY SCHOOL','PRIMARY SCHOOL','TEENAGERS-ADULTS','THIRD - FOURTH_AGE');
CREATE TYPE "rrc_rc_regime_type" AS ENUM ('HALF_BOARD','FULL_BOARD');
CREATE TABLE "rrc_rc" (
  "rrc_rc_id" SERIAL PRIMARY KEY,
  "rrc_rc_name" VARCHAR(255) NOT NULL,
  "rrc_rc_type" rrc_rc_type_type DEFAULT NULL,
  "rrc_rc_public" rrc_rc_public_type DEFAULT NULL,
  "rrc_rc_age" rrc_rc_age_type DEFAULT NULL,
  "rrc_rc_regime" rrc_rc_regime_type DEFAULT NULL,
  "rrc_rc_dayactive" INTEGER DEFAULT NULL,
  "rrc_rc_rrc_location_id" INTEGER DEFAULT NULL,
  "rrc_rc_creation" timestamp NOT NULL,
  "rrc_rc_modification" timestamp,
  "rrc_rc_rrc_geo_zonevalue_id" INTEGER DEFAULT NULL,
  "rrc_rc_user_id" INTEGER DEFAULT NULL
);
CREATE INDEX rrc_rc_zv_idx ON "rrc_rc" ("rrc_rc_rrc_geo_zonevalue_id");
CREATE INDEX rrc_rc_us_idx ON "rrc_rc" ("rrc_rc_user_id");
ALTER SEQUENCE rrc_rc_rrc_rc_id_seq RESTART WITH 500; 

--
-- Table structure for table "rrc_recipe"
--

CREATE TYPE "rrc_re_component_type" AS ENUM ('STARTER','MEAL','CHEESE/DESSERT','BREAD');
CREATE TYPE "rrc_re_recipe_type" AS ENUM ('STANDARD','LIGHTFOOTPRINT','ADMIN','STALLION');
CREATE TABLE "rrc_recipe" (
  "rrc_re_id" SERIAL PRIMARY KEY,
  "rrc_re_rrc_rc_id" INTEGER DEFAULT NULL,
  "rrc_re_public" VARCHAR DEFAULT '0',
  "rrc_re_label" VARCHAR(255) DEFAULT NULL,
  "rrc_re_component" rrc_re_component_type DEFAULT NULL,
  "rrc_re_persons" INTEGER DEFAULT NULL,
  "rrc_re_byadmin" INTEGER NOT NULL DEFAULT '0',
  "rrc_re_hash" TEXT,
  "rrc_re_creation" TIMESTAMP,
  "rrc_re_modification" TIMESTAMP,
  "rrc_re_comment" TEXT,
  "rrc_re_modules" INTEGER DEFAULT NULL,
	"rrc_re_consumptiondate" TIMESTAMP,
	"rrc_re_type" rrc_re_recipe_type DEFAULT 'STANDARD',
  "rrc_re_price" INTEGER DEFAULT NULL,
  "rrc_re_vat" INTEGER DEFAULT 1
);
CREATE INDEX rrc_rc_rc_idx ON "rrc_recipe" ("rrc_re_rrc_rc_id");
ALTER SEQUENCE rrc_recipe_rrc_re_id_seq RESTART WITH 1000; 

--
-- Table structure for table "rrc_recipe_foodstuff"
--

CREATE TYPE "rrc_rf_conservation_type" AS ENUM ('','G1','G2','G3','G4','G5','G6','G7');
CREATE TYPE "rrc_rf_production_type" AS ENUM ('', 'Conv','AB','Dur','Lab','AOC','IGP', 'BBC', 'COHERENCE', 'COMMERCEEQUITABLE');
CREATE TYPE "rrc_rf_quantity_unit_type" AS ENUM ('KG','G','UNIT');
CREATE TABLE "rrc_recipe_foodstuff" (
  "rrc_rf_id" SERIAL PRIMARY KEY,
  "rrc_rf_rrc_recipe_id" INTEGER DEFAULT NULL,
  "rrc_rf_rrc_foodstuff_id" INTEGER DEFAULT NULL,
  "rrc_rf_rrc_foodstuff_synonym_id" INTEGER DEFAULT NULL,
  "rrc_rf_quantity_unit" rrc_rf_quantity_unit_type NOT NULL DEFAULT 'KG',
  "rrc_rf_quantity_value" FLOAT DEFAULT NULL,
  "rrc_rf_price" FLOAT DEFAULT NULL,
  "rrc_rf_vat" INTEGER DEFAULT 0,
  "rrc_rf_conservation" rrc_rf_conservation_type DEFAULT NULL,
  "rrc_rf_production" rrc_rf_production_type DEFAULT NULL
);
CREATE INDEX rrc_rf_fs_idx ON "rrc_recipe_foodstuff" ("rrc_rf_rrc_foodstuff_id");
CREATE INDEX rrc_rf_fss_idx ON "rrc_recipe_foodstuff" ("rrc_rf_rrc_foodstuff_synonym_id");
ALTER SEQUENCE rrc_recipe_foodstuff_rrc_rf_id_seq RESTART WITH 2500; 
