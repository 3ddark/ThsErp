unit ufrmPrdPacketRaws;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  PrdPacketRaw.Service, PrdPacketRaw, ufrmPrdPacketRaw;

type
  TfrmPrdPacketRaws = class(TfrmGrid<TPrdPacketRaw, TPrdPacketRawService>)
  private
    FmniDetails: TMenuItem;
    procedure mniDetailsClick(Sender: TObject);
  public
    procedure PreparePopupMenu; override;

    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure SetSelectedItem; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  ufrmPrdPacketRawDetails, PrdPacketRawDetail, PrdPacketRawDetail.Service;

procedure TfrmPrdPacketRaws.mniDetailsClick(Sender: TObject);
var
  LFrm: TfrmPrdPacketRawDetails;
begin
  if Grd.DataSource.DataSet.IsEmpty then
    Exit;

  SetSelectedItem;
  LFrm := TfrmPrdPacketRawDetails.Create(Self, TPrdPacketRawDetailService.Create, TPrdPacketRawDetail.Create);
  LFrm.SetFixedPacket(Table.Id, Table.PacketName);
  LFrm.Show;
end;

procedure TfrmPrdPacketRaws.PreparePopupMenu;
begin
  inherited;
  if IsHelper then
    Exit;

  AddPopupMenuSpliter();
  FmniDetails := AddMenu(TLocalizationManager.Translate(TLangKeys.TPrdPacketRaw.MenuDetails, 'Packet Contents'), 'mniDetails', mniDetailsClick);
end;

function TfrmPrdPacketRaws.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmPrdPacketRaw.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmPrdPacketRaw.Create(Self, Service, TPrdPacketRaw.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmPrdPacketRaw.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmPrdPacketRaws.SetSelectedItem;

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
  Table.ItemCount := FieldText('item_count');
end;

procedure TfrmPrdPacketRaws.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);
end;

procedure TfrmPrdPacketRaws.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmPrdPacketRaws.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TPrdPacketRaw.TitlePlural, 'Raw Material Packets');
  if Assigned(FmniDetails) then
    FmniDetails.Caption := TLocalizationManager.Translate(TLangKeys.TPrdPacketRaw.MenuDetails, 'Packet Contents');
  SetColumnTitle('packet_name', TLocalizationManager.Translate(TLangKeys.TPrdPacketRaw.ColPacketName, 'Packet Name'));
  SetColumnTitle('item_count', TLocalizationManager.Translate(TLangKeys.TPrdPacketRaw.ColItemCount, 'Item Count'));
end;

end.
