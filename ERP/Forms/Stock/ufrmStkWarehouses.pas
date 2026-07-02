unit ufrmStkWarehouses;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, StkWarehouseService, StkWarehouse, ufrmStkWarehouse;

type
  TfrmStkWarehouses = class(TfrmGrid<TStkWarehouse, TStkWarehouseService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
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
  SetColumnProperty('id',                      0, 'Id');
  SetColumnProperty('warehouse_name',        150, 'Warehouse Name');
  SetColumnProperty('default_raw_material',   80, 'Default RM');
  SetColumnProperty('default_production',      80, 'Default Production');
  SetColumnProperty('default_sales',           70, 'Default Sales');
end;

procedure TfrmStkWarehouses.DefineFooterColumns;
begin
  AddFooterColumn('id', atCount, '#,##0');
end;

procedure TfrmStkWarehouses.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'Stock Warehouses';
end;

end.
