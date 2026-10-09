unit ufrmPrdBomRaws;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  PrdBomRaw.Service, PrdBomRaw, ufrmPrdBomRaw;

type
  TfrmPrdBomRaws = class(TfrmGrid<TPrdBomRaw, TPrdBomRawService>)
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

procedure TfrmPrdBomRaws.SetFixedBom(AMasterId: Int64; const AMasterName: string);
begin
  FFixedMasterId := AMasterId;
  FFixedMasterName := AMasterName;
  AddFixedFilter('prd_bom_id', AMasterId);
end;

function TfrmPrdBomRaws.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
var
  LNew: TPrdBomRaw;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmPrdBomRaw.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
  begin
    LNew := TPrdBomRaw.Create;
    if FFixedMasterId > 0 then
    begin
      LNew.PrdBomId := FFixedMasterId;
      LNew.BomName := FFixedMasterName;
    end;
    Result := TfrmPrdBomRaw.Create(Self, Service, LNew, AFormMode, Self.RefreshParentGrid);
  end
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmPrdBomRaw.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmPrdBomRaws.SetSelectedItem;

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
  Table.InventoryCode := FieldText('inventory_code');
  Table.InventoryName := FieldText('inventory_name');
  Table.SubBomName := FieldText('sub_bom_name');
  Table.GrossQuantity := FieldText('gross_quantity');
end;

procedure TfrmPrdBomRaws.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('prd_bom_id', 0);
  SetColumnProperty('stk_inventory_id', 0);
  SetColumnProperty('sub_prd_bom_id', 0);
end;

procedure TfrmPrdBomRaws.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmPrdBomRaws.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBomRaw.TitlePlural, 'BoM Raw Materials');
  if FFixedMasterName <> '' then
    Self.Caption := Self.Caption + ' - ' + FFixedMasterName;
  SetColumnTitle('quantity', TLocalizationManager.Translate(TLangKeys.TPrdBomRaw.ColQuantity, 'Quantity'));
  SetColumnTitle('scrap_rate', TLocalizationManager.Translate(TLangKeys.TPrdBomRaw.ColScrapRate, 'Scrap Rate (%)'));
  SetColumnTitle('bom_name', TLocalizationManager.Translate(TLangKeys.TPrdBomRaw.ColBomName, 'BoM'));
  SetColumnTitle('inventory_code', TLocalizationManager.Translate(TLangKeys.TPrdBomRaw.ColInventoryCode, 'Stock Code'));
  SetColumnTitle('inventory_name', TLocalizationManager.Translate(TLangKeys.TPrdBomRaw.ColInventoryName, 'Raw Material'));
  SetColumnTitle('sub_bom_name', TLocalizationManager.Translate(TLangKeys.TPrdBomRaw.ColSubBomName, 'Sub BoM (Semi-Product)'));
  SetColumnTitle('gross_quantity', TLocalizationManager.Translate(TLangKeys.TPrdBomRaw.ColGrossQuantity, 'Gross Quantity'));
end;

end.
