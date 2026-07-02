unit ufrmStkInventorySummary;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.DBCtrls, ufrmInputSimpleDbX, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  StkInventorySummaryService, StkInventorySummary;

type
  TfrmStkInventorySummary = class(TfrmInputSimpleDbX<TStkInventorySummary, TStkInventorySummaryService>)
    pgcMain: TPageControl;
    tsMain: TTabSheet;
    lblinventory_id: TLabel;
    edtinventory_id: TEdit;
    lblcurrent_quantity: TLabel;
    edtcurrent_quantity: TMaskEdit;
    lblaverage_cost: TLabel;
    edtaverage_cost: TMaskEdit;
    lblopening_price: TLabel;
    edtopening_price: TMaskEdit;
    lblopening_quantity: TLabel;
    edtopening_quantity: TMaskEdit;
    lblopening_amount: TLabel;
    edtopening_amount: TMaskEdit;
    lblincoming_quantity: TLabel;
    edtincoming_quantity: TMaskEdit;
    lblincoming_amount: TLabel;
    edtincoming_amount: TMaskEdit;
    lbloutgoing_quantity: TLabel;
    edtoutgoing_quantity: TMaskEdit;
    lbloutgoing_amount: TLabel;
    edtoutgoing_amount: TMaskEdit;
    lbllast_buy_price: TLabel;
    edtlast_buy_price: TMaskEdit;
    lbllast_buy_money: TLabel;
    edtlast_buy_money: TEdit;
    lbllast_buy_date: TLabel;
    edtlast_buy_date: TDateTimePicker;
    lbllast_buy_quantity: TLabel;
    edtlast_buy_quantity: TMaskEdit;
    lbllast_buy_exchange_rate: TLabel;
    edtlast_buy_exchange_rate: TMaskEdit;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  published
    procedure BtnAcceptClick(Sender: TObject); override;

  public
    procedure RefreshData; override;
    procedure InitializeInputCase; override;
  end;

implementation

{$R *.dfm}

procedure TfrmStkInventorySummary.BtnAcceptClick(Sender: TObject);
begin
  Table.InventoryId.Value := StrToInt64Def(edtinventory_id.Text, 0);
  Table.CurrentQuantity.Value := edtcurrent_quantity.asFloat;
  Table.AverageCost.Value := edtaverage_cost.asFloat;
  Table.OpeningPrice.Value := edtopening_price.asFloat;
  Table.OpeningQuantity.Value := edtopening_quantity.asFloat;
  Table.OpeningAmount.Value := edtopening_amount.asFloat;
  Table.IncomingQuantity.Value := edtincoming_quantity.asFloat;
  Table.IncomingAmount.Value := edtincoming_amount.asFloat;
  Table.OutgoingQuantity.Value := edtoutgoing_quantity.asFloat;
  Table.OutgoingAmount.Value := edtoutgoing_amount.asFloat;
  if edtlast_buy_price.Text <> '' then
    Table.LastBuyPrice.Value := edtlast_buy_price.asFloat;
  Table.LastBuyMoney.Value := edtlast_buy_money.Text;
  if Assigned(edtlast_buy_date.DateTime) then
    Table.LastBuyDate.Value := edtlast_buy_date.Date;
  if edtlast_buy_quantity.Text <> '' then
    Table.LastBuyQuantity.Value := edtlast_buy_quantity.asFloat;
  if edtlast_buy_exchange_rate.Text <> '' then
    Table.LastBuyExchangeRate.Value := edtlast_buy_exchange_rate.asFloat;
  inherited;
end;

procedure TfrmStkInventorySummary.FormCreate(Sender: TObject);
begin
  inherited;
  pgcMain.Parent := PanelMain;
  PgcBase := pgcMain;
end;

procedure TfrmStkInventorySummary.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'Input Stk Inventory Summary';
  edtinventory_id.SetFocus;
end;

procedure TfrmStkInventorySummary.InitializeInputCase;
begin
  inherited;
end;

procedure TfrmStkInventorySummary.RefreshData;
begin
  inherited;
  edtinventory_id.Text := IntToStr(Table.InventoryId.Value);
  edtcurrent_quantity.Text := FormatFloat('0.000000', Table.CurrentQuantity.Value);
  edtaverage_cost.Text := FormatFloat('0.00', Table.AverageCost.Value);
  edtopening_price.Text := FormatFloat('0.00', Table.OpeningPrice.Value);
  edtopening_quantity.Text := FormatFloat('0.000000', Table.OpeningQuantity.Value);
  edtopening_amount.Text := FormatFloat('0.00', Table.OpeningAmount.Value);
  edtincoming_quantity.Text := FormatFloat('0.000000', Table.IncomingQuantity.Value);
  edtincoming_amount.Text := FormatFloat('0.00', Table.IncomingAmount.Value);
  edtoutgoing_quantity.Text := FormatFloat('0.000000', Table.OutgoingQuantity.Value);
  edtoutgoing_amount.Text := FormatFloat('0.00', Table.OutgoingAmount.Value);
  if not VarIsNull(Table.LastBuyPrice.Value) then
    edtlast_buy_price.Text := FormatFloat('0.00', Table.LastBuyPrice.Value);
  edtlast_buy_money.Text := Table.LastBuyMoney.Value;
  if not VarIsNull(Table.LastBuyDate.Value) then
    edtlast_buy_date.Date := DateOf(Table.LastBuyDate.Value);
  if not VarIsNull(Table.LastBuyQuantity.Value) then
    edtlast_buy_quantity.Text := FormatFloat('0.000000', Table.LastBuyQuantity.Value);
  if not VarIsNull(Table.LastBuyExchangeRate.Value) then
    edtlast_buy_exchange_rate.Text := FormatFloat('0.00', Table.LastBuyExchangeRate.Value);
end;

end.
