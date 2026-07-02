unit ufrmStkInventorySummaries;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, StkInventorySummaryService, StkInventorySummary, ufrmStkInventorySummary;

type
  TfrmStkInventorySummaries = class(TfrmGrid<TStkInventorySummary, TStkInventorySummaryService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
  end;

implementation

{$R *.dfm}

function TfrmStkInventorySummaries.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmStkInventorySummary.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmStkInventorySummary.Create(Self, Service, TStkInventorySummary.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmStkInventorySummary.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmStkInventorySummaries.DefineColumnWidths;
begin
  SetColumnProperty('id',                     0, 'Id');
  SetColumnProperty('inventory_id',             0, 'Inventory Id');
  SetColumnProperty('current_quantity',        90, 'Current Qty');
  SetColumnProperty('average_cost',            80, 'Avg Cost');
  SetColumnProperty('opening_price',           80, 'Opening Price');
  SetColumnProperty('opening_quantity',        90, 'Opening Qty');
  SetColumnProperty('opening_amount',          90, 'Opening Amt');
  SetColumnProperty('incoming_quantity',       90, 'Incoming Qty');
  SetColumnProperty('incoming_amount',         90, 'Incoming Amt');
  SetColumnProperty('outgoing_quantity',       90, 'Outgoing Qty');
  SetColumnProperty('outgoing_amount',         90, 'Outgoing Amt');
  SetColumnProperty('last_buy_price',          80, 'Last Buy Price');
  SetColumnProperty('last_buy_money',          60, 'Buy Curr');
  SetColumnProperty('last_buy_date',           80, 'Last Buy Date');
  SetColumnProperty('last_buy_quantity',       90, 'Last Buy Qty');
  SetColumnProperty('last_buy_exchange_rate', 100, 'Last Buy ExR');
end;

procedure TfrmStkInventorySummaries.DefineFooterColumns;
begin
  AddFooterColumn('id', atCount, '#,##0');
end;

procedure TfrmStkInventorySummaries.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'Stock Inventory Summaries';
end;

end.
