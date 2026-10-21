unit ufrmPrdPacketLabours;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  PrdPacketLabour.Service, PrdPacketLabour, ufrmPrdPacketLabourDetail;

type
  TfrmPrdPacketLabours = class(TfrmGrid<TPrdPacketLabour, TPrdPacketLabourService>)
  public

    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure SetSelectedItem; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

function TfrmPrdPacketLabours.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmPrdPacketLabourDetail.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmPrdPacketLabourDetail.Create(Self, Service, TPrdPacketLabour.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmPrdPacketLabourDetail.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmPrdPacketLabours.SetSelectedItem;

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

procedure TfrmPrdPacketLabours.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);
end;

procedure TfrmPrdPacketLabours.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmPrdPacketLabours.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TPrdPacketLabour.TitlePlural, 'Labour Packets');
  SetColumnTitle('packet_name', TLocalizationManager.Translate(TLangKeys.TPrdPacketLabour.ColPacketName, 'Packet Name'));
  SetColumnTitle('item_count', TLocalizationManager.Translate(TLangKeys.TPrdPacketLabour.ColItemCount, 'Item Count'));
end;

end.
