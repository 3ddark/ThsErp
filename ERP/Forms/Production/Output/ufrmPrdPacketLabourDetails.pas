unit ufrmPrdPacketLabourDetails;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  PrdPacketLabourDetail.Service, PrdPacketLabourDetail, ufrmPrdPacketLabourDetail;

type
  TfrmPrdPacketLabourDetails = class(TfrmGrid<TPrdPacketLabourDetail, TPrdPacketLabourDetailService>)
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

procedure TfrmPrdPacketLabourDetails.SetFixedPacket(AMasterId: Int64; const AMasterName: string);
begin
  FFixedMasterId := AMasterId;
  FFixedMasterName := AMasterName;
  AddFixedFilter('prd_packet_labour_id', AMasterId);
end;

function TfrmPrdPacketLabourDetails.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
var
  LNew: TPrdPacketLabourDetail;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmPrdPacketLabourDetail.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
  begin
    LNew := TPrdPacketLabourDetail.Create;
    if FFixedMasterId > 0 then
    begin
      LNew.PrdPacketLabourId := FFixedMasterId;
      LNew.PacketName := FFixedMasterName;
    end;
    Result := TfrmPrdPacketLabourDetail.Create(Self, Service, LNew, AFormMode, Self.RefreshParentGrid);
  end
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmPrdPacketLabourDetail.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmPrdPacketLabourDetails.SetSelectedItem;

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
  Table.LabourCode := FieldText('labour_code');
  Table.LabourName := FieldText('labour_name');
  Table.UnitPrice := FieldText('unit_price');
  Table.Currency := FieldText('currency');
  Table.TotalAmount := FieldText('total_amount');
end;

procedure TfrmPrdPacketLabourDetails.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('prd_packet_labour_id', 0);
  SetColumnProperty('prd_labour_id', 0);
end;

procedure TfrmPrdPacketLabourDetails.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmPrdPacketLabourDetails.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TPrdPacketLabourDetail.TitlePlural, 'Labour Packet Items');
  if FFixedMasterName <> '' then
    Self.Caption := Self.Caption + ' - ' + FFixedMasterName;
  SetColumnTitle('quantity', TLocalizationManager.Translate(TLangKeys.TPrdPacketLabourDetail.ColQuantity, 'Quantity'));
  SetColumnTitle('packet_name', TLocalizationManager.Translate(TLangKeys.TPrdPacketLabourDetail.ColPacketName, 'Packet'));
  SetColumnTitle('labour_code', TLocalizationManager.Translate(TLangKeys.TPrdPacketLabourDetail.ColLabourCode, 'Labour Code'));
  SetColumnTitle('labour_name', TLocalizationManager.Translate(TLangKeys.TPrdPacketLabourDetail.ColLabourName, 'Labour / Cost'));
  SetColumnTitle('unit_price', TLocalizationManager.Translate(TLangKeys.TPrdPacketLabourDetail.ColUnitPrice, 'Unit Price'));
  SetColumnTitle('currency', TLocalizationManager.Translate(TLangKeys.TPrdPacketLabourDetail.ColCurrency, 'Currency'));
  SetColumnTitle('total_amount', TLocalizationManager.Translate(TLangKeys.TPrdPacketLabourDetail.ColTotalAmount, 'Total Amount'));
end;

end.
