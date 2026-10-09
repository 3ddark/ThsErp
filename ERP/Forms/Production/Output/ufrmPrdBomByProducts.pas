unit ufrmPrdBomByProducts;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  PrdBomByProduct.Service, PrdBomByProduct, ufrmPrdBomByProduct;

type
  TfrmPrdBomByProducts = class(TfrmGrid<TPrdBomByProduct, TPrdBomByProductService>)
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

procedure TfrmPrdBomByProducts.SetFixedBom(AMasterId: Int64; const AMasterName: string);
begin
  FFixedMasterId := AMasterId;
  FFixedMasterName := AMasterName;
  AddFixedFilter('prd_bom_id', AMasterId);
end;

function TfrmPrdBomByProducts.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
var
  LNew: TPrdBomByProduct;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmPrdBomByProduct.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
  begin
    LNew := TPrdBomByProduct.Create;
    if FFixedMasterId > 0 then
    begin
      LNew.PrdBomId := FFixedMasterId;
      LNew.BomName := FFixedMasterName;
    end;
    Result := TfrmPrdBomByProduct.Create(Self, Service, LNew, AFormMode, Self.RefreshParentGrid);
  end
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmPrdBomByProduct.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmPrdBomByProducts.SetSelectedItem;

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
end;

procedure TfrmPrdBomByProducts.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('prd_bom_id', 0);
  SetColumnProperty('stk_inventory_id', 0);
end;

procedure TfrmPrdBomByProducts.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmPrdBomByProducts.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBomByProduct.TitlePlural, 'BoM By-Products');
  if FFixedMasterName <> '' then
    Self.Caption := Self.Caption + ' - ' + FFixedMasterName;
  SetColumnTitle('quantity', TLocalizationManager.Translate(TLangKeys.TPrdBomByProduct.ColQuantity, 'Quantity'));
  SetColumnTitle('bom_name', TLocalizationManager.Translate(TLangKeys.TPrdBomByProduct.ColBomName, 'BoM'));
  SetColumnTitle('inventory_code', TLocalizationManager.Translate(TLangKeys.TPrdBomByProduct.ColInventoryCode, 'Stock Code'));
  SetColumnTitle('inventory_name', TLocalizationManager.Translate(TLangKeys.TPrdBomByProduct.ColInventoryName, 'By-Product'));
end;

end.
