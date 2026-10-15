unit ufrmSlsInvoiceDetail;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  SlsInvoiceDetail.Service, SlsInvoiceDetail;

type
  TfrmSlsInvoiceDetail = class(TfrmInputSimpleDB<TSlsInvoiceDetail, TSlsInvoiceDetailService>)
    pnlContent: TPanel;
    lblSlsInvoiceId: TLabel;
    edtSlsInvoiceId: TEdit;
    lblLineNo: TLabel;
    edtLineNo: TEdit;
    lblStkInventoryId: TLabel;
    edtStkInventoryId: TEdit;
    lblQuantity: TLabel;
    edtQuantity: TEdit;
    lblUnitPrice: TLabel;
    edtUnitPrice: TEdit;
    lblDiscountRate: TLabel;
    edtDiscountRate: TEdit;
    lblVatRate: TLabel;
    edtVatRate: TEdit;
    lblDescription: TLabel;
    edtDescription: TEdit;
    lblGrossAmount: TLabel;
    edtGrossAmount: TEdit;
    lblDiscountAmount: TLabel;
    edtDiscountAmount: TEdit;
    lblNetAmount: TLabel;
    edtNetAmount: TEdit;
    lblVatAmount: TLabel;
    edtVatAmount: TEdit;
    lblTotalAmount: TLabel;
    edtTotalAmount: TEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
    procedure FillInventoryDefaults;
  public
    procedure HelperProcess(Sender: TObject);
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  SlsLookup,
  SlsInvoice, SlsInvoice.Service, ufrmSlsInvoices,
  StkInventory, StkInventory.Service, ufrmStkInventories;

procedure TfrmSlsInvoiceDetail.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.LineNo := StrToIntDef(edtLineNo.Text, 0);
  Table.Quantity := StrToCurrDef(edtQuantity.Text, 0);
  Table.UnitPrice := StrToCurrDef(edtUnitPrice.Text, 0);
  Table.DiscountRate := StrToCurrDef(edtDiscountRate.Text, 0);
  Table.VatRate := StrToCurrDef(edtVatRate.Text, 0);
  Table.Description := edtDescription.Text;
  inherited;
end;

procedure TfrmSlsInvoiceDetail.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtSlsInvoiceId.OnHelperProcess := HelperProcess;
  edtLineNo.thsInputDataType := itInteger;
  edtStkInventoryId.OnHelperProcess := HelperProcess;
  edtQuantity.thsInputDataType := itFloat;
  edtUnitPrice.thsInputDataType := itFloat;
  edtDiscountRate.thsInputDataType := itFloat;
  edtVatRate.thsInputDataType := itFloat;
  edtDescription.thsInputDataType := itString;
end;

procedure TfrmSlsInvoiceDetail.FormShow(Sender: TObject);
begin
  inherited;
  if edtStkInventoryId.CanFocus then
    edtStkInventoryId.SetFocus;
end;

procedure TfrmSlsInvoiceDetail.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.TitleSingular, 'Invoice Line');
  lblSlsInvoiceId.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColSlsInvoiceId, 'Invoice');
  lblLineNo.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColLineNo, 'Line No');
  lblStkInventoryId.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColStkInventoryId, 'Stock Card');
  lblQuantity.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColQuantity, 'Quantity');
  lblUnitPrice.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColUnitPrice, 'Unit Price');
  lblDiscountRate.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColDiscountRate, 'Discount (%)');
  lblVatRate.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColVatRate, 'VAT (%)');
  lblDescription.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColDescription, 'Description');
  lblGrossAmount.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColGrossAmount, 'Gross Amount');
  lblDiscountAmount.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColDiscountAmount, 'Discount Amount');
  lblNetAmount.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColNetAmount, 'Net Amount');
  lblVatAmount.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColVatAmount, 'VAT Amount');
  lblTotalAmount.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColTotalAmount, 'Total');
end;

procedure TfrmSlsInvoiceDetail.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmSlsInvoiceId: TfrmSlsInvoices;
  LFrmStkInventoryId: TfrmStkInventories;
begin
  if not (Sender is TEdit) then
    Exit;

  LEdit := (Sender as TEdit);
  if LEdit.Name = edtSlsInvoiceId.Name then
  begin
    LFrmSlsInvoiceId := TfrmSlsInvoices.Create(LEdit, TSlsInvoiceService.Create, TSlsInvoice.Create);
    try
      LFrmSlsInvoiceId.IsHelper := True;
      LFrmSlsInvoiceId.ShowModal;
      if LFrmSlsInvoiceId.DataTransfer then
        if LFrmSlsInvoiceId.CleanAndClose then
        begin
          Table.SlsInvoiceId := 0;
          Table.InvoiceNo := '';
          Table.Currency := '';
          LEdit.Clear;
        end
        else
        begin
          Table.SlsInvoiceId := LFrmSlsInvoiceId.Table.Id;
          Table.InvoiceNo := LFrmSlsInvoiceId.Table.InvoiceNo;
          Table.Currency := LFrmSlsInvoiceId.Table.Currency;
          LEdit.Text := Table.InvoiceNo;
        end;
    finally
      LFrmSlsInvoiceId.Free;
    end;
  end
  else if LEdit.Name = edtStkInventoryId.Name then
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
          LEdit.Clear;
        end
        else
        begin
          Table.StkInventoryId := LFrmStkInventoryId.Table.Id;
          Table.InventoryCode := LFrmStkInventoryId.Table.Code;
          Table.InventoryName := LFrmStkInventoryId.Table.Name;
          LEdit.Text := Table.InventoryName;
        end;
      if LFrmStkInventoryId.DataTransfer and not LFrmStkInventoryId.CleanAndClose then
        FillInventoryDefaults;
    finally
      LFrmStkInventoryId.Free;
    end;
  end;
end;

// Stok kartının satış fiyatı (belge para biriminde ise), satış iskontosu ve geçerli KDV oranı önerilir
procedure TfrmSlsInvoiceDetail.FillInventoryDefaults;
var
  LPrice, LDiscount, LVat: Currency;
  LCurrency: string;
begin
  if not Service.GetInventoryDefaults(Table.StkInventoryId, LPrice, LCurrency, LDiscount, LVat) then
    Exit;
  if (Table.Currency = '') or (LCurrency = Table.Currency) then
    edtUnitPrice.Text := CurrToStr(LPrice);
  edtDiscountRate.Text := CurrToStr(LDiscount);
  edtVatRate.Text := CurrToStr(LVat);
end;

procedure TfrmSlsInvoiceDetail.RefreshData;
begin
  inherited;
  edtSlsInvoiceId.Text := Table.InvoiceNo;
  edtLineNo.Text := IntToStr(Table.LineNo);
  edtStkInventoryId.Text := Table.InventoryName;
  edtQuantity.Text := CurrToStr(Table.Quantity);
  edtUnitPrice.Text := CurrToStr(Table.UnitPrice);
  edtDiscountRate.Text := CurrToStr(Table.DiscountRate);
  edtVatRate.Text := CurrToStr(Table.VatRate);
  edtDescription.Text := Table.Description;
  edtGrossAmount.Text := CurrToStr(Table.GrossAmount);
  edtDiscountAmount.Text := CurrToStr(Table.DiscountAmount);
  edtNetAmount.Text := CurrToStr(Table.NetAmount);
  edtVatAmount.Text := CurrToStr(Table.VatAmount);
  edtTotalAmount.Text := CurrToStr(Table.TotalAmount);
end;

end.
