unit ufrmStkKartlar;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, StkInventoryService, StkInventory, ufrmStkKart;

type
  TfrmStkKartlar = class(TfrmGrid<TStkInventory, TStkInventoryService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
  end;

implementation

{$R *.dfm}

function TfrmStkKartlar.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmStkKart.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmStkKart.Create(Self, Service, TStkInventory.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmStkKart.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmStkKartlar.DefineColumnWidths;
begin
  SetColumnProperty('id',                          0, 'Id');
  SetColumnProperty('stk_kodu',                  80, 'Stock Code');
  SetColumnProperty('stk_adi',                   200, 'Stock Name');
  SetColumnProperty('group_id',                    0, 'Group Id');
  SetColumnProperty('measurement_id',              0, 'UoM Id');
  SetColumnProperty('product_type',               80, 'Product Type');
  SetColumnProperty('buying_discount',            60, 'Buy Disc %');
  SetColumnProperty('sales_discount',             60, 'Sale Disc %');
  SetColumnProperty('buying_price',              100, 'Buying Price');
  SetColumnProperty('buying_currency',            50, 'Buy Curr');
  SetColumnProperty('sales_price',               100, 'Sales Price');
  SetColumnProperty('sales_currency',             50, 'Sale Curr');
  SetColumnProperty('export_price',              100, 'Export Price');
  SetColumnProperty('export_currency',            50, 'Exp Curr');
  SetColumnProperty('width',                      60, 'Width');
  SetColumnProperty('length',                     60, 'Length');
  SetColumnProperty('height',                     60, 'Height');
  SetColumnProperty('weight',                     60, 'Weight');
  SetColumnProperty('supply_duration',            60, 'Supply Days');
  SetColumnProperty('special_code',               80, 'Special Code');
  SetColumnProperty('brand',                      80, 'Brand');
end;

procedure TfrmStkKartlar.DefineFooterColumns;
begin
  AddFooterColumn('id', atCount, '#,##0');
end;

procedure TfrmStkKartlar.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'Stock Cards';
end;

end.
