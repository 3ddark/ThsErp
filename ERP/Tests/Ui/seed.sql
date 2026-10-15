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

-- finans: kasa + banka hesabı, gelen EFT, bankadan kasaya virman, kasa masrafı
INSERT INTO fin_money_account (account_kind, code, name) VALUES (1, 'K01', 'UI MERKEZ KASA');
INSERT INTO fin_money_account (account_kind, code, name, acc_bank_id, acc_bank_branch_id, account_no, iban)
SELECT 2, 'B01', 'UI BANKA TL', (SELECT min(id) FROM acc_bank), (SELECT max(id) FROM acc_bank_branch), '123456', 'TR330006100519786457841326';
INSERT INTO fin_money_transaction (fin_money_account_id, transaction_type, transfer_method, acc_account_id, amount, document_no, counterparty_name)
SELECT (SELECT id FROM fin_money_account WHERE code = 'B01'), 1, 3, (SELECT min(id) FROM acc_account), 5000, 'D-1', 'UI GÖNDEREN';
INSERT INTO fin_money_transaction (fin_money_account_id, transaction_type, target_fin_money_account_id, amount)
SELECT (SELECT id FROM fin_money_account WHERE code = 'B01'), 3, (SELECT id FROM fin_money_account WHERE code = 'K01'), 1200;
INSERT INTO fin_money_transaction (fin_money_account_id, transaction_type, amount, description)
SELECT (SELECT id FROM fin_money_account WHERE code = 'K01'), 4, 15.50, 'UI MASRAF';

-- satın alma: taslak talep + taslak sipariş (düzenlenebilir), kısmi teslim alınmış sipariş + mal kabul + fatura
INSERT INTO pur_request (request_no, emp_employee_id, description) SELECT 'PT900001', min(id), 'UI TALEP' FROM emp_employee;
INSERT INTO pur_request_detail (pur_request_id, stk_inventory_id, quantity) SELECT (SELECT max(id) FROM pur_request), min(id), 10 FROM stk_inventory;
INSERT INTO pur_order (order_no, acc_account_id, stk_warehouse_id, status) SELECT 'PS900001', (SELECT min(id) FROM acc_account), (SELECT min(id) FROM stk_warehouse), 1;
INSERT INTO pur_order_detail (pur_order_id, line_no, stk_inventory_id, quantity, unit_price, discount_rate, vat_rate, gross_amount, discount_amount, net_amount, vat_amount, total_amount)
SELECT (SELECT id FROM pur_order WHERE order_no = 'PS900001'), 1, min(id), 10, 2.5, 10, 20, 25, 2.5, 22.5, 4.5, 27 FROM stk_inventory;
INSERT INTO pur_order (order_no, acc_account_id, stk_warehouse_id, status) SELECT 'PS900002', (SELECT min(id) FROM acc_account), (SELECT min(id) FROM stk_warehouse), 3;
INSERT INTO pur_order_detail (pur_order_id, line_no, stk_inventory_id, quantity, unit_price, gross_amount, net_amount, total_amount, received_quantity)
SELECT (SELECT id FROM pur_order WHERE order_no = 'PS900002'), 1, min(id), 20, 3, 60, 60, 60, 5 FROM stk_inventory;
UPDATE pur_order o SET gross_amount = s.g, discount_amount = s.d, net_amount = s.n, vat_amount = s.v, total_amount = s.t
  FROM (SELECT pur_order_id, sum(gross_amount) g, sum(discount_amount) d, sum(net_amount) n, sum(vat_amount) v, sum(total_amount) t FROM pur_order_detail GROUP BY 1) s
 WHERE s.pur_order_id = o.id;
INSERT INTO pur_receipt (receipt_no, acc_account_id, stk_warehouse_id, waybill_no, pur_order_id)
SELECT 'MK900001', (SELECT min(id) FROM acc_account), (SELECT min(id) FROM stk_warehouse), 'IRS-1', (SELECT id FROM pur_order WHERE order_no = 'PS900002');
INSERT INTO pur_receipt_detail (pur_receipt_id, stk_inventory_id, quantity, unit_price, pur_order_detail_id)
SELECT (SELECT max(id) FROM pur_receipt), d.stk_inventory_id, 5, 3, d.id FROM pur_order_detail d JOIN pur_order o ON o.id = d.pur_order_id WHERE o.order_no = 'PS900002';
INSERT INTO stk_transaction (transaction_type, stk_inventory_id, to_stk_warehouse_id, quantity, amount, transaction_date, description, pur_receipt_detail_id)
SELECT 1, d.stk_inventory_id, p.stk_warehouse_id, d.quantity, d.quantity * d.unit_price, p.receipt_date, 'MK ' || p.receipt_no, d.id
  FROM pur_receipt_detail d JOIN pur_receipt p ON p.id = d.pur_receipt_id;
INSERT INTO pur_invoice (invoice_no, acc_account_id, gross_amount, net_amount, total_amount) SELECT 'IRS-1', min(id), 15, 15, 15 FROM acc_account;
INSERT INTO pur_invoice_detail (pur_invoice_id, line_no, stk_inventory_id, quantity, unit_price, gross_amount, net_amount, total_amount, pur_receipt_detail_id)
SELECT (SELECT max(id) FROM pur_invoice), 1, stk_inventory_id, 5, 3, 15, 15, 15, id FROM pur_receipt_detail;

-- satış: taslak teklif, taslak sipariş, kısmi sevkli sipariş + irsaliye (stok çıkışı) + irsaliyeden fatura, irsaliyeli fatura
INSERT INTO sls_offer (offer_no, acc_account_id, status) SELECT 'ST900001', min(id), 1 FROM acc_account;
INSERT INTO sls_offer_detail (sls_offer_id, line_no, stk_inventory_id, quantity, unit_price, discount_rate, vat_rate, gross_amount, discount_amount, net_amount, vat_amount, total_amount)
SELECT (SELECT id FROM sls_offer WHERE offer_no = 'ST900001'), 1, min(id), 10, 2.5, 10, 20, 25, 2.5, 22.5, 4.5, 27 FROM stk_inventory;
INSERT INTO sls_order (order_no, acc_account_id, stk_warehouse_id, status) SELECT 'SS900001', (SELECT min(id) FROM acc_account), (SELECT min(id) FROM stk_warehouse), 1;
INSERT INTO sls_order_detail (sls_order_id, line_no, stk_inventory_id, quantity, unit_price, discount_rate, vat_rate, gross_amount, discount_amount, net_amount, vat_amount, total_amount)
SELECT (SELECT id FROM sls_order WHERE order_no = 'SS900001'), 1, min(id), 10, 2.5, 10, 20, 25, 2.5, 22.5, 4.5, 27 FROM stk_inventory;
INSERT INTO sls_order (order_no, acc_account_id, stk_warehouse_id, status) SELECT 'SS900002', (SELECT min(id) FROM acc_account), (SELECT min(id) FROM stk_warehouse), 3;
INSERT INTO sls_order_detail (sls_order_id, line_no, stk_inventory_id, quantity, unit_price, gross_amount, net_amount, total_amount, delivered_quantity)
SELECT (SELECT id FROM sls_order WHERE order_no = 'SS900002'), 1, min(id), 20, 3, 60, 60, 60, 7 FROM stk_inventory;
UPDATE sls_offer o SET gross_amount = s.g, discount_amount = s.d, net_amount = s.n, vat_amount = s.v, total_amount = s.t
  FROM (SELECT sls_offer_id, sum(gross_amount) g, sum(discount_amount) d, sum(net_amount) n, sum(vat_amount) v, sum(total_amount) t FROM sls_offer_detail GROUP BY 1) s
 WHERE s.sls_offer_id = o.id;
UPDATE sls_order o SET gross_amount = s.g, discount_amount = s.d, net_amount = s.n, vat_amount = s.v, total_amount = s.t
  FROM (SELECT sls_order_id, sum(gross_amount) g, sum(discount_amount) d, sum(net_amount) n, sum(vat_amount) v, sum(total_amount) t FROM sls_order_detail GROUP BY 1) s
 WHERE s.sls_order_id = o.id;
INSERT INTO sls_dispatch (dispatch_no, acc_account_id, stk_warehouse_id, sls_order_id)
SELECT 'SI900001', (SELECT min(id) FROM acc_account), (SELECT min(id) FROM stk_warehouse), (SELECT id FROM sls_order WHERE order_no = 'SS900002');
INSERT INTO sls_dispatch_detail (sls_dispatch_id, stk_inventory_id, quantity, unit_price, sls_order_detail_id)
SELECT (SELECT max(id) FROM sls_dispatch), d.stk_inventory_id, 5, 3, d.id FROM sls_order_detail d JOIN sls_order o ON o.id = d.sls_order_id WHERE o.order_no = 'SS900002';
INSERT INTO stk_transaction (transaction_type, stk_inventory_id, from_stk_warehouse_id, quantity, amount, transaction_date, description, sls_dispatch_detail_id)
SELECT 2, d.stk_inventory_id, p.stk_warehouse_id, d.quantity, d.quantity * d.unit_price, p.dispatch_date, p.dispatch_no, d.id
  FROM sls_dispatch_detail d JOIN sls_dispatch p ON p.id = d.sls_dispatch_id;
INSERT INTO sls_invoice (invoice_no, acc_account_id, gross_amount, net_amount, total_amount) SELECT 'SF900001', min(id), 15, 15, 15 FROM acc_account;
INSERT INTO sls_invoice_detail (sls_invoice_id, line_no, stk_inventory_id, quantity, unit_price, gross_amount, net_amount, total_amount, sls_dispatch_detail_id)
SELECT (SELECT max(id) FROM sls_invoice), 1, stk_inventory_id, 5, 3, 15, 15, 15, id FROM sls_dispatch_detail;
INSERT INTO sls_invoice (invoice_no, acc_account_id, stk_warehouse_id, gross_amount, net_amount, total_amount)
SELECT 'SF900002', (SELECT min(id) FROM acc_account), (SELECT min(id) FROM stk_warehouse), 6, 6, 6;
INSERT INTO sls_invoice_detail (sls_invoice_id, line_no, stk_inventory_id, quantity, unit_price, gross_amount, net_amount, total_amount, sls_order_detail_id)
SELECT (SELECT max(id) FROM sls_invoice), 1, d.stk_inventory_id, 2, 3, 6, 6, 6, d.id FROM sls_order_detail d JOIN sls_order o ON o.id = d.sls_order_id WHERE o.order_no = 'SS900002';
INSERT INTO stk_transaction (transaction_type, stk_inventory_id, from_stk_warehouse_id, quantity, amount, transaction_date, description, sls_invoice_detail_id)
SELECT 2, d.stk_inventory_id, f.stk_warehouse_id, d.quantity, d.net_amount, f.invoice_date, f.invoice_no, d.id
  FROM sls_invoice_detail d JOIN sls_invoice f ON f.id = d.sls_invoice_id WHERE f.invoice_no = 'SF900002';

-- firma banka hesabı (çek + çıktı) ve verilen çeke bağlantısı
INSERT INTO fin_company_bank_account (acc_bank_id, branch_code, branch_name, sys_city_id, account_no, iban, account_holder, show_on_cheque, show_on_print)
SELECT min(id), '1234', 'UI MERKEZ', (SELECT min(id) FROM sys_city), '6297711', 'TR330006100519786457841326', 'UI LTD', true, true FROM acc_bank;
UPDATE fin_cheque_note SET fin_company_bank_account_id = (SELECT max(id) FROM fin_company_bank_account),
       acc_bank_id = (SELECT acc_bank_id FROM fin_company_bank_account ORDER BY id DESC LIMIT 1)
 WHERE serial_no = 'UI-K1';

COMMIT;
