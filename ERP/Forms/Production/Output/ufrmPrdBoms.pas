unit ufrmPrdBoms;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  PrdBom.Service, PrdBom, ufrmPrdBom;

type
  TfrmPrdBoms = class(TfrmGrid<TPrdBom, TPrdBomService>)
  private
    FmniRaws: TMenuItem;
    FmniByProducts: TMenuItem;
    FmniLabours: TMenuItem;
    FmniPacketRaws: TMenuItem;
    FmniPacketLabours: TMenuItem;
    procedure mniRawsClick(Sender: TObject);
    procedure mniByProductsClick(Sender: TObject);
    procedure mniLaboursClick(Sender: TObject);
    procedure mniPacketRawsClick(Sender: TObject);
    procedure mniPacketLaboursClick(Sender: TObject);
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
  ufrmPrdBomRaws, PrdBomRaw, PrdBomRaw.Service,
  ufrmPrdBomByProducts, PrdBomByProduct, PrdBomByProduct.Service,
  ufrmPrdBomLabours, PrdBomLabour, PrdBomLabour.Service,
  ufrmPrdBomPacketRaws, PrdBomPacketRaw, PrdBomPacketRaw.Service,
  ufrmPrdBomPacketLabours, PrdBomPacketLabour, PrdBomPacketLabour.Service;

procedure TfrmPrdBoms.mniRawsClick(Sender: TObject);
var
  LFrm: TfrmPrdBomRaws;
begin
  if Grd.DataSource.DataSet.IsEmpty then
    Exit;

  SetSelectedItem;
  LFrm := TfrmPrdBomRaws.Create(Self, TPrdBomRawService.Create, TPrdBomRaw.Create);
  LFrm.SetFixedBom(Table.Id, Table.InventoryCode + ' / ' + Table.BomName);
  LFrm.Show;
end;

procedure TfrmPrdBoms.mniByProductsClick(Sender: TObject);
var
  LFrm: TfrmPrdBomByProducts;
begin
  if Grd.DataSource.DataSet.IsEmpty then
    Exit;

  SetSelectedItem;
  LFrm := TfrmPrdBomByProducts.Create(Self, TPrdBomByProductService.Create, TPrdBomByProduct.Create);
  LFrm.SetFixedBom(Table.Id, Table.InventoryCode + ' / ' + Table.BomName);
  LFrm.Show;
end;

procedure TfrmPrdBoms.mniLaboursClick(Sender: TObject);
var
  LFrm: TfrmPrdBomLabours;
begin
  if Grd.DataSource.DataSet.IsEmpty then
    Exit;

  SetSelectedItem;
  LFrm := TfrmPrdBomLabours.Create(Self, TPrdBomLabourService.Create, TPrdBomLabour.Create);
  LFrm.SetFixedBom(Table.Id, Table.InventoryCode + ' / ' + Table.BomName);
  LFrm.Show;
end;

procedure TfrmPrdBoms.mniPacketRawsClick(Sender: TObject);
var
  LFrm: TfrmPrdBomPacketRaws;
begin
  if Grd.DataSource.DataSet.IsEmpty then
    Exit;

  SetSelectedItem;
  LFrm := TfrmPrdBomPacketRaws.Create(Self, TPrdBomPacketRawService.Create, TPrdBomPacketRaw.Create);
  LFrm.SetFixedBom(Table.Id, Table.InventoryCode + ' / ' + Table.BomName);
  LFrm.Show;
end;

procedure TfrmPrdBoms.mniPacketLaboursClick(Sender: TObject);
var
  LFrm: TfrmPrdBomPacketLabours;
begin
  if Grd.DataSource.DataSet.IsEmpty then
    Exit;

  SetSelectedItem;
  LFrm := TfrmPrdBomPacketLabours.Create(Self, TPrdBomPacketLabourService.Create, TPrdBomPacketLabour.Create);
  LFrm.SetFixedBom(Table.Id, Table.InventoryCode + ' / ' + Table.BomName);
  LFrm.Show;
end;

procedure TfrmPrdBoms.PreparePopupMenu;
begin
  inherited;
  if IsHelper then
    Exit;

  AddPopupMenuSpliter();
  FmniRaws := AddMenu(TLocalizationManager.Translate(TLangKeys.TPrdBom.MenuRaws, 'Raw Materials'), 'mniRaws', mniRawsClick);
  FmniByProducts := AddMenu(TLocalizationManager.Translate(TLangKeys.TPrdBom.MenuByProducts, 'By-Products'), 'mniByProducts', mniByProductsClick);
  FmniLabours := AddMenu(TLocalizationManager.Translate(TLangKeys.TPrdBom.MenuLabours, 'Labours / Costs'), 'mniLabours', mniLaboursClick);
  FmniPacketRaws := AddMenu(TLocalizationManager.Translate(TLangKeys.TPrdBom.MenuPacketRaws, 'Raw Material Packets'), 'mniPacketRaws', mniPacketRawsClick);
  FmniPacketLabours := AddMenu(TLocalizationManager.Translate(TLangKeys.TPrdBom.MenuPacketLabours, 'Labour Packets'), 'mniPacketLabours', mniPacketLaboursClick);
end;

function TfrmPrdBoms.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmPrdBom.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmPrdBom.Create(Self, Service, TPrdBom.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmPrdBom.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmPrdBoms.SetSelectedItem;

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
  Table.InventoryCode := FieldText('inventory_code');
  Table.InventoryName := FieldText('inventory_name');
  Table.RawCount := FieldText('raw_count');
  Table.LabourCount := FieldText('labour_count');
end;

procedure TfrmPrdBoms.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('stk_inventory_id', 0);
end;

procedure TfrmPrdBoms.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmPrdBoms.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBom.TitlePlural, 'BoMs');
  if Assigned(FmniRaws) then
    FmniRaws.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBom.MenuRaws, 'Raw Materials');
  if Assigned(FmniByProducts) then
    FmniByProducts.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBom.MenuByProducts, 'By-Products');
  if Assigned(FmniLabours) then
    FmniLabours.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBom.MenuLabours, 'Labours / Costs');
  if Assigned(FmniPacketRaws) then
    FmniPacketRaws.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBom.MenuPacketRaws, 'Raw Material Packets');
  if Assigned(FmniPacketLabours) then
    FmniPacketLabours.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBom.MenuPacketLabours, 'Labour Packets');
  SetColumnTitle('bom_name', TLocalizationManager.Translate(TLangKeys.TPrdBom.ColBomName, 'BoM Name'));
  SetColumnTitle('base_quantity', TLocalizationManager.Translate(TLangKeys.TPrdBom.ColBaseQuantity, 'Base Quantity'));
  SetColumnTitle('is_default', TLocalizationManager.Translate(TLangKeys.TPrdBom.ColIsDefault, 'Default BoM'));
  SetColumnTitle('is_active', TLocalizationManager.Translate(TLangKeys.TPrdBom.ColIsActive, 'Active'));
  SetColumnTitle('description', TLocalizationManager.Translate(TLangKeys.TPrdBom.ColDescription, 'Description'));
  SetColumnTitle('inventory_code', TLocalizationManager.Translate(TLangKeys.TPrdBom.ColInventoryCode, 'Stock Code'));
  SetColumnTitle('inventory_name', TLocalizationManager.Translate(TLangKeys.TPrdBom.ColInventoryName, 'Product'));
  SetColumnTitle('raw_count', TLocalizationManager.Translate(TLangKeys.TPrdBom.ColRawCount, 'Raw Materials'));
  SetColumnTitle('labour_count', TLocalizationManager.Translate(TLangKeys.TPrdBom.ColLabourCount, 'Labours'));
end;

end.
