unit ufrmPurQuotationDetail;

// Alış teklifi: başlık (pur_quotation) + kalemler (Table.Lines, pur_quotation_detail) tek ekranda. Kalemler bellekte
// teklif servisiyle eklenir / değişir / çıkar (satır formu TfrmPurQuotationLine); Onayla Service.BusinessSaveWithDetails
// ile başlık ve kalemleri tek transaction'da yazar. Başlık ve kalemler yalnız taslak teklifte değişir.

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes, System.Math,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls,
  System.Generics.Collections,
  ufrmInputDetailedDB, Detail.Lines, Detail.Totals, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  PurQuotation.Service, PurQuotation, PurQuotationDetail.Service, PurQuotationDetail;

type
  TfrmPurQuotationDetail = class(TfrmInputDetailedDB<TPurQuotation, TPurQuotationService>)
    pnlContent: TPanel;
    lblQuotationNo: TLabel;
    edtQuotationNo: TEdit;
    lblQuotationDate: TLabel;
    edtQuotationDate: TEdit;
    lblAccAccountId: TLabel;
    edtAccAccountId: TEdit;
    lblPurRequestId: TLabel;
    edtPurRequestId: TEdit;
    lblSupplierRefNo: TLabel;
    edtSupplierRefNo: TEdit;
    lblValidUntil: TLabel;
    edtValidUntil: TEdit;
    lblDeliveryDays: TLabel;
    edtDeliveryDays: TEdit;
    lblDeliveryDate: TLabel;
    edtDeliveryDate: TEdit;
    lblCurrency: TLabel;
    edtCurrency: TEdit;
    lblExchangeRate: TLabel;
    edtExchangeRate: TEdit;
    lblStatusText: TLabel;
    edtStatusText: TEdit;
    lblPaymentTermDays: TLabel;
    edtPaymentTermDays: TEdit;
    lblPaymentTerms: TLabel;
    edtPaymentTerms: TEdit;
    lblDescription: TLabel;
    edtDescription: TEdit;
    pnlTotals: TPanel;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  private
    FTotals: TTotalsPanel;
    FPageLines: TTabSheet;
    FLines: TDetailSet<TPurQuotationDetail>;
    procedure ShowTotals;
    // Table toplamları + bağlı sipariş / onay bilgisi panelde
    procedure ShowTotalValues;
  protected
    procedure DetailsChanged; override;
    // başlık ve kalemler yalnız taslak teklifte değişir
    function DetailsEditable: Boolean; override;
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
  PurLookup, Grid.Types, ufrmPurQuotationLine,
  AccAccount, AccAccount.Service, ufrmAccAccounts,        // TfrmAccAccounts helper output form
  PurRequest, PurRequest.Service, ufrmPurRequests,        // TfrmPurRequests helper output form
  SysCurrency, SysCurrency.Service, ufrmSysCurrencies;    // TfrmSysCurrencies helper output form

const
  ROW_ORDER = 'order';
  ROW_APPROVED = 'approved';

procedure TfrmPurQuotationDetail.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.QuotationNo := edtQuotationNo.Text;
  Table.QuotationDate := StrToDateDef(edtQuotationDate.Text, 0);
  Table.SupplierRefNo := edtSupplierRefNo.Text;
  Table.ValidUntil := StrToDateDef(edtValidUntil.Text, 0);
  Table.DeliveryDays := StrToIntDef(edtDeliveryDays.Text, 0);
  Table.DeliveryDate := StrToDateDef(edtDeliveryDate.Text, 0);
  Table.ExchangeRate := StrToCurrDef(edtExchangeRate.Text, 0);
  Table.PaymentTermDays := StrToIntDef(edtPaymentTermDays.Text, 0);
  Table.PaymentTerms := edtPaymentTerms.Text;
  Table.Description := edtDescription.Text;
  inherited;
end;

procedure TfrmPurQuotationDetail.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  FTotals := TTotalsPanel.Create(pnlTotals);
  FTotals.AddRow('gross');
  FTotals.AddRow('discount');
  FTotals.AddRow('net');
  FTotals.AddRow('vat');
  FTotals.AddRow('total', True);
  FTotals.AddRow(ROW_ORDER);
  FTotals.AddRow(ROW_APPROVED);
  pnlTotals.Height := FTotals.RequiredHeight;

  edtQuotationNo.thsInputDataType := itString;
  edtQuotationNo.CharCase := TEditCharCase.ecUpperCase;
  edtQuotationDate.thsInputDataType := itDate;
  edtAccAccountId.OnHelperProcess := HelperProcess;
  edtPurRequestId.OnHelperProcess := HelperProcess;
  edtSupplierRefNo.thsInputDataType := itString;
  edtValidUntil.thsInputDataType := itDate;
  edtDeliveryDays.thsInputDataType := itInteger;
  edtDeliveryDate.thsInputDataType := itDate;
  edtCurrency.OnHelperProcess := HelperProcess;
  edtExchangeRate.thsInputDataType := itFloat;
  edtExchangeRate.thsDecimalDigitCount := TDecimalPlaces.ExchangeRate;
  edtPaymentTermDays.thsInputDataType := itInteger;
  edtPaymentTerms.thsInputDataType := itString;
  edtDescription.thsInputDataType := itString;

  // Kalemler = Table.Lines (servis satır no sırasıyla okur); ekle / çıkar / hesap teklif servisinde,
  // satır formu modal, kayıt teklifle birlikte
  FPageLines := AddDetailPage(TLocalizationManager.Translate(TLangKeys.TPurQuotation.MenuLines, 'Lines'));
  FLines := AddDetail<TPurQuotationDetail>(FPageLines, 'vw_pur_quotation_detail',
    function: TObjectList<TPurQuotationDetail>
    begin
      Result := Table.Lines;
    end,
    function: TPurQuotationDetail
    begin
      Result := Service.CreateLine(Table);
    end,
    procedure(ALine: TPurQuotationDetail)
    begin
      Service.AddLine(Table, ALine);
    end,
    procedure(ALine: TPurQuotationDetail)
    begin
      Service.RemoveLine(Table, ALine);
    end,
    function(ALine: TPurQuotationDetail; AMode: TInputFormMode): TForm
    begin
      Result := TfrmPurQuotationLine.Create(Self, TPurQuotationDetailService.Create, ALine, AMode, nil);
    end);

  FLines.Grid.AddFooterColumn('net_amount', atSum, TDecimalPlaces.TotalFormat);
  FLines.Grid.AddFooterColumn('vat_amount', atSum, TDecimalPlaces.TotalFormat);
  FLines.Grid.AddFooterColumn('total_amount', atSum, TDecimalPlaces.TotalFormat);
  FLines.Grid.BuildData;
  FLines.Grid.SetColumnProperty('id', 0);
  FLines.Grid.SetColumnProperty('pur_quotation_id', 0);
  FLines.Grid.SetColumnProperty('stk_inventory_id', 0);
  FLines.Grid.SetColumnProperty('pur_request_detail_id', 0);
  FLines.Grid.SetColumnProperty('quotation_no', 0);
  FLines.Grid.SetColumnProperty('currency', 0);
  FLines.Grid.SetColumnProperty('gross_amount', 0);
  FLines.Grid.SetColumnProperty('discount_amount', 0);
  FLines.Grid.SetColumnProperty('line_no', 50);
  FLines.Grid.SetColumnProperty('inventory_code', 90);
  FLines.Grid.SetColumnProperty('inventory_name', 200);
  FLines.Grid.SetColumnProperty('uom_code', 50);
  FLines.Grid.SetColumnProperty('description', 160);
end;

destructor TfrmPurQuotationDetail.Destroy;
begin
  FreeAndNil(FTotals);
  inherited;
end;

procedure TfrmPurQuotationDetail.FormShow(Sender: TObject);
begin
  inherited;
  if edtQuotationDate.CanFocus then
    edtQuotationDate.SetFocus;
end;

function TfrmPurQuotationDetail.DetailsEditable: Boolean;
begin
  Result := inherited DetailsEditable and Assigned(Table) and (Table.Status = PUR_QUO_DRAFT);
end;

procedure TfrmPurQuotationDetail.ShowTotalValues;
var
  LApproved: string;
begin
  if not Assigned(FTotals) or not Assigned(Table) then
    Exit;
  FTotals.SetValue('gross', Table.GrossAmount, Table.Currency);
  FTotals.SetValue('discount', Table.DiscountAmount, Table.Currency);
  FTotals.SetValue('net', Table.NetAmount, Table.Currency);
  FTotals.SetValue('vat', Table.VatAmount, Table.Currency);
  FTotals.SetValue('total', Table.TotalAmount, Table.Currency);
  FTotals.SetText(ROW_ORDER, Table.OrderNo);
  LApproved := Table.ApprovedBy;
  if Table.ApprovedAt > 0 then
    LApproved := LApproved + ' ' + DateTimeToStr(Table.ApprovedAt);
  FTotals.SetText(ROW_APPROVED, Trim(LApproved));
end;

// Başlık toplamları: servis kalemlerden hesaplar (kayıtta yine aynı hesap)
procedure TfrmPurQuotationDetail.ShowTotals;
begin
  if not Assigned(Table) then
    Exit;
  Service.Recalculate(Table);
  ShowTotalValues;
end;

procedure TfrmPurQuotationDetail.DetailsChanged;
begin
  inherited;
  ShowTotals;
end;

procedure TfrmPurQuotationDetail.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TPurQuotation.TitleSingular, 'Purchase Quotation');
  lblQuotationNo.Caption := TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColQuotationNo, 'Quotation No');
  lblQuotationDate.Caption := TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColQuotationDate, 'Quotation Date');
  lblAccAccountId.Caption := TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColAccAccountId, 'Supplier');
  lblPurRequestId.Caption := TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColPurRequestId, 'Purchase Request');
  lblSupplierRefNo.Caption := TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColSupplierRefNo, 'Supplier Ref. No');
  lblValidUntil.Caption := TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColValidUntil, 'Valid Until');
  lblDeliveryDays.Caption := TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColDeliveryDays, 'Delivery Time (Days)');
  lblDeliveryDate.Caption := TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColDeliveryDate, 'Delivery Date');
  lblCurrency.Caption := TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColCurrency, 'Currency');
  lblExchangeRate.Caption := TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColExchangeRate, 'Exchange Rate');
  lblStatusText.Caption := TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColStatus, 'Status');
  lblPaymentTermDays.Caption := TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColPaymentTermDays, 'Payment Term (Days)');
  lblPaymentTerms.Caption := TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColPaymentTerms, 'Payment Terms');
  lblDescription.Caption := TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColDescription, 'Description');
  if Assigned(FTotals) then
  begin
    FTotals.SetCaption('gross', TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColGrossAmount, 'Gross Amount'));
    FTotals.SetCaption('discount', TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColDiscountAmount, 'Discount Amount'));
    FTotals.SetCaption('net', TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColNetAmount, 'Net Amount'));
    FTotals.SetCaption('vat', TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColVatAmount, 'VAT Amount'));
    FTotals.SetCaption('total', TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColTotalAmount, 'Total'));
    FTotals.SetCaption(ROW_ORDER, TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColOrderNo, 'Order No'));
    FTotals.SetCaption(ROW_APPROVED, TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColApprovedBy, 'Approved By'));
  end;

  if Assigned(FPageLines) then
    FPageLines.Caption := TLocalizationManager.Translate(TLangKeys.TPurQuotation.MenuLines, 'Lines');
  if Assigned(FLines) then
  begin
    FLines.Grid.SetColumnTitle('line_no', TLocalizationManager.Translate(TLangKeys.TPurQuotationDetail.ColLineNo, 'Line No'));
    FLines.Grid.SetColumnTitle('inventory_code', TLocalizationManager.Translate(TLangKeys.TPurQuotationDetail.ColInventoryCode, 'Stock Code'));
    FLines.Grid.SetColumnTitle('inventory_name', TLocalizationManager.Translate(TLangKeys.TPurQuotationDetail.ColInventoryName, 'Stock Name'));
    FLines.Grid.SetColumnTitle('uom_code', TLocalizationManager.Translate(TLangKeys.TPurQuotationDetail.ColUomCode, 'Unit'));
    FLines.Grid.SetColumnTitle('quantity', TLocalizationManager.Translate(TLangKeys.TPurQuotationDetail.ColQuantity, 'Quantity'));
    FLines.Grid.SetColumnTitle('unit_price', TLocalizationManager.Translate(TLangKeys.TPurQuotationDetail.ColUnitPrice, 'Unit Price'));
    FLines.Grid.SetColumnTitle('discount_rate', TLocalizationManager.Translate(TLangKeys.TPurQuotationDetail.ColDiscountRate, 'Discount (%)'));
    FLines.Grid.SetColumnTitle('vat_rate', TLocalizationManager.Translate(TLangKeys.TPurQuotationDetail.ColVatRate, 'VAT (%)'));
    FLines.Grid.SetColumnTitle('gross_amount', TLocalizationManager.Translate(TLangKeys.TPurQuotationDetail.ColGrossAmount, 'Gross Amount'));
    FLines.Grid.SetColumnTitle('discount_amount', TLocalizationManager.Translate(TLangKeys.TPurQuotationDetail.ColDiscountAmount, 'Discount Amount'));
    FLines.Grid.SetColumnTitle('net_amount', TLocalizationManager.Translate(TLangKeys.TPurQuotationDetail.ColNetAmount, 'Net Amount'));
    FLines.Grid.SetColumnTitle('vat_amount', TLocalizationManager.Translate(TLangKeys.TPurQuotationDetail.ColVatAmount, 'VAT Amount'));
    FLines.Grid.SetColumnTitle('total_amount', TLocalizationManager.Translate(TLangKeys.TPurQuotationDetail.ColTotalAmount, 'Total'));
    FLines.Grid.SetColumnTitle('delivery_date', TLocalizationManager.Translate(TLangKeys.TPurQuotationDetail.ColDeliveryDate, 'Delivery Date'));
    FLines.Grid.SetColumnTitle('request_no', TLocalizationManager.Translate(TLangKeys.TPurQuotationDetail.ColRequestNo, 'Request No'));
    FLines.Grid.SetColumnTitle('description', TLocalizationManager.Translate(TLangKeys.TPurQuotationDetail.ColDescription, 'Description'));
  end;
end;

procedure TfrmPurQuotationDetail.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmAccAccountId: TfrmAccAccounts;
  LFrmPurRequestId: TfrmPurRequests;
  LFrmCurrency: TfrmSysCurrencies;
  LLine: TPurQuotationDetail;
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
  else if LEdit.Name = edtPurRequestId.Name then
  begin
    LFrmPurRequestId := TfrmPurRequests.Create(LEdit, TPurRequestService.Create, TPurRequest.Create);
    try
      LFrmPurRequestId.IsHelper := True;
      LFrmPurRequestId.ShowModal;
      if LFrmPurRequestId.DataTransfer then
        if LFrmPurRequestId.CleanAndClose then
        begin
          Table.PurRequestId := 0;
          Table.RequestNo := '';
          LEdit.Clear;
        end
        else
        begin
          Table.PurRequestId := LFrmPurRequestId.Table.Id;
          Table.RequestNo := LFrmPurRequestId.Table.RequestNo;
          LEdit.Text := Table.RequestNo;
        end;
    finally
      LFrmPurRequestId.Free;
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
      // kalemlerin para birimi (fiyat önerisi) ve toplamların gösterimi belgeyle aynı
      for LLine in Table.Lines do
        LLine.Currency := Table.Currency;
      ShowTotalValues;
    finally
      LFrmCurrency.Free;
    end;
  end;
end;

procedure TfrmPurQuotationDetail.RefreshData;

  function DateText(AValue: TDate): string;
  begin
    if AValue > 0 then
      Result := DateToStr(AValue)
    else
      Result := '';
  end;

begin
  inherited;
  edtQuotationNo.Text := Table.QuotationNo;
  edtQuotationDate.Text := DateText(Table.QuotationDate);
  edtAccAccountId.Text := Table.AccountName;
  edtPurRequestId.Text := Table.RequestNo;
  edtSupplierRefNo.Text := Table.SupplierRefNo;
  edtValidUntil.Text := DateText(Table.ValidUntil);
  edtDeliveryDays.Text := IntToStr(Table.DeliveryDays);
  edtDeliveryDate.Text := DateText(Table.DeliveryDate);
  edtCurrency.Text := Table.Currency;
  edtExchangeRate.Text := CurrToStr(Table.ExchangeRate);
  edtPaymentTermDays.Text := IntToStr(Table.PaymentTermDays);
  edtPaymentTerms.Text := Table.PaymentTerms;
  edtStatusText.Text := TPurLookup.Text(plkQuotationStatus, Table.Status);
  edtDescription.Text := Table.Description;
  // bellekte kalem varsa toplamlar onlardan
  if Table.Lines.Count > 0 then
    ShowTotals
  else
    ShowTotalValues;
end;

end.
