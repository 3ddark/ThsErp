unit ufrmQcInspections;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  QcInspection.Service, QcInspection, ufrmQcInspection;

type
  // Giriş kalite kontrol kayıtları: hızlı filtre tümü / uygun / uygunsuz (kısmen uygun dahil)
  TfrmQcInspections = class(TfrmGrid<TQcInspection, TQcInspectionService>)
  private
    procedure ResultGetText(Sender: TField; var Text: string; DisplayText: Boolean);
    procedure DispositionGetText(Sender: TField; var Text: string; DisplayText: Boolean);
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  QcLookup;

procedure TfrmQcInspections.ResultGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if Sender.IsNull then
    Text := ''
  else
    Text := TQcLookup.Text(qlkResult, Sender.AsInteger);
end;

procedure TfrmQcInspections.DispositionGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if Sender.IsNull then
    Text := ''
  else
    Text := TQcLookup.Text(qlkDisposition, Sender.AsInteger);
end;

function TfrmQcInspections.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) or (AFormMode = ifmCopyNewRecord) then
    Result := TfrmQcInspection.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmQcInspection.Create(Self, Service, TQcInspection.Create, AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmQcInspections.DefineColumnWidths;
var
  LField: TField;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('pur_receipt_detail_id', 0);
  SetColumnProperty('pur_receipt_id', 0);
  SetColumnProperty('acc_account_id', 0);
  SetColumnProperty('stk_warehouse_id', 0);
  SetColumnProperty('stk_inventory_id', 0);
  SetColumnProperty('emp_employee_id', 0);
  SetColumnProperty('stk_transaction_id', 0);
  SetColumnProperty('reject_stk_warehouse_id', 0);
  LField := Grd.DataSource.DataSet.FindField('result');
  if Assigned(LField) then
    LField.OnGetText := ResultGetText;
  LField := Grd.DataSource.DataSet.FindField('disposition');
  if Assigned(LField) then
    LField.OnGetText := DispositionGetText;
end;

procedure TfrmQcInspections.FormShow(Sender: TObject);
begin
  if QuickFilterCount = 0 then
  begin
    AddQuickFilter('', '', []);
    AddQuickFilter('', 'result = :qc0', [QC_RESULT_ACCEPTED]);
    AddQuickFilter('', 'result IN (:qc0, :qc1)', [QC_RESULT_REJECTED, QC_RESULT_PARTIAL]);
  end;
  inherited;
  // mal kabul kalemi başına tek kayıt: kopya anlamsız
  if Assigned(mniDuplicate) then
    mniDuplicate.Visible := False;
  ApplyLocalization;
end;

procedure TfrmQcInspections.ApplyLocalization;
begin
  inherited;
  SetQuickFilterCaption(0, TLocalizationManager.Translate(TLangKeys.TGeneral.QuickAll, 'All'));
  SetQuickFilterCaption(1, TLocalizationManager.Translate(TLangKeys.TQcOption.ResAccepted, 'Accepted'));
  SetQuickFilterCaption(2, TLocalizationManager.Translate(TLangKeys.TQcInspection.QuickNonconforming, 'Nonconforming'));
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TQcInspection.TitlePlural, 'Quality Inspections');
  SetColumnTitle('inspection_no', TLocalizationManager.Translate(TLangKeys.TQcInspection.ColInspectionNo, 'Inspection No'));
  SetColumnTitle('inspection_date', TLocalizationManager.Translate(TLangKeys.TQcInspection.ColInspectionDate, 'Inspection Date'));
  SetColumnTitle('receipt_no', TLocalizationManager.Translate(TLangKeys.TQcInspection.ColReceiptNo, 'Receipt No'));
  SetColumnTitle('receipt_date', TLocalizationManager.Translate(TLangKeys.TQcInspection.ColReceiptDate, 'Receipt Date'));
  SetColumnTitle('account_name', TLocalizationManager.Translate(TLangKeys.TQcInspection.ColAccountName, 'Supplier'));
  SetColumnTitle('warehouse_name', TLocalizationManager.Translate(TLangKeys.TQcInspection.ColWarehouseName, 'Warehouse'));
  SetColumnTitle('receipt_line_no', TLocalizationManager.Translate(TLangKeys.TQcInspection.ColReceiptLineNo, 'Line'));
  SetColumnTitle('inventory_code', TLocalizationManager.Translate(TLangKeys.TQcInspection.ColInventoryCode, 'Stock Code'));
  SetColumnTitle('inventory_name', TLocalizationManager.Translate(TLangKeys.TQcInspection.ColInventoryName, 'Stock Name'));
  SetColumnTitle('uom_code', TLocalizationManager.Translate(TLangKeys.TQcInspection.ColUomCode, 'Unit'));
  SetColumnTitle('quantity', TLocalizationManager.Translate(TLangKeys.TQcInspection.ColQuantity, 'Inspected Quantity'));
  SetColumnTitle('accepted_quantity', TLocalizationManager.Translate(TLangKeys.TQcInspection.ColAcceptedQuantity, 'Accepted Quantity'));
  SetColumnTitle('rejected_quantity', TLocalizationManager.Translate(TLangKeys.TQcInspection.ColRejectedQuantity, 'Rejected Quantity'));
  SetColumnTitle('result', TLocalizationManager.Translate(TLangKeys.TQcInspection.ColResult, 'Result'));
  SetColumnTitle('disposition', TLocalizationManager.Translate(TLangKeys.TQcInspection.ColDisposition, 'Disposition'));
  SetColumnTitle('employee_name', TLocalizationManager.Translate(TLangKeys.TQcInspection.ColEmployeeName, 'Inspected By'));
  SetColumnTitle('description', TLocalizationManager.Translate(TLangKeys.TQcInspection.ColDescription, 'Findings / Description'));
end;

end.
