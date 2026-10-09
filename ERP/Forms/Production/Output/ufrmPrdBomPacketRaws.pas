unit ufrmPrdBomPacketRaws;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  PrdBomPacketRaw.Service, PrdBomPacketRaw, ufrmPrdBomPacketRaw;

type
  TfrmPrdBomPacketRaws = class(TfrmGrid<TPrdBomPacketRaw, TPrdBomPacketRawService>)
  private
    FFixedMasterId: Int64;
    FFixedMasterName: string;
  public
    procedure SetFixedBom(AMasterId: Int64; const AMasterName: string);

    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure SetSelectedItem; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

procedure TfrmPrdBomPacketRaws.SetFixedBom(AMasterId: Int64; const AMasterName: string);
begin
  FFixedMasterId := AMasterId;
  FFixedMasterName := AMasterName;
  AddFixedFilter('prd_bom_id', AMasterId);
end;

function TfrmPrdBomPacketRaws.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
var
  LNew: TPrdBomPacketRaw;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmPrdBomPacketRaw.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
  begin
    LNew := TPrdBomPacketRaw.Create;
    if FFixedMasterId > 0 then
    begin
      LNew.PrdBomId := FFixedMasterId;
      LNew.BomName := FFixedMasterName;
    end;
    Result := TfrmPrdBomPacketRaw.Create(Self, Service, LNew, AFormMode, Self.RefreshParentGrid);
  end
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmPrdBomPacketRaw.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmPrdBomPacketRaws.SetSelectedItem;

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
  Table.BomName := FieldText('bom_name');
  Table.PacketName := FieldText('packet_name');
end;

procedure TfrmPrdBomPacketRaws.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('prd_bom_id', 0);
  SetColumnProperty('prd_packet_raw_id', 0);
end;

procedure TfrmPrdBomPacketRaws.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmPrdBomPacketRaws.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBomPacketRaw.TitlePlural, 'BoM Raw Material Packets');
  if FFixedMasterName <> '' then
    Self.Caption := Self.Caption + ' - ' + FFixedMasterName;
  SetColumnTitle('quantity', TLocalizationManager.Translate(TLangKeys.TPrdBomPacketRaw.ColQuantity, 'Quantity'));
  SetColumnTitle('bom_name', TLocalizationManager.Translate(TLangKeys.TPrdBomPacketRaw.ColBomName, 'BoM'));
  SetColumnTitle('packet_name', TLocalizationManager.Translate(TLangKeys.TPrdBomPacketRaw.ColPacketName, 'Raw Material Packet'));
end;

end.
