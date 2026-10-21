unit ufrmPurReceiptLine;

// Mal kabul kalemi satır formu (TfrmPurReceiptDetail'den modal): bellekteki satırı düzenler, DB'ye mal kabulle birlikte
// yazılır (stok hareketi dahil). Girilenler: sıra no, stok, miktar (ölçü birimi yanında), birim maliyet (para birimi
// yanında). Tutar, bağlı sipariş ve faturalanan miktar panelde; miktar / maliyet değiştikçe tutar anında hesaplanır.

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputLineDB, SharedFormTypes, LocalizationManager, Detail.Totals,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  PurReceiptDetail.Service, PurReceiptDetail;

type
  TfrmPurReceiptLine = class(TfrmInputLineDB<TPurReceiptDetail, TPurReceiptDetailService>)
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
  StkInventory, StkInventory.Service, ufrmStkInventories;   // TfrmStkInventories helper output form

const
  ROW_AMOUNT = 'amount';
  ROW_ORDER = 'order';
  ROW_INVOICED = 'invoiced';

procedure TfrmPurReceiptLine.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır; mal kabul (pur_receipt_id) ana formdan gelir
  Table.LineNo := StrToIntDef(edtLineNo.Text, 0);
  Table.Quantity := StrToCurrDef(edtQuantity.Text, 0);
  Table.UnitPrice := StrToCurrDef(edtUnitPrice.Text, 0);
  Table.Description := edtDescription.Text;
  inherited;
end;

// Kabul: alan kontrolleri + tutar (servisin belge kaydıyla aynı kurallar)
procedure TfrmPurReceiptLine.PrepareLine;
begin
  inherited;
  TPurReceiptDetailService.CheckLine(Table);
end;

procedure TfrmPurReceiptLine.FormCreate(Sender: TObject);
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
  FTotals.AddRow(ROW_ORDER);
  FTotals.AddRow(ROW_INVOICED);
  pnlTotals.Height := FTotals.RequiredHeight;
end;

destructor TfrmPurReceiptLine.Destroy;
begin
  FreeAndNil(FTotals);
  inherited;
end;

procedure TfrmPurReceiptLine.FormShow(Sender: TObject);
begin
  inherited;
  if edtStkInventoryId.CanFocus then
    edtStkInventoryId.SetFocus;
end;

procedure TfrmPurReceiptLine.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TPurReceiptDetail.TitleSingular, 'Goods Receipt Line');
  lblLineNo.Caption := TLocalizationManager.Translate(TLangKeys.TPurReceiptDetail.ColLineNo, 'Line No');
  lblStkInventoryId.Caption := TLocalizationManager.Translate(TLangKeys.TPurReceiptDetail.ColStkInventoryId, 'Stock Card');
  lblQuantity.Caption := TLocalizationManager.Translate(TLangKeys.TPurReceiptDetail.ColQuantity, 'Quantity');
  lblUnitPrice.Caption := TLocalizationManager.Translate(TLangKeys.TPurReceiptDetail.ColUnitPrice, 'Unit Cost');
  lblDescription.Caption := TLocalizationManager.Translate(TLangKeys.TPurReceiptDetail.ColDescription, 'Description');
  if Assigned(FTotals) then
  begin
    FTotals.SetCaption(ROW_AMOUNT, TLocalizationManager.Translate(TLangKeys.TPurReceiptDetail.ColAmount, 'Amount'));
    FTotals.SetCaption(ROW_ORDER, TLocalizationManager.Translate(TLangKeys.TPurReceiptDetail.ColOrderNo, 'Order No'));
    FTotals.SetCaption(ROW_INVOICED, TLocalizationManager.Translate(TLangKeys.TPurReceiptDetail.ColInvoicedQuantity, 'Invoiced Quantity'));
  end;
end;

procedure TfrmPurReceiptLine.InputChanged(Sender: TObject);
begin
  ShowAmounts;
end;

procedure TfrmPurReceiptLine.ShowAmounts;
begin
  if not Assigned(FTotals) or not Assigned(Table) then
    Exit;
  FTotals.SetValue(ROW_AMOUNT, TDecimalPlaces.RoundTo(StrToCurrDef(edtQuantity.Text, 0) * StrToCurrDef(edtUnitPrice.Text, 0), 2),
    Table.Currency);
  FTotals.SetText(ROW_ORDER, Table.OrderNo);
  FTotals.SetValue(ROW_INVOICED, Table.InvoicedQuantity, Table.UomCode, -1);
end;

procedure TfrmPurReceiptLine.HelperProcess(Sender: TObject);
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

// Stok kartının alış fiyatı (belge para biriminde ise) birim maliyet olarak önerilir
procedure TfrmPurReceiptLine.FillInventoryDefaults;
var
  LPrice, LDiscount, LVat: Currency;
  LCurrency: string;
begin
  if not Service.GetInventoryDefaults(Table.StkInventoryId, LPrice, LCurrency, LDiscount, LVat) then
    Exit;
  if (Table.Currency = '') or (LCurrency = Table.Currency) then
    edtUnitPrice.Text := CurrToStr(LPrice);
end;

procedure TfrmPurReceiptLine.RefreshData;
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
