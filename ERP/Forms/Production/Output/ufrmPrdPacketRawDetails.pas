unit ufrmPrdPacketRawDetails;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  PrdPacketRawDetail.Service, PrdPacketRawDetail, ufrmPrdPacketRawDetail;

type
  TfrmPrdPacketRawDetails = class(TfrmGrid<TPrdPacketRawDetail, TPrdPacketRawDetailService>)
  private
    FFixedMasterId: Int64;
    FFixedMasterName: string;
  public
    procedure SetFixedPacket(AMasterId: Int64; const AMasterName: string);

    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure SetSelectedItem; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

procedure TfrmPrdPacketRawDetails.SetFixedPacket(AMasterId: Int64; const AMasterName: string);
begin
  FFixedMasterId := AMasterId;
  FFixedMasterName := AMasterName;
  AddFixedFilter('prd_packet_raw_id', AMasterId);
end;

function TfrmPrdPacketRawDetails.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
var
  LNew: TPrdPacketRawDetail;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmPrdPacketRawDetail.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
  begin
    LNew := TPrdPacketRawDetail.Create;
    if FFixedMasterId > 0 then
    begin
      LNew.PrdPacketRawId := FFixedMasterId;
      LNew.PacketName := FFixedMasterName;
    end;
    Result := TfrmPrdPacketRawDetail.Create(Self, Service, LNew, AFormMode, Self.RefreshParentGrid);
  end
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmPrdPacketRawDetail.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmPrdPacketRawDetails.SetSelectedItem;

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
  Table.PacketName := FieldText('packet_name');
  Table.InventoryCode := FieldText('inventory_code');
  Table.InventoryName := FieldText('inventory_name');
  Table.SubBomName := FieldText('sub_bom_name');
end;

procedure TfrmPrdPacketRawDetails.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('prd_packet_raw_id', 0);
  SetColumnProperty('stk_inventory_id', 0);
  SetColumnProperty('sub_prd_bom_id', 0);
end;

procedure TfrmPrdPacketRawDetails.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmPrdPacketRawDetails.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TPrdPacketRawDetail.TitlePlural, 'Raw Material Packet Items');
  if FFixedMasterName <> '' then
    Self.Caption := Self.Caption + ' - ' + FFixedMasterName;
  SetColumnTitle('quantity', TLocalizationManager.Translate(TLangKeys.TPrdPacketRawDetail.ColQuantity, 'Quantity'));
  SetColumnTitle('packet_name', TLocalizationManager.Translate(TLangKeys.TPrdPacketRawDetail.ColPacketName, 'Packet'));
  SetColumnTitle('inventory_code', TLocalizationManager.Translate(TLangKeys.TPrdPacketRawDetail.ColInventoryCode, 'Stock Code'));
  SetColumnTitle('inventory_name', TLocalizationManager.Translate(TLangKeys.TPrdPacketRawDetail.ColInventoryName, 'Raw Material'));
  SetColumnTitle('sub_bom_name', TLocalizationManager.Translate(TLangKeys.TPrdPacketRawDetail.ColSubBomName, 'Sub BoM (Semi-Product)'));
end;

end.
