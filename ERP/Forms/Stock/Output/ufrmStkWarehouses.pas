unit ufrmStkWarehouses;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, StkWarehouse.Service, StkWarehouse, ufrmStkWarehouse,
  LocalizationManager;

type
  TfrmStkWarehouses = class(TfrmGrid<TStkWarehouse, TStkWarehouseService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
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
    Result := TfrmStkWarehouse.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmStkWarehouse.Create(Self, Service, TStkWarehouse.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmStkWarehouse.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmStkWarehouses.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id',                    0, TLocalizationManager.Translate('stk_warehouse.col_id', 'Id'));
  SetColumnProperty('warehouse_name',      150, TLocalizationManager.Translate('stk_warehouse.col_warehouse_name', 'Warehouse Name'));
  SetColumnProperty('default_raw_material', 80, TLocalizationManager.Translate('stk_warehouse.col_default_raw_material', 'Default RM'));
  SetColumnProperty('default_production',   80, TLocalizationManager.Translate('stk_warehouse.col_default_production', 'Default Production'));
  SetColumnProperty('default_sales',        70, TLocalizationManager.Translate('stk_warehouse.col_default_sales', 'Default Sales'));
end;

procedure TfrmStkWarehouses.DefineFooterColumns;
begin
  inherited;
  AddFooterColumn('id', atCount, '#,##0');
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
  Self.Caption := TLocalizationManager.Translate('stk_warehouse.title_plural', 'Stock Warehouses');
end;

end.
