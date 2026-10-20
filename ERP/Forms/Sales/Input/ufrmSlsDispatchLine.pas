unit ufrmSlsDispatchLine;

// İrsaliye kalemi satır formu (TfrmSlsDispatchDetail'den modal): bellekteki satırı düzenler, DB'ye irsaliyeyle birlikte
// yazılır. Girilenler: sıra no, stok, miktar (ölçü birimi yanında), net birim fiyat (para birimi yanında). Hesaplananlar
// (tutar, faturalanan miktar, bağlı sipariş) panelde; miktar / fiyat değiştikçe tutar anında hesaplanır.

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputLineDB, SharedFormTypes, LocalizationManager, Detail.Totals,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  SlsDispatchDetail.Service, SlsDispatchDetail;

type
  TfrmSlsDispatchLine = class(TfrmInputLineDB<TSlsDispatchDetail, TSlsDispatchDetailService>)
    pnlContent: TPanel;
    lblLineNo: TLabel;
    edtLineNo: TEdit;
    lblStkInventoryId: TLabel;
    edtStkInventoryId: TEdit;
    lblQuantity: TLabel;
    edtQuantity: TEdit;
    lblUomCode: TLabel;
    lblUnitPrice: TLabel;
    edtUnitPrice: TEdit;
    lblPriceCurrency: TLabel;
    lblDescription: TLabel;
    edtDescription: TEdit;
    pnlTotals: TPanel;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  private
    FTotals: TTotalsPanel;
    procedure FillInventoryDefaults;
    procedure InputChanged(Sender: TObject);
    // Girilen değerlerle tutar (Table'a yazmadan) hesaplanır ve panelde gösterilir
    procedure ShowAmounts;
  protected
    procedure PrepareLine; override;
  public
    destructor Destroy; override;
    procedure HelperProcess(Sender: TObject);
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  SysDecimalPlace.Cache,
  SlsLookup,
  StkInventory, StkInventory.Service, ufrmStkInventories;   // TfrmStkInventories helper output form

const
  ROW_AMOUNT = 'amount';
  ROW_INVOICED = 'invoiced';
  ROW_ORDER = 'order';

procedure TfrmSlsDispatchLine.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır; irsaliye (sls_dispatch_id) ana formdan gelir
  Table.LineNo := StrToIntDef(edtLineNo.Text, 0);
  Table.Quantity := StrToCurrDef(edtQuantity.Text, 0);
  Table.UnitPrice := StrToCurrDef(edtUnitPrice.Text, 0);
  Table.Description := edtDescription.Text;
  inherited;
end;

// Kabul: alan kontrolleri + tutar (servisin belge kaydıyla aynı kurallar)
procedure TfrmSlsDispatchLine.PrepareLine;
begin
  inherited;
  TSlsDispatchDetailService.CheckLine(Table);
end;

procedure TfrmSlsDispatchLine.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtLineNo.thsInputDataType := itInteger;
  edtStkInventoryId.OnHelperProcess := HelperProcess;
  edtQuantity.thsInputDataType := itFloat;
  edtQuantity.thsDecimalDigitCount := TDecimalPlaces.Quantity;
  edtUnitPrice.thsInputDataType := itFloat;
  edtUnitPrice.thsDecimalDigitCount := TDecimalPlaces.Price;
  edtDescription.thsInputDataType := itString;

  edtQuantity.OnChange := InputChanged;
  edtUnitPrice.OnChange := InputChanged;

  FTotals := TTotalsPanel.Create(pnlTotals);
  FTotals.AddRow(ROW_AMOUNT, True);
  FTotals.AddRow(ROW_INVOICED);
  FTotals.AddRow(ROW_ORDER);
  pnlTotals.Height := FTotals.RequiredHeight;
end;

destructor TfrmSlsDispatchLine.Destroy;
begin
  FreeAndNil(FTotals);
  inherited;
end;

procedure TfrmSlsDispatchLine.FormShow(Sender: TObject);
begin
  inherited;
  if edtStkInventoryId.CanFocus then
    edtStkInventoryId.SetFocus;
end;

procedure TfrmSlsDispatchLine.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatchDetail.TitleSingular, 'Delivery Note Line');
  lblLineNo.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatchDetail.ColLineNo, 'Line No');
  lblStkInventoryId.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatchDetail.ColStkInventoryId, 'Stock Card');
  lblQuantity.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatchDetail.ColQuantity, 'Quantity');
  lblUnitPrice.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatchDetail.ColUnitPrice, 'Net Unit Price');
  lblDescription.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatchDetail.ColDescription, 'Description');
  if Assigned(FTotals) then
  begin
    FTotals.SetCaption(ROW_AMOUNT, TLocalizationManager.Translate(TLangKeys.TSlsDispatchDetail.ColAmount, 'Amount'));
    FTotals.SetCaption(ROW_INVOICED, TLocalizationManager.Translate(TLangKeys.TSlsDispatchDetail.ColInvoicedQuantity, 'Invoiced Quantity'));
    FTotals.SetCaption(ROW_ORDER, TLocalizationManager.Translate(TLangKeys.TSlsDispatchDetail.ColOrderNo, 'Order No'));
  end;
end;

procedure TfrmSlsDispatchLine.InputChanged(Sender: TObject);
begin
  ShowAmounts;
end;

procedure TfrmSlsDispatchLine.ShowAmounts;
begin
  if not Assigned(FTotals) or not Assigned(Table) then
    Exit;
  FTotals.SetValue(ROW_AMOUNT, TSlsLookup.RoundAmount(StrToCurrDef(edtQuantity.Text, 0) * StrToCurrDef(edtUnitPrice.Text, 0)), Table.Currency);
  FTotals.SetValue(ROW_INVOICED, Table.InvoicedQuantity, Table.UomCode, -1);
  FTotals.SetText(ROW_ORDER, Table.OrderNo);
end;

procedure TfrmSlsDispatchLine.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmStkInventoryId: TfrmStkInventories;
begin
  if not (Sender is TEdit) then
    Exit;
  LEdit := (Sender as TEdit);
  if LEdit.Name = edtStkInventoryId.Name then
  begin
    LFrmStkInventoryId := TfrmStkInventories.Create(LEdit, TStkInventoryService.Create, TStkInventory.Create);
    try
      LFrmStkInventoryId.IsHelper := True;
      LFrmStkInventoryId.ShowModal;
      if LFrmStkInventoryId.DataTransfer then
        if LFrmStkInventoryId.CleanAndClose then
        begin
          Table.StkInventoryId := 0;
          Table.InventoryCode := '';
          Table.InventoryName := '';
          Table.UomCode := '';
          LEdit.Clear;
        end
        else
        begin
          Table.StkInventoryId := LFrmStkInventoryId.Table.Id;
          Table.InventoryCode := LFrmStkInventoryId.Table.Code;
          Table.InventoryName := LFrmStkInventoryId.Table.Name;
          Table.UomCode := Service.GetUomCode(Table.StkInventoryId);
          LEdit.Text := Table.InventoryName;
        end;
      lblUomCode.Caption := Table.UomCode;
      if LFrmStkInventoryId.DataTransfer and not LFrmStkInventoryId.CleanAndClose then
        FillInventoryDefaults;
      ShowAmounts;
    finally
      LFrmStkInventoryId.Free;
    end;
  end;
end;

// Stok kartının iskontolu satış fiyatı (belge para biriminde ise) net fiyat olarak önerilir
procedure TfrmSlsDispatchLine.FillInventoryDefaults;
var
  LPrice, LDiscount, LVat: Currency;
  LCurrency: string;
begin
  if not Service.GetInventoryDefaults(Table.StkInventoryId, LPrice, LCurrency, LDiscount, LVat) then
    Exit;
  if (Table.Currency = '') or (LCurrency = Table.Currency) then
    edtUnitPrice.Text := CurrToStr(LPrice * (100 - LDiscount) / 100);
end;

procedure TfrmSlsDispatchLine.RefreshData;
begin
  inherited;
  edtLineNo.Text := IntToStr(Table.LineNo);
  edtStkInventoryId.Text := Table.InventoryName;
  edtQuantity.Text := CurrToStr(Table.Quantity);
  edtUnitPrice.Text := CurrToStr(Table.UnitPrice);
  edtDescription.Text := Table.Description;
  lblUomCode.Caption := Table.UomCode;
  lblPriceCurrency.Caption := Table.Currency;
  ShowAmounts;
end;

end.
