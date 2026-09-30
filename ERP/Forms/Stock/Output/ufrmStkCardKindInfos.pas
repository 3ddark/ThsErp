unit ufrmStkCardKindInfos;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  StkCardKindInfo.Service, StkCardKindInfo, ufrmStkCardKindInfo;

type
  TfrmStkCardKindInfos = class(TfrmGrid<TStkCardKindInfo, TStkCardKindInfoService>)
  private
    FFixedInventoryId: Int64;
    FFixedInventoryName: string;
  public
    procedure SetFixedInventory(AInventoryId: Int64; const AInventoryName: string);

    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure SetSelectedItem; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

procedure TfrmStkCardKindInfos.SetFixedInventory(AInventoryId: Int64; const AInventoryName: string);
begin
  FFixedInventoryId := AInventoryId;
  FFixedInventoryName := AInventoryName;
  AddFixedFilter('stk_inventory_id', AInventoryId);
end;

function TfrmStkCardKindInfos.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
var
  LNew: TStkCardKindInfo;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmStkCardKindInfo.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
  begin
    LNew := TStkCardKindInfo.Create;
    if FFixedInventoryId > 0 then
    begin
      LNew.StkInventoryId := FFixedInventoryId;
      LNew.InventoryName := FFixedInventoryName;
    end;
    Result := TfrmStkCardKindInfo.Create(Self, Service, LNew, AFormMode, Self.RefreshParentGrid);
  end
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmStkCardKindInfo.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmStkCardKindInfos.SetSelectedItem;

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
  Table.InventoryName := FieldText('inventory_name');
  Table.KindName := FieldText('kind_name');
  Table.InventoryCode := FieldText('inventory_code');
end;

procedure TfrmStkCardKindInfos.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('stk_inventory_id', 0);
  SetColumnProperty('stk_kind_property_id', 0);
end;

procedure TfrmStkCardKindInfos.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmStkCardKindInfos.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TStkCardKindInfo.TitlePlural, 'Stock Kind Information');
  if FFixedInventoryName <> '' then
    Self.Caption := Self.Caption + ' - ' + FFixedInventoryName;
  SetColumnTitle('inventory_name', TLocalizationManager.Translate(TLangKeys.TStkCardKindInfo.ColInventory, 'Stock Card'));
  SetColumnTitle('kind_name', TLocalizationManager.Translate(TLangKeys.TStkCardKindInfo.ColKind, 'Kind'));
  SetColumnTitle('s1', TLocalizationManager.Translate(TLangKeys.TStkCardKindInfo.ColS1, 'Text 1'));
  SetColumnTitle('s2', TLocalizationManager.Translate(TLangKeys.TStkCardKindInfo.ColS2, 'Text 2'));
  SetColumnTitle('s3', TLocalizationManager.Translate(TLangKeys.TStkCardKindInfo.ColS3, 'Text 3'));
  SetColumnTitle('s4', TLocalizationManager.Translate(TLangKeys.TStkCardKindInfo.ColS4, 'Text 4'));
  SetColumnTitle('s5', TLocalizationManager.Translate(TLangKeys.TStkCardKindInfo.ColS5, 'Text 5'));
  SetColumnTitle('s6', TLocalizationManager.Translate(TLangKeys.TStkCardKindInfo.ColS6, 'Text 6'));
  SetColumnTitle('s7', TLocalizationManager.Translate(TLangKeys.TStkCardKindInfo.ColS7, 'Text 7'));
  SetColumnTitle('s8', TLocalizationManager.Translate(TLangKeys.TStkCardKindInfo.ColS8, 'Text 8'));
  SetColumnTitle('s9', TLocalizationManager.Translate(TLangKeys.TStkCardKindInfo.ColS9, 'Text 9'));
  SetColumnTitle('s10', TLocalizationManager.Translate(TLangKeys.TStkCardKindInfo.ColS10, 'Text 10'));
  SetColumnTitle('i1', TLocalizationManager.Translate(TLangKeys.TStkCardKindInfo.ColI1, 'Integer 1'));
  SetColumnTitle('i2', TLocalizationManager.Translate(TLangKeys.TStkCardKindInfo.ColI2, 'Integer 2'));
  SetColumnTitle('i3', TLocalizationManager.Translate(TLangKeys.TStkCardKindInfo.ColI3, 'Integer 3'));
  SetColumnTitle('i4', TLocalizationManager.Translate(TLangKeys.TStkCardKindInfo.ColI4, 'Integer 4'));
  SetColumnTitle('i5', TLocalizationManager.Translate(TLangKeys.TStkCardKindInfo.ColI5, 'Integer 5'));
  SetColumnTitle('d1', TLocalizationManager.Translate(TLangKeys.TStkCardKindInfo.ColD1, 'Decimal 1'));
  SetColumnTitle('d2', TLocalizationManager.Translate(TLangKeys.TStkCardKindInfo.ColD2, 'Decimal 2'));
  SetColumnTitle('d3', TLocalizationManager.Translate(TLangKeys.TStkCardKindInfo.ColD3, 'Decimal 3'));
  SetColumnTitle('d4', TLocalizationManager.Translate(TLangKeys.TStkCardKindInfo.ColD4, 'Decimal 4'));
  SetColumnTitle('d5', TLocalizationManager.Translate(TLangKeys.TStkCardKindInfo.ColD5, 'Decimal 5'));
  SetColumnTitle('inventory_code', TLocalizationManager.Translate(TLangKeys.TStkCardKindInfo.ColInventoryCode, 'Stock Code'));
end;

end.
