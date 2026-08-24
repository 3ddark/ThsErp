unit ufrmStkInventorySummary;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.DateUtils,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Mask,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.DBCtrls, ufrmInputSimpleDB, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  StkInventorySummary.Service, StkInventorySummary, LocalizationManager;

type
  TfrmStkInventorySummary = class(TfrmInputSimpleDB<TStkInventorySummary, TStkInventorySummaryService>)
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
    procedure BtnAcceptClick(Sender: TObject); override;
  public
    procedure RefreshData; override;
    procedure InitializeInputCase; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

procedure TfrmStkInventorySummary.BtnAcceptClick(Sender: TObject);
begin
  Table.InventoryID := StrToInt64Def(edtinventory_id.Text, 0);
  Table.CurrentQuantity := StrToCurrDef(edtcurrent_quantity.Text, 0);
  Table.AverageCost := StrToCurrDef(edtaverage_cost.Text, 0);
  Table.OpeningPrice := StrToCurrDef(edtopening_price.Text, 0);
  Table.OpeningQuantity := StrToCurrDef(edtopening_quantity.Text, 0);
  Table.OpeningAmount := StrToCurrDef(edtopening_amount.Text, 0);
  Table.IncomingQuantity := StrToCurrDef(edtincoming_quantity.Text, 0);
  Table.IncomingAmount := StrToCurrDef(edtincoming_amount.Text, 0);
  Table.OutgoingQuantity := StrToCurrDef(edtoutgoing_quantity.Text, 0);
  Table.OutgoingAmount := StrToCurrDef(edtoutgoing_amount.Text, 0);
  Table.LastBuyPrice := StrToCurrDef(edtlast_buy_price.Text, 0);
  Table.LastBuyMoney := edtlast_buy_money.Text;
  Table.LastBuyDate := edtlast_buy_date.Date;
  Table.LastBuyQuantity := StrToCurrDef(edtlast_buy_quantity.Text, 0);
  Table.LastBuyExchangeRate := StrToCurrDef(edtlast_buy_exchange_rate.Text, 0);
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
  ApplyLocalization;
  edtinventory_id.SetFocus;
end;

procedure TfrmStkInventorySummary.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate('stk_inventory_summary.title_singular', 'Stok Envanter Özeti');
  lblinventory_id.Caption := TLocalizationManager.Translate('stk_inventory_summary.lbl_inventory_id', 'Stok ID');
  lblcurrent_quantity.Caption := TLocalizationManager.Translate('stk_inventory_summary.lbl_current_quantity', 'Mevcut Miktar');
  lblaverage_cost.Caption := TLocalizationManager.Translate('stk_inventory_summary.lbl_average_cost', 'Ortalama Maliyet');
  lblopening_price.Caption := TLocalizationManager.Translate('stk_inventory_summary.lbl_opening_price', 'Açılış Fiyatı');
  lblopening_quantity.Caption := TLocalizationManager.Translate('stk_inventory_summary.lbl_opening_quantity', 'Açılış Miktarı');
  lblopening_amount.Caption := TLocalizationManager.Translate('stk_inventory_summary.lbl_opening_amount', 'Açılış Tutarı');
  lblincoming_quantity.Caption := TLocalizationManager.Translate('stk_inventory_summary.lbl_incoming_quantity', 'Giren Miktar');
  lblincoming_amount.Caption := TLocalizationManager.Translate('stk_inventory_summary.lbl_incoming_amount', 'Giren Tutar');
  lbloutgoing_quantity.Caption := TLocalizationManager.Translate('stk_inventory_summary.lbl_outgoing_quantity', 'Çıkan Miktar');
  lbloutgoing_amount.Caption := TLocalizationManager.Translate('stk_inventory_summary.lbl_outgoing_amount', 'Çıkan Tutar');
  lbllast_buy_price.Caption := TLocalizationManager.Translate('stk_inventory_summary.lbl_last_buy_price', 'Son Alış Fiyatı');
  lbllast_buy_money.Caption := TLocalizationManager.Translate('stk_inventory_summary.lbl_last_buy_money', 'Son Alış Para Birimi');
  lbllast_buy_date.Caption := TLocalizationManager.Translate('stk_inventory_summary.lbl_last_buy_date', 'Son Alış Tarihi');
  lbllast_buy_quantity.Caption := TLocalizationManager.Translate('stk_inventory_summary.lbl_last_buy_quantity', 'Son Alış Miktarı');
  lbllast_buy_exchange_rate.Caption := TLocalizationManager.Translate('stk_inventory_summary.lbl_last_buy_exchange_rate', 'Son Alış Kuru');
end;

procedure TfrmStkInventorySummary.InitializeInputCase;
begin
  inherited;
end;

procedure TfrmStkInventorySummary.RefreshData;
begin
  inherited;
  edtinventory_id.Text := IntToStr(Table.InventoryID);
  edtcurrent_quantity.Text := CurrToStr(Table.CurrentQuantity);
  edtaverage_cost.Text := CurrToStr(Table.AverageCost);
  edtopening_price.Text := CurrToStr(Table.OpeningPrice);
  edtopening_quantity.Text := CurrToStr(Table.OpeningQuantity);
  edtopening_amount.Text := CurrToStr(Table.OpeningAmount);
  edtincoming_quantity.Text := CurrToStr(Table.IncomingQuantity);
  edtincoming_amount.Text := CurrToStr(Table.IncomingAmount);
  edtoutgoing_quantity.Text := CurrToStr(Table.OutgoingQuantity);
  edtoutgoing_amount.Text := CurrToStr(Table.OutgoingAmount);
  edtlast_buy_price.Text := CurrToStr(Table.LastBuyPrice);
  edtlast_buy_money.Text := Table.LastBuyMoney;
  edtlast_buy_date.Date := Table.LastBuyDate;
  edtlast_buy_quantity.Text := CurrToStr(Table.LastBuyQuantity);
  edtlast_buy_exchange_rate.Text := CurrToStr(Table.LastBuyExchangeRate);
end;

end.
