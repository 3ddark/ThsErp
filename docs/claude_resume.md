# Resume State

## Goal
Regenerate all Account (acc_) module forms using modern TfrmInputSimpleDB / TfrmGrid pattern.

## Completed Tasks
- Read all 14 acc_ domain entities in ERP/BackEnd/Account/Domain/
- Analyzed base form classes: TfrmInputSimpleDB, TfrmGrid
- Created workflow for generating 28 forms (input + output per table)

## Workflow Running
- Task ID: w4oobqo6h
- Script: acc-forms-gen-wf_5a8d1cc7-f88.js
- Generating forms for 14 tables:
  1. acc_account_plan → ufrmAccHesapPlani / ufrmAccHesapPlanlari
  2. acc_bank → ufrmAccBanka / ufrmAccBanksi
  3. acc_group → ufrmAccGrup / ufrmAccGruplar
  4. acc_region → ufrmAccBolge / ufrmAccBolgeler
  5. acc_set_account_type → ufrmAccHesapTipi / ufrmAccHesapTipleri
  6. acc_set_ownership_type → ufrmAccSahiplikTipi / ufrmAccSahiplikTipleri
  7. acc_exchange_rate → ufrmAccDovizKuru / ufrmAccDovizKurlari
  8. acc_bank_branch → ufrmAccBankaSube / ufrmAccBankaSubeleri (FK: bank_id)
  9. acc_voucher → ufrmAccDefter / ufrmAccDefterler
  10. acc_account → ufrmAccHesapKarti / ufrmAccHesapKartlari (FK: type, group, region)
  11. acc_set_company_legal_form → ufrmAccFirmaTuru / ufrmAccFirmaTurleri (FK: ownership_id)
  12. acc_set_tax_rate → ufrmAccVergiOrani / ufrmAccVergiOranlari (FK: account fields)
  13. acc_transfer_code → ufrmAccTransferKodu / ufrmAccTransferKodlar (FK: account)
  14. acc_voucher_detail → ufrmAccDefterDetay / ufrmAccDefterDetaylar

## Pattern Used
- Input forms: TfrmInputSimpleDB<TEntity, TService> with pnlContent, helper buttons for FK fields
- Output forms: TfrmGrid<TEntity, TService> with DefineColumnWidths, CreateInputForm override
- DFM files match class names (e.g., frmAccHesapPlani ↔ TfrmAccHesapPlani)
