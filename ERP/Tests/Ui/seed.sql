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

INSERT INTO acc_bank_branch (acc_bank_id, branch_code, branch_name, sys_city_id)
SELECT min(id), 9001, 'UI ŞUBE', (SELECT min(id) FROM sys_city) FROM acc_bank;
-- finans: alınan çek (portföyde), müşteri senedi, verilen çek, firma kredi kartı + harcama, POS + tahsilat
INSERT INTO fin_cheque_note (doc_kind, direction, portfolio_no, serial_no, issue_date, due_date, amount, currency, acc_account_id, acc_bank_id, drawer_name, status, acc_bank_branch_id)
SELECT 1, 1, 'MC000001', 'UI-C1', current_date, current_date + 30, 1500.50, fn_default_currency(), (SELECT min(id) FROM acc_account), (SELECT min(id) FROM acc_bank), 'UI KEŞİDECİ', 1, (SELECT max(id) FROM acc_bank_branch);
INSERT INTO fin_cheque_note (doc_kind, direction, portfolio_no, serial_no, issue_date, due_date, amount, currency, acc_account_id, status)
SELECT 2, 1, 'MS000001', 'UI-S1', current_date, current_date + 60, 2500, fn_default_currency(), (SELECT min(id) FROM acc_account), 1;
INSERT INTO fin_cheque_note (doc_kind, direction, portfolio_no, serial_no, issue_date, due_date, amount, currency, acc_account_id, acc_bank_id, status)
SELECT 1, 2, 'KC000001', 'UI-K1', current_date, current_date + 45, 900, fn_default_currency(), (SELECT max(id) FROM acc_account), (SELECT min(id) FROM acc_bank), 9;
INSERT INTO fin_cheque_note_transaction (fin_cheque_note_id, transaction_date, transaction_type, acc_account_id)
SELECT id, issue_date, status, acc_account_id FROM fin_cheque_note;

INSERT INTO fin_credit_card (card_name, acc_bank_id, card_holder, card_last_digits, card_limit, statement_day, payment_day, currency)
SELECT 'UI KART', min(id), 'UI SAHİBİ', '1234', 10000, 5, 15, fn_default_currency() FROM acc_bank;
INSERT INTO fin_credit_card_transaction (fin_credit_card_id, transaction_type, acc_account_id, amount, installment_count)
SELECT (SELECT max(id) FROM fin_credit_card), 1, (SELECT max(id) FROM acc_account), 1200, 3;

INSERT INTO fin_pos_terminal (pos_name, acc_bank_id, terminal_no, commission_rate, blocked_days, currency)
SELECT 'UI POS', min(id), 'T-001', 1.75, 30, fn_default_currency() FROM acc_bank;
INSERT INTO fin_pos_transaction (fin_pos_terminal_id, transaction_type, acc_account_id, amount, commission_rate, commission_amount, net_amount, value_date, card_last_digits)
SELECT (SELECT max(id) FROM fin_pos_terminal), 1, (SELECT min(id) FROM acc_account), 1000, 1.75, 17.50, 982.50, current_date + 30, '4321';

COMMIT;
