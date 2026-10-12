unit ufrmPurRequestDetails;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  PurRequestDetail.Service, PurRequestDetail, ufrmPurRequestDetail;

type
  TfrmPurRequestDetails = class(TfrmGrid<TPurRequestDetail, TPurRequestDetailService>)
  private
    FFixedMasterId: Int64;
    FFixedMasterName: string;
    procedure RequestStatusGetText(Sender: TField; var Text: string; DisplayText: Boolean);
  public
    procedure SetFixedRequest(AMasterId: Int64; const AMasterName: string);
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure SetSelectedItem; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  PurLookup;

procedure TfrmPurRequestDetails.RequestStatusGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if Sender.IsNull then
    Text := ''
  else
    Text := TPurLookup.Text(plkRequestStatus, Sender.AsInteger);
end;
procedure TfrmPurRequestDetails.SetFixedRequest(AMasterId: Int64; const AMasterName: string);
begin
  FFixedMasterId := AMasterId;
  FFixedMasterName := AMasterName;
  AddFixedFilter('pur_request_id', AMasterId);
end;

function TfrmPurRequestDetails.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
var
  LNew: TPurRequestDetail;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmPurRequestDetail.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
  begin
    LNew := TPurRequestDetail.Create;
    if FFixedMasterId > 0 then
    begin
      LNew.PurRequestId := FFixedMasterId;
      LNew.RequestNo := FFixedMasterName;
    end;
    Result := TfrmPurRequestDetail.Create(Self, Service, LNew, AFormMode, Self.RefreshParentGrid);
  end
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmPurRequestDetail.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmPurRequestDetails.SetSelectedItem;

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
  Table.RequestNo := FieldText('request_no');
  Table.InventoryCode := FieldText('inventory_code');
  Table.InventoryName := FieldText('inventory_name');
  Table.UomCode := FieldText('uom_code');
end;

procedure TfrmPurRequestDetails.DefineColumnWidths;
var
  LField: TField;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('pur_request_id', 0);
  SetColumnProperty('stk_inventory_id', 0);
  LField := Grd.DataSource.DataSet.FindField('request_status');
  if Assigned(LField) then
    LField.OnGetText := RequestStatusGetText;
end;

procedure TfrmPurRequestDetails.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmPurRequestDetails.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TPurRequestDetail.TitlePlural, 'Request Lines');
  if FFixedMasterName <> '' then
    Self.Caption := Self.Caption + ' - ' + FFixedMasterName;
  SetColumnTitle('quantity', TLocalizationManager.Translate(TLangKeys.TPurRequestDetail.ColQuantity, 'Quantity'));
  SetColumnTitle('ordered_quantity', TLocalizationManager.Translate(TLangKeys.TPurRequestDetail.ColOrderedQuantity, 'Ordered Quantity'));
  SetColumnTitle('required_date', TLocalizationManager.Translate(TLangKeys.TPurRequestDetail.ColRequiredDate, 'Required Date'));
  SetColumnTitle('description', TLocalizationManager.Translate(TLangKeys.TPurRequestDetail.ColDescription, 'Description'));
  SetColumnTitle('request_no', TLocalizationManager.Translate(TLangKeys.TPurRequestDetail.ColRequestNo, 'Request No'));
  SetColumnTitle('inventory_code', TLocalizationManager.Translate(TLangKeys.TPurRequestDetail.ColInventoryCode, 'Stock Code'));
  SetColumnTitle('inventory_name', TLocalizationManager.Translate(TLangKeys.TPurRequestDetail.ColInventoryName, 'Stock Name'));
  SetColumnTitle('uom_code', TLocalizationManager.Translate(TLangKeys.TPurRequestDetail.ColUomCode, 'Unit'));
  SetColumnTitle('remaining_quantity', TLocalizationManager.Translate(TLangKeys.TPurRequestDetail.ColRemainingQuantity, 'Remaining Quantity'));
  SetColumnTitle('request_status', TLocalizationManager.Translate(TLangKeys.TPurRequestDetail.ColRequestStatus, 'Status'));
end;

end.
