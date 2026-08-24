unit ufrmStkInventorySummaries;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, StkInventorySummary.Service, StkInventorySummary, ufrmStkInventorySummary,
  LocalizationManager;

type
  TfrmStkInventorySummaries = class(TfrmGrid<TStkInventorySummary, TStkInventorySummaryService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
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
  inherited;
  SetColumnProperty('id',                     0, TLocalizationManager.Translate('stk_inventory_summary.col_id', 'Id'));
  SetColumnProperty('inventory_id',             0, TLocalizationManager.Translate('stk_inventory_summary.col_inventory_id', 'Inventory Id'));
  SetColumnProperty('current_quantity',        90, TLocalizationManager.Translate('stk_inventory_summary.col_current_quantity', 'Current Qty'));
  SetColumnProperty('average_cost',            80, TLocalizationManager.Translate('stk_inventory_summary.col_average_cost', 'Avg Cost'));
  SetColumnProperty('opening_price',           80, TLocalizationManager.Translate('stk_inventory_summary.col_opening_price', 'Opening Price'));
  SetColumnProperty('opening_quantity',        90, TLocalizationManager.Translate('stk_inventory_summary.col_opening_quantity', 'Opening Qty'));
  SetColumnProperty('opening_amount',          90, TLocalizationManager.Translate('stk_inventory_summary.col_opening_amount', 'Opening Amt'));
  SetColumnProperty('incoming_quantity',       90, TLocalizationManager.Translate('stk_inventory_summary.col_incoming_quantity', 'Incoming Qty'));
  SetColumnProperty('incoming_amount',         90, TLocalizationManager.Translate('stk_inventory_summary.col_incoming_amount', 'Incoming Amt'));
  SetColumnProperty('outgoing_quantity',       90, TLocalizationManager.Translate('stk_inventory_summary.col_outgoing_quantity', 'Outgoing Qty'));
  SetColumnProperty('outgoing_amount',         90, TLocalizationManager.Translate('stk_inventory_summary.col_outgoing_amount', 'Outgoing Amt'));
  SetColumnProperty('last_buy_price',          80, TLocalizationManager.Translate('stk_inventory_summary.col_last_buy_price', 'Last Buy Price'));
  SetColumnProperty('last_buy_money',          60, TLocalizationManager.Translate('stk_inventory_summary.col_last_buy_money', 'Buy Curr'));
  SetColumnProperty('last_buy_date',           80, TLocalizationManager.Translate('stk_inventory_summary.col_last_buy_date', 'Last Buy Date'));
  SetColumnProperty('last_buy_quantity',       90, TLocalizationManager.Translate('stk_inventory_summary.col_last_buy_quantity', 'Last Buy Qty'));
  SetColumnProperty('last_buy_exchange_rate', 100, TLocalizationManager.Translate('stk_inventory_summary.col_last_buy_exchange_rate', 'Last Buy ExR'));
end;

procedure TfrmStkInventorySummaries.DefineFooterColumns;
begin
  inherited;
  AddFooterColumn('id', atCount, '#,##0');
end;

procedure TfrmStkInventorySummaries.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmStkInventorySummaries.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate('stk_inventory_summary.title_plural', 'Stock Inventory Summaries');
end;

end.
