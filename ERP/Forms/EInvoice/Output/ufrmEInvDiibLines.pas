unit ufrmEInvDiibLines;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  EInvDiibLine.Service, EInvDiibLine, ufrmEInvDiibLine;

type
  TfrmEInvDiibLines = class(TfrmGrid<TEInvDiibLine, TEInvDiibLineService>)
  private
    FFixedDiibId: Int64;
    FFixedDiibNo: string;
    procedure LineKindGetText(Sender: TField; var Text: string; DisplayText: Boolean);
    procedure HolderTypeGetText(Sender: TField; var Text: string; DisplayText: Boolean);
  public
    procedure SetFixedDiib(ADiibId: Int64; const ADocumentNo: string);
    // Fatura kalemi seçimi: belge sahibi (1 firmamız / 2 müşteri) + müşteri, yalnız aktif satırlar
    procedure SetFixedHolder(AHolderType: SmallInt; AAccountId: Int64);
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure SetSelectedItem; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  EInvLookup;

procedure TfrmEInvDiibLines.LineKindGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if Sender.IsNull then
    Text := ''
  else
    Text := TEInvLookup.Text(elkDiibLineKind, Sender.AsInteger);
end;

procedure TfrmEInvDiibLines.HolderTypeGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if Sender.IsNull then
    Text := ''
  else
    Text := TEInvLookup.Text(elkDiibHolder, Sender.AsInteger);
end;
procedure TfrmEInvDiibLines.SetFixedDiib(ADiibId: Int64; const ADocumentNo: string);
begin
  FFixedDiibId := ADiibId;
  FFixedDiibNo := ADocumentNo;
  AddFixedFilter('einv_diib_id', ADiibId);
end;

procedure TfrmEInvDiibLines.SetFixedHolder(AHolderType: SmallInt; AAccountId: Int64);
begin
  AddFixedFilter('holder_type', AHolderType);
  if AHolderType = EINV_DIIB_CUSTOMER then
    AddFixedFilter('acc_account_id', AAccountId);
  AddFixedFilter('is_active', True);
  AddFixedFilter('diib_is_active', True);
end;

function TfrmEInvDiibLines.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
var
  LNew: TEInvDiibLine;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmEInvDiibLine.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
  begin
    LNew := TEInvDiibLine.Create;
    if FFixedDiibId > 0 then
    begin
      LNew.EinvDiibId := FFixedDiibId;
      LNew.DocumentNo := FFixedDiibNo;
    end;
    Result := TfrmEInvDiibLine.Create(Self, Service, LNew, AFormMode, Self.RefreshParentGrid);
  end
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmEInvDiibLine.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmEInvDiibLines.SetSelectedItem;

  function FieldText(const AFieldName: string): string;
  var
    LField: TField;
  begin
    LField := Grd.DataSource.DataSet.FindField(AFieldName);
    if Assigned(LField) then
      Result := LField.AsString
    else
      Result := '';
  end;

begin
  inherited;
  Table.DocumentNo := FieldText('document_no');
  Table.AccountName := FieldText('account_name');
  Table.GtipCode := FieldText('gtip_code');
  Table.GtipName := FieldText('gtip_name');
  Table.InventoryCode := FieldText('inventory_code');
  Table.InventoryName := FieldText('inventory_name');
  Table.UnitCode := FieldText('unit_code');
  Table.UomEinvCode := FieldText('uom_einv_code');
end;

procedure TfrmEInvDiibLines.DefineColumnWidths;
var
  LField: TField;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('einv_diib_id', 0);
  SetColumnProperty('einv_gtip_id', 0);
  SetColumnProperty('stk_inventory_id', 0);
  SetColumnProperty('sys_uom_id', 0);
  SetColumnProperty('acc_account_id', 0);
  LField := Grd.DataSource.DataSet.FindField('line_kind');
  if Assigned(LField) then
    LField.OnGetText := LineKindGetText;
  LField := Grd.DataSource.DataSet.FindField('holder_type');
  if Assigned(LField) then
    LField.OnGetText := HolderTypeGetText;
end;

procedure TfrmEInvDiibLines.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmEInvDiibLines.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TEInvDiibLine.TitlePlural, 'DIIB Lines');
  if FFixedDiibNo <> '' then
    Self.Caption := Self.Caption + ' - ' + FFixedDiibNo;
  SetColumnTitle('line_code', TLocalizationManager.Translate(TLangKeys.TEInvDiibLine.ColLineCode, 'DIIB Line Code'));
  SetColumnTitle('line_kind', TLocalizationManager.Translate(TLangKeys.TEInvDiibLine.ColLineKind, 'Line Kind'));
  SetColumnTitle('product_description', TLocalizationManager.Translate(TLangKeys.TEInvDiibLine.ColProductDescription, 'DIIB Product Description'));
  SetColumnTitle('quantity', TLocalizationManager.Translate(TLangKeys.TEInvDiibLine.ColQuantity, 'Quantity'));
  SetColumnTitle('is_active', TLocalizationManager.Translate(TLangKeys.TEInvDiibLine.ColIsActive, 'Active'));
  SetColumnTitle('document_no', TLocalizationManager.Translate(TLangKeys.TEInvDiibLine.ColDocumentNo, 'DIIB No'));
  SetColumnTitle('holder_type', TLocalizationManager.Translate(TLangKeys.TEInvDiibLine.ColHolderType, 'Certificate Holder'));
  SetColumnTitle('acc_account_id', TLocalizationManager.Translate(TLangKeys.TEInvDiibLine.ColAccAccountId, 'Customer / Exporter'));
  SetColumnTitle('account_name', TLocalizationManager.Translate(TLangKeys.TEInvDiibLine.ColAccountName, 'Customer / Exporter'));
  SetColumnTitle('gtip_code', TLocalizationManager.Translate(TLangKeys.TEInvDiibLine.ColGtipCode, 'GTIP Code'));
  SetColumnTitle('gtip_name', TLocalizationManager.Translate(TLangKeys.TEInvDiibLine.ColGtipName, 'GTIP Description'));
  SetColumnTitle('inventory_code', TLocalizationManager.Translate(TLangKeys.TEInvDiibLine.ColInventoryCode, 'Stock Code'));
  SetColumnTitle('inventory_name', TLocalizationManager.Translate(TLangKeys.TEInvDiibLine.ColInventoryName, 'Stock Card'));
  SetColumnTitle('unit_code', TLocalizationManager.Translate(TLangKeys.TEInvDiibLine.ColUnitCode, 'Unit'));
  SetColumnTitle('uom_einv_code', TLocalizationManager.Translate(TLangKeys.TEInvDiibLine.ColUomEinvCode, 'e-Document Unit Code'));
  SetColumnTitle('diib_is_active', TLocalizationManager.Translate(TLangKeys.TEInvDiibLine.ColDiibIsActive, 'Certificate Active'));
  SetColumnTitle('valid_until', TLocalizationManager.Translate(TLangKeys.TEInvDiibLine.ColValidUntil, 'Valid Until'));
end;

end.
