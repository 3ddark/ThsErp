unit ufrmSlsOfferDetail;

// Satış teklifi: başlık (sls_offer) + kalemler (sls_offer_detail) tek ekranda. Kalemler bellekte eklenir / değişir /
// silinir (satır formu TfrmSlsOfferLine); Onayla başlık ve kalemleri tek transaction'da yazar.

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes, System.Math,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls,
  System.Generics.Collections,
  ufrmInputDetailedDB, Detail.Lines, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  SlsOffer.Service, SlsOffer, SlsOfferDetail.Service, SlsOfferDetail;

type
  TfrmSlsOfferDetail = class(TfrmInputDetailedDB<TSlsOffer, TSlsOfferService>)
    pnlContent: TPanel;
    lblOfferNo: TLabel;
    edtOfferNo: TEdit;
    lblOfferDate: TLabel;
    edtOfferDate: TEdit;
    lblValidUntil: TLabel;
    edtValidUntil: TEdit;
    lblAccAccountId: TLabel;
    edtAccAccountId: TEdit;
    lblCustomerRefNo: TLabel;
    edtCustomerRefNo: TEdit;
    lblEmpEmployeeId: TLabel;
    edtEmpEmployeeId: TEdit;
    lblCurrency: TLabel;
    edtCurrency: TEdit;
    lblExchangeRate: TLabel;
    edtExchangeRate: TEdit;
    lblPaymentTermDays: TLabel;
    edtPaymentTermDays: TEdit;
    lblStatusText: TLabel;
    edtStatusText: TEdit;
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
    lblDescription: TLabel;
    edtDescription: TEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  private
    FPageLines: TTabSheet;
    FLines: TDetailSet<TSlsOfferDetail, TSlsOfferDetailService>;
    procedure NewLine(ALine: TSlsOfferDetail);
    procedure ShowTotals;
  protected
    procedure DetailsChanged; override;
  public
    procedure HelperProcess(Sender: TObject);
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  SlsLookup, Grid.Types, ufrmSlsOfferLine,
  AccAccount, AccAccount.Service, ufrmAccAccounts,        // TfrmAccAccounts helper output form
  EmpEmployee, EmpEmployee.Service, ufrmEmpEmployees,     // TfrmEmpEmployees helper output form
  SysCurrency, SysCurrency.Service, ufrmSysCurrencies;    // TfrmSysCurrencies helper output form

procedure TfrmSlsOfferDetail.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.OfferNo := edtOfferNo.Text;
  Table.OfferDate := StrToDateDef(edtOfferDate.Text, 0);
  Table.ValidUntil := StrToDateDef(edtValidUntil.Text, 0);
  Table.CustomerRefNo := edtCustomerRefNo.Text;
  Table.ExchangeRate := StrToCurrDef(edtExchangeRate.Text, 0);
  Table.PaymentTermDays := StrToIntDef(edtPaymentTermDays.Text, 0);
  Table.Description := edtDescription.Text;
  inherited;
end;

procedure TfrmSlsOfferDetail.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtOfferNo.thsInputDataType := itString;
  edtOfferNo.CharCase := TEditCharCase.ecUpperCase;
  edtOfferDate.thsInputDataType := itDate;
  edtValidUntil.thsInputDataType := itDate;
  edtAccAccountId.OnHelperProcess := HelperProcess;
  edtCustomerRefNo.thsInputDataType := itString;
  edtEmpEmployeeId.OnHelperProcess := HelperProcess;
  edtCurrency.OnHelperProcess := HelperProcess;
  edtExchangeRate.thsInputDataType := itFloat;
  edtPaymentTermDays.thsInputDataType := itInteger;
  edtDescription.thsInputDataType := itString;

  // Kalemler: sıra satır no'ya göre; satır formu modal, kayıt teklifle birlikte
  FPageLines := AddDetailPage(TLocalizationManager.Translate(TLangKeys.TSlsOffer.MenuLines, 'Lines'));
  FLines := AddDetail<TSlsOfferDetail, TSlsOfferDetailService>(FPageLines, TSlsOfferDetailService.Create,
    'vw_sls_offer_detail', 'sls_offer_id',
    procedure(ALine: TSlsOfferDetail; AMasterId: Int64)
    begin
      ALine.SlsOfferId := AMasterId;
    end,
    function(ALine: TSlsOfferDetail; AMode: TInputFormMode): TForm
    begin
      Result := TfrmSlsOfferLine.Create(Self, TSlsOfferDetailService.Create, ALine, AMode, nil);
    end,
    function(const A, B: TSlsOfferDetail): Integer
    begin
      Result := CompareValue(A.LineNo, B.LineNo);
      if Result = 0 then
        Result := CompareValue(A.Id, B.Id);
    end);
  FLines.OnNewLine := NewLine;

  FLines.Grid.AddFooterColumn('net_amount', atSum, '#,##0.00');
  FLines.Grid.AddFooterColumn('vat_amount', atSum, '#,##0.00');
  FLines.Grid.AddFooterColumn('total_amount', atSum, '#,##0.00');
  FLines.Grid.BuildData;
  FLines.Grid.SetColumnProperty('id', 0);
  FLines.Grid.SetColumnProperty('sls_offer_id', 0);
  FLines.Grid.SetColumnProperty('stk_inventory_id', 0);
  FLines.Grid.SetColumnProperty('offer_no', 0);
  FLines.Grid.SetColumnProperty('currency', 0);
  FLines.Grid.SetColumnProperty('gross_amount', 0);
  FLines.Grid.SetColumnProperty('discount_amount', 0);
  FLines.Grid.SetColumnProperty('line_no', 50);
  FLines.Grid.SetColumnProperty('inventory_code', 90);
  FLines.Grid.SetColumnProperty('inventory_name', 200);
  FLines.Grid.SetColumnProperty('uom_code', 50);
  FLines.Grid.SetColumnProperty('description', 160);
end;

procedure TfrmSlsOfferDetail.FormShow(Sender: TObject);
begin
  inherited;
  if edtOfferDate.CanFocus then
    edtOfferDate.SetFocus;
end;

// Yeni kalem: teklif, para birimi (fiyat önerisi için) ve sıradaki satır no ana kayıttan
procedure TfrmSlsOfferDetail.NewLine(ALine: TSlsOfferDetail);
var
  i, LMax: Integer;
begin
  ALine.SlsOfferId := Table.Id;
  ALine.OfferNo := edtOfferNo.Text;
  ALine.Currency := Table.Currency;
  LMax := 0;
  for i := 0 to FLines.Changes.Count - 1 do
    LMax := Max(LMax, FLines.Changes[i].LineNo);
  ALine.LineNo := LMax + 1;
end;

// Başlık toplamları bellekteki kalemlerden (kayıtta servis kalemlerden yeniden hesaplar)
procedure TfrmSlsOfferDetail.ShowTotals;
var
  i: Integer;
  LGross, LDiscount, LNet, LVat, LTotal: Currency;
begin
  if not Assigned(FLines) then
    Exit;
  LGross := 0; LDiscount := 0; LNet := 0; LVat := 0; LTotal := 0;
  for i := 0 to FLines.Changes.Count - 1 do
  begin
    LGross := LGross + FLines.Changes[i].GrossAmount;
    LDiscount := LDiscount + FLines.Changes[i].DiscountAmount;
    LNet := LNet + FLines.Changes[i].NetAmount;
    LVat := LVat + FLines.Changes[i].VatAmount;
    LTotal := LTotal + FLines.Changes[i].TotalAmount;
  end;
  edtGrossAmount.Text := CurrToStr(LGross);
  edtDiscountAmount.Text := CurrToStr(LDiscount);
  edtNetAmount.Text := CurrToStr(LNet);
  edtVatAmount.Text := CurrToStr(LVat);
  edtTotalAmount.Text := CurrToStr(LTotal);
end;

procedure TfrmSlsOfferDetail.DetailsChanged;
begin
  inherited;
  ShowTotals;
end;

procedure TfrmSlsOfferDetail.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOffer.TitleSingular, 'Sales Offer');
  lblOfferNo.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColOfferNo, 'Offer No');
  lblOfferDate.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColOfferDate, 'Offer Date');
  lblValidUntil.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColValidUntil, 'Valid Until');
  lblAccAccountId.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColAccAccountId, 'Customer');
  lblCustomerRefNo.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColCustomerRefNo, 'Customer Ref. No');
  lblEmpEmployeeId.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColEmpEmployeeId, 'Sales Representative');
  lblCurrency.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColCurrency, 'Currency');
  lblExchangeRate.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColExchangeRate, 'Exchange Rate');
  lblPaymentTermDays.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColPaymentTermDays, 'Payment Term (Days)');
  lblStatusText.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColStatus, 'Status');
  lblGrossAmount.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColGrossAmount, 'Gross Amount');
  lblDiscountAmount.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColDiscountAmount, 'Discount Amount');
  lblNetAmount.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColNetAmount, 'Net Amount');
  lblVatAmount.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColVatAmount, 'VAT Amount');
  lblTotalAmount.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColTotalAmount, 'Total');
  lblDescription.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColDescription, 'Description');

  if Assigned(FPageLines) then
    FPageLines.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOffer.MenuLines, 'Lines');
  if Assigned(FLines) then
  begin
    FLines.Grid.SetColumnTitle('line_no', TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColLineNo, 'Line No'));
    FLines.Grid.SetColumnTitle('inventory_code', TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColInventoryCode, 'Stock Code'));
    FLines.Grid.SetColumnTitle('inventory_name', TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColInventoryName, 'Stock Name'));
    FLines.Grid.SetColumnTitle('uom_code', TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColUomCode, 'Unit'));
    FLines.Grid.SetColumnTitle('quantity', TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColQuantity, 'Quantity'));
    FLines.Grid.SetColumnTitle('unit_price', TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColUnitPrice, 'Unit Price'));
    FLines.Grid.SetColumnTitle('discount_rate', TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColDiscountRate, 'Discount (%)'));
    FLines.Grid.SetColumnTitle('vat_rate', TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColVatRate, 'VAT (%)'));
    FLines.Grid.SetColumnTitle('gross_amount', TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColGrossAmount, 'Gross Amount'));
    FLines.Grid.SetColumnTitle('discount_amount', TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColDiscountAmount, 'Discount Amount'));
    FLines.Grid.SetColumnTitle('net_amount', TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColNetAmount, 'Net Amount'));
    FLines.Grid.SetColumnTitle('vat_amount', TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColVatAmount, 'VAT Amount'));
    FLines.Grid.SetColumnTitle('total_amount', TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColTotalAmount, 'Total'));
    FLines.Grid.SetColumnTitle('ordered_quantity', TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColOrderedQuantity, 'Ordered Quantity'));
    FLines.Grid.SetColumnTitle('description', TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColDescription, 'Description'));
  end;
end;

procedure TfrmSlsOfferDetail.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmAccAccountId: TfrmAccAccounts;
  LFrmEmpEmployeeId: TfrmEmpEmployees;
  LFrmCurrency: TfrmSysCurrencies;
begin
  if not (Sender is TEdit) then
    Exit;

  LEdit := (Sender as TEdit);
  if LEdit.Name = edtAccAccountId.Name then
  begin
    LFrmAccAccountId := TfrmAccAccounts.Create(LEdit, TAccAccountService.Create, TAccAccount.Create);
    try
      LFrmAccAccountId.IsHelper := True;
      LFrmAccAccountId.ShowModal;
      if LFrmAccAccountId.DataTransfer then
        if LFrmAccAccountId.CleanAndClose then
        begin
          Table.AccAccountId := 0;
          Table.AccountCode := '';
          Table.AccountName := '';
          LEdit.Clear;
        end
        else
        begin
          Table.AccAccountId := LFrmAccAccountId.Table.Id;
          Table.AccountCode := LFrmAccAccountId.Table.Code;
          Table.AccountName := LFrmAccAccountId.Table.Name;
          LEdit.Text := Table.AccountName;
        end;
    finally
      LFrmAccAccountId.Free;
    end;
  end
  else if LEdit.Name = edtEmpEmployeeId.Name then
  begin
    LFrmEmpEmployeeId := TfrmEmpEmployees.Create(LEdit, TEmpEmployeeService.Create, TEmpEmployee.Create);
    try
      LFrmEmpEmployeeId.IsHelper := True;
      LFrmEmpEmployeeId.ShowModal;
      if LFrmEmpEmployeeId.DataTransfer then
        if LFrmEmpEmployeeId.CleanAndClose then
        begin
          Table.EmpEmployeeId := 0;
          Table.EmployeeName := '';
          LEdit.Clear;
        end
        else
        begin
          Table.EmpEmployeeId := LFrmEmpEmployeeId.Table.Id;
          Table.EmployeeName := LFrmEmpEmployeeId.Table.FullName;
          LEdit.Text := Table.EmployeeName;
        end;
    finally
      LFrmEmpEmployeeId.Free;
    end;
  end
  else if LEdit.Name = edtCurrency.Name then
  begin
    LFrmCurrency := TfrmSysCurrencies.Create(LEdit, TSysCurrencyService.Create, TSysCurrency.Create);
    try
      LFrmCurrency.IsHelper := True;
      LFrmCurrency.ShowModal;
      if LFrmCurrency.DataTransfer then
        if LFrmCurrency.CleanAndClose then
        begin
          Table.Currency := '';
          LEdit.Clear;
        end
        else
        begin
          Table.Currency := LFrmCurrency.Table.Currency;
          LEdit.Text := Table.Currency;
        end;
    finally
      LFrmCurrency.Free;
    end;
  end;
end;

procedure TfrmSlsOfferDetail.RefreshData;
begin
  inherited;
  edtOfferNo.Text := Table.OfferNo;
  if Table.OfferDate > 0 then
    edtOfferDate.Text := DateToStr(Table.OfferDate)
  else
    edtOfferDate.Text := '';
  if Table.ValidUntil > 0 then
    edtValidUntil.Text := DateToStr(Table.ValidUntil)
  else
    edtValidUntil.Text := '';
  edtAccAccountId.Text := Table.AccountName;
  edtCustomerRefNo.Text := Table.CustomerRefNo;
  edtEmpEmployeeId.Text := Table.EmployeeName;
  edtCurrency.Text := Table.Currency;
  edtExchangeRate.Text := CurrToStr(Table.ExchangeRate);
  edtPaymentTermDays.Text := IntToStr(Table.PaymentTermDays);
  edtStatusText.Text := TSlsLookup.Text(slkOfferStatus, Table.Status);
  edtGrossAmount.Text := CurrToStr(Table.GrossAmount);
  edtDiscountAmount.Text := CurrToStr(Table.DiscountAmount);
  edtNetAmount.Text := CurrToStr(Table.NetAmount);
  edtVatAmount.Text := CurrToStr(Table.VatAmount);
  edtTotalAmount.Text := CurrToStr(Table.TotalAmount);
  edtDescription.Text := Table.Description;
  // açık satırlar varsa toplamlar onlardan
  if Assigned(FLines) and (FLines.Changes.Count > 0) then
    ShowTotals;
end;

end.
