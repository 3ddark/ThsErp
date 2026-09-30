unit ufrmStkWarehouses;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  StkWarehouse.Service, StkWarehouse, ufrmStkWarehouse;

type
  TfrmStkWarehouses = class(TfrmGrid<TStkWarehouse, TStkWarehouseService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure SetSelectedItem; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

function TfrmStkWarehouses.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmStkWarehouse.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmStkWarehouse.Create(Self, Service, TStkWarehouse.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmStkWarehouse.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmStkWarehouses.SetSelectedItem;

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
end;

procedure TfrmStkWarehouses.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);
end;

procedure TfrmStkWarehouses.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmStkWarehouses.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TStkWarehouse.TitlePlural, 'Warehouses');
  SetColumnTitle('warehouse_name', TLocalizationManager.Translate(TLangKeys.TStkWarehouse.ColWarehouseName, 'Warehouse Name'));
  SetColumnTitle('default_raw_material', TLocalizationManager.Translate(TLangKeys.TStkWarehouse.ColDefaultRawMaterial, 'Default Raw Material'));
  SetColumnTitle('default_production', TLocalizationManager.Translate(TLangKeys.TStkWarehouse.ColDefaultProduction, 'Default Production'));
  SetColumnTitle('default_sales', TLocalizationManager.Translate(TLangKeys.TStkWarehouse.ColDefaultSales, 'Default Sales'));
end;

end.
