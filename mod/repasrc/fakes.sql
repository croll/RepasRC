INSERT INTO rrc_foodstuff ("rrc_fs_label", "rrc_fs_label_caps", "rrc_fs_code", "rrc_fs_fake", "rrc_fs_comment", "rrc_fs_creation") VALUES ('Surimi', 'SURIMI', 'a1000', 1, '', now());
INSERT INTO rrc_foodstuff ("rrc_fs_label", "rrc_fs_label_caps", "rrc_fs_code", "rrc_fs_fake", "rrc_fs_comment", "rrc_fs_creation") VALUES ('Poisson', 'POISSON', 'a1001', 1, 'Désolés, nous ne sommes, pour l''instant, pas en mesure de prendre en compte l''empreinte écologique des poissons, l''expertise est en cours. Pour plus d''informations sur la surexploitation des ressources marines et sur les poissons à privilégier, cliquez ici : <a href="http://questcequonmange.fondation-nature-homme.org/des-actions-a-suivre-et-a-creer.html" alt="Informer et agir Ademe-FNH" target="_blank">S''informer et agir Ademe-FNH</a>', now());
UPDATE rrc_foodstuff SET rrc_fs_label_caps='OEUF' WHERE rrf_fs_id=68;

INSERT INTO rrc_foodstuff_family (rrc_ff_rrc_foodstuff_id, rrc_ff_rrc_family_id) VALUES (501, 29);
INSERT INTO rrc_foodstuff_family (rrc_ff_rrc_foodstuff_id, rrc_ff_rrc_family_id) VALUES (502, 29);

INSERT INTO rrc_foodstuff_datavalue (rrc_dv_value, rrc_dv_rrc_foodstuff_id, rrc_dv_rrc_foodstuff_datatype_id, rrc_dv_creation) VALUES (0, 501, 1, now());
INSERT INTO rrc_foodstuff_datavalue (rrc_dv_value, rrc_dv_rrc_foodstuff_id, rrc_dv_rrc_foodstuff_datatype_id, rrc_dv_creation) VALUES (0, 502, 1, now());

UPDATE rrc_family SET rrc_fa_rrc_family_group_id=21 WHERE rrc_fa_id=35;

DELETE FROM rrc_foodstuff_family where rrc_ff_rrc_foodstuff_id IN (155,156,154,153,186,119) AND rrc_ff_rrc_family_id=35;

