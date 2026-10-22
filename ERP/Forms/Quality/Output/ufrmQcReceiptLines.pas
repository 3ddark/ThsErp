unit ufrmQcReceiptLines;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  QcReceiptLine.Service, QcReceiptLine;

type
  // Kalite kontrol gereken mal kabul kalemleri (salt okunur; modül kapalıyken boş). Hızlı filtre bekleyen / kontrol
  // edilen / tümü; çift tık ya da popup ile kontrol kaydı girilir / açılır. Mal kabul listesine eklenti olarak bağlanır
  // (PurReceiptExtension, initialization): satın alma modülü bu birimi kullanmaz.
  TfrmQcReceiptLines = class(TfrmGrid<TQcReceiptLine, TQcReceiptLineService>)
  private
    FFixedReceiptName: string;
    FmniInspect: TMenuItem;
    procedure mniInspectClick(Sender: TObject);
    procedure StatusGetText(Sender: TField; var Text: string; DisplayText: Boolean);
    procedure ResultGetText(Sender: TField; var Text: string; DisplayText: Boolean);
  public
    procedure SetFixedReceipt(AReceiptId: Int64; const AReceiptName: string);
    procedure grdDblClick(Sender: TObject); override;
    procedure PreparePopupMenu; override;
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  QcLookup, PurReceiptExtension, UnitOfWork, SysPermission.Service,
  QcSetting, QcSetting.Service, QcInspection, QcInspection.Service, ufrmQcInspection;

procedure TfrmQcReceiptLines.StatusGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if Sender.IsNull then
    Text := ''
  else
    Text := TQcLookup.Text(qlkStatus, Sender.AsInteger);
end;

procedure TfrmQcReceiptLines.ResultGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if Sender.IsNull then
    Text := ''
  else
    Text := TQcLookup.Text(qlkResult, Sender.AsInteger);
end;

procedure TfrmQcReceiptLines.SetFixedReceipt(AReceiptId: Int64; const AReceiptName: string);
begin
  FFixedReceiptName := AReceiptName;
  AddFixedFilter('pur_receipt_id', AReceiptId);
end;

procedure TfrmQcReceiptLines.grdDblClick(Sender: TObject);
begin
  if IsHelper then
    inherited
  else
    mniInspectClick(Sender);
end;

// Kontrol kaydı: varsa açılır (inceleme), yoksa mal kabul kalemine bağlı yeni kayıt
procedure TfrmQcReceiptLines.mniInspectClick(Sender: TObject);
var
  LSvc: TQcInspectionService;
  LInspection: TQcInspection;
  LMode: TInputFormMode;
begin
  if Grd.DataSource.DataSet.IsEmpty then
    Exit;

  SetSelectedItem;
  LSvc := TQcInspectionService.Create;
  try
    if Table.QcInspectionId > 0 then
    begin
      LInspection := LSvc.BusinessFindById(Table.QcInspectionId, False, False, True);
      LMode := ifmRewiev;
    end
    else
    begin
      LInspection := TQcInspection.Create;
      LInspection.PurReceiptDetailId := Table.Id;
      LInspection.StkInventoryId := Table.StkInventoryId;
      LInspection.Quantity := Table.Quantity;
      LInspection.PurReceiptId := Table.PurReceiptId;
      LInspection.ReceiptNo := Table.ReceiptNo;
      LInspection.ReceiptLineNo := Table.LineNo;
      LInspection.AccountName := Table.AccountName;
      LInspection.WarehouseName := Table.WarehouseName;
      LInspection.InventoryCode := Table.InventoryCode;
      LInspection.InventoryName := Table.InventoryName;
      LInspection.UomCode := Table.UomCode;
      LMode := ifmNewRecord;
    end;
  except
    LSvc.Free;
    raise;
  end;
  if not Assigned(LInspection) then
  begin
    LSvc.Free;
    Exit;
  end;
  TfrmQcInspection.Create(Self, LSvc, LInspection, LMode, Self.RefreshParentGrid, ivmNormal, True).Show;
end;

procedure TfrmQcReceiptLines.PreparePopupMenu;
begin
  inherited;
  if IsHelper then
    Exit;

  AddPopupMenuSpliter();
  FmniInspect := AddMenu(TLocalizationManager.Translate(TLangKeys.TQcReceiptLine.MenuInspect, 'Record / Open Inspection'),
    'mniInspect', mniInspectClick);
end;

function TfrmQcReceiptLines.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  // Salt okunur liste: kontrol kaydı popup / çift tık ile açılır
  Result := nil;
end;

procedure TfrmQcReceiptLines.DefineColumnWidths;
var
  LField: TField;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('pur_receipt_id', 0);
  SetColumnProperty('acc_account_id', 0);
  SetColumnProperty('stk_warehouse_id', 0);
  SetColumnProperty('stk_inventory_id', 0);
  SetColumnProperty('qc_inspection_id', 0);
  LField := Grd.DataSource.DataSet.FindField('qc_status');
  if Assigned(LField) then
    LField.OnGetText := StatusGetText;
  LField := Grd.DataSource.DataSet.FindField('result');
  if Assigned(LField) then
    LField.OnGetText := ResultGetText;
end;

procedure TfrmQcReceiptLines.FormShow(Sender: TObject);
begin
  // Hızlı filtre: bekleyen (yeni + yeniden kontrol) / kontrol edilen / tümü
  if QuickFilterCount = 0 then
  begin
    AddQuickFilter('', 'qc_status IN (:qc0, :qc1)', [QC_STATUS_PENDING, QC_STATUS_RECHECK]);
    AddQuickFilter('', 'qc_status = :qc0', [QC_STATUS_DONE]);
    AddQuickFilter('', '', []);
  end;
  inherited;
  if Assigned(BtnAdd) then
    BtnAdd.Visible := False;
  if Assigned(mniDuplicate) then
    mniDuplicate.Visible := False;
  ApplyLocalization;
end;

procedure TfrmQcReceiptLines.ApplyLocalization;
begin
  inherited;
  SetQuickFilterCaption(0, TLocalizationManager.Translate(TLangKeys.TQcReceiptLine.QuickPending, 'Awaiting'));
  SetQuickFilterCaption(1, TLocalizationManager.Translate(TLangKeys.TQcReceiptLine.QuickDone, 'Inspected'));
  SetQuickFilterCaption(2, TLocalizationManager.Translate(TLangKeys.TGeneral.QuickAll, 'All'));
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TQcReceiptLine.TitlePlural, 'Receipts Awaiting Inspection');
  if FFixedReceiptName <> '' then
    Self.Caption := Self.Caption + ' - ' + FFixedReceiptName;
  SetColumnTitle('receipt_no', TLocalizationManager.Translate(TLangKeys.TQcInspection.ColReceiptNo, 'Receipt No'));
  SetColumnTitle('receipt_date', TLocalizationManager.Translate(TLangKeys.TQcInspection.ColReceiptDate, 'Receipt Date'));
  SetColumnTitle('account_name', TLocalizationManager.Translate(TLangKeys.TQcInspection.ColAccountName, 'Supplier'));
  SetColumnTitle('warehouse_name', TLocalizationManager.Translate(TLangKeys.TQcInspection.ColWarehouseName, 'Warehouse'));
  SetColumnTitle('line_no', TLocalizationManager.Translate(TLangKeys.TQcInspection.ColReceiptLineNo, 'Line'));
  SetColumnTitle('inventory_code', TLocalizationManager.Translate(TLangKeys.TQcInspection.ColInventoryCode, 'Stock Code'));
  SetColumnTitle('inventory_name', TLocalizationManager.Translate(TLangKeys.TQcInspection.ColInventoryName, 'Stock Name'));
  SetColumnTitle('uom_code', TLocalizationManager.Translate(TLangKeys.TQcInspection.ColUomCode, 'Unit'));
  SetColumnTitle('quantity', TLocalizationManager.Translate(TLangKeys.TQcReceiptLine.ColQuantity, 'Received Quantity'));
  SetColumnTitle('inspection_criteria', TLocalizationManager.Translate(TLangKeys.TQcRule.ColInspectionCriteria, 'Inspection Criteria'));
  SetColumnTitle('inspection_no', TLocalizationManager.Translate(TLangKeys.TQcInspection.ColInspectionNo, 'Inspection No'));
  SetColumnTitle('inspection_date', TLocalizationManager.Translate(TLangKeys.TQcInspection.ColInspectionDate, 'Inspection Date'));
  SetColumnTitle('inspected_quantity', TLocalizationManager.Translate(TLangKeys.TQcReceiptLine.ColInspectedQuantity, 'Inspected Quantity'));
  SetColumnTitle('accepted_quantity', TLocalizationManager.Translate(TLangKeys.TQcInspection.ColAcceptedQuantity, 'Accepted Quantity'));
  SetColumnTitle('rejected_quantity', TLocalizationManager.Translate(TLangKeys.TQcInspection.ColRejectedQuantity, 'Rejected Quantity'));
  SetColumnTitle('result', TLocalizationManager.Translate(TLangKeys.TQcInspection.ColResult, 'Result'));
  SetColumnTitle('qc_status', TLocalizationManager.Translate(TLangKeys.TQcReceiptLine.ColQcStatus, 'Inspection Status'));
  if Assigned(FmniInspect) then
    FmniInspect.Caption := TLocalizationManager.Translate(TLangKeys.TQcReceiptLine.MenuInspect, 'Record / Open Inspection');
end;

{ Mal kabul listesine eklenti }

// modül açık ve kullanıcı kontrol kayıtlarını okuyabiliyorsa
function ReceiptQualityAvailable: Boolean;
var
  LSvc: TQcSettingService;
begin
  Result := False;
  try
    if not TUnitOfWork.Instance.IsAuthorized(PERMISSION_QC_INSPECTION, ptRead, True) then
      Exit;
    LSvc := TQcSettingService.Create;
    try
      Result := LSvc.IsEnabled;
    finally
      LSvc.Free;
    end;
  except
    // eklenti mal kabul ekranını hiçbir durumda bozmaz
    Result := False;
  end;
end;

procedure ReceiptQualityShow(AOwner: TComponent; AReceiptId: Int64; const AReceiptNo: string);
var
  LFrm: TfrmQcReceiptLines;
begin
  LFrm := TfrmQcReceiptLines.Create(AOwner, TQcReceiptLineService.Create, TQcReceiptLine.Create);
  LFrm.SetFixedReceipt(AReceiptId, AReceiptNo);
  LFrm.Show;
end;

initialization
  GReceiptQualityAvailable := ReceiptQualityAvailable;
  GReceiptQualityShow := ReceiptQualityShow;

end.
