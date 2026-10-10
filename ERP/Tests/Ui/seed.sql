-- ths_erp_it test DB: boş tablolara ekran testleri için birer örnek satır
BEGIN;
SELECT set_config('ths_erp.user_name', 'ui_seed', true);

INSERT INTO emp_transportation (car_no, car_name) VALUES (1, 'UI SERVİS 1');

INSERT INTO sys_address (sys_city_id, district, street)
SELECT min(id), 'UI İlçe', 'UI Sokak' FROM sys_city;

INSERT INTO emp_person_address (emp_employee_id, sys_address_id, address_type, is_primary)
SELECT (SELECT min(id) FROM emp_employee), (SELECT max(id) FROM sys_address), 'HOME', true;

INSERT INTO acc_account_address (acc_account_id, sys_address_id, address_type, is_primary)
SELECT (SELECT min(id) FROM acc_account), (SELECT max(id) FROM sys_address), 'BILLING', true;

INSERT INTO acc_transfer_code (transfer_code, description, account)
SELECT 'UI1', 'UI aktarım', min(code) FROM acc_account;

INSERT INTO sys_grid_filter (table_name, filter_content) VALUES ('vw_ui_dummy', '1=1');

INSERT INTO sys_user_permission_template (sys_user_id, sys_permission_template_id)
SELECT 4, min(id) FROM sys_permission_template;

INSERT INTO stk_card_kind_info (stk_inventory_id, stk_kind_property_id, s1)
SELECT (SELECT min(id) FROM stk_inventory), (SELECT min(id) FROM stk_kind_property), 'UI';

INSERT INTO stk_transaction (transaction_type, stk_inventory_id, to_stk_warehouse_id, quantity, amount, is_opening)
SELECT 1, (SELECT min(id) FROM stk_inventory), (SELECT min(id) FROM stk_warehouse), 10, 100, true;

INSERT INTO prd_packet_labour (packet_name) VALUES ('UI İŞÇİLİK PAKETİ');
INSERT INTO prd_packet_labour_detail (prd_packet_labour_id, prd_labour_id, quantity)
SELECT (SELECT max(id) FROM prd_packet_labour), (SELECT min(id) FROM prd_labour), 1;

INSERT INTO prd_bom_by_product (prd_bom_id, stk_inventory_id, quantity)
SELECT (SELECT min(id) FROM prd_bom), (SELECT max(id) FROM stk_inventory), 1;
INSERT INTO prd_bom_packet_labour (prd_bom_id, prd_packet_labour_id, quantity)
SELECT (SELECT min(id) FROM prd_bom), (SELECT max(id) FROM prd_packet_labour), 1;
INSERT INTO prd_bom_packet_raw (prd_bom_id, prd_packet_raw_id, quantity)
SELECT (SELECT min(id) FROM prd_bom), (SELECT min(id) FROM prd_packet_raw), 1;

COMMIT;
