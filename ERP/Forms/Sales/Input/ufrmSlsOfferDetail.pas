unit ufrmSlsOfferDetail;

// Satış teklifi: başlık (sls_offer) + kalemler (Table.Lines, sls_offer_detail) tek ekranda. Kalemler bellekte teklif
// servisiyle eklenir / değişir / çıkar (satır formu TfrmSlsOfferLine); Onayla Service.BusinessSaveWithDetails ile
// başlık ve kalemleri tek transaction'da yazar.

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes, System.Math,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls,
  System.Generics.Collections,
  ufrmInputDetailedDB, Detail.Lines, Detail.Totals, SharedFormTypes, LocalizationManager,
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
    pnlTotals: TPanel;
    lblDescription: TLabel;
    edtDescription: TEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  private
    FTotals: TTotalsPanel;
    FPageLines: TTabSheet;
    FLines: TDetailSet<TSlsOfferDetail>;
    procedure ShowTotals;
    // Table toplamları panelde (para birimiyle)
    procedure ShowTotalValues;
  protected
    procedure DetailsChanged; override;
  public
    destructor Destroy; override;
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
  FTotals := TTotalsPanel.Create(pnlTotals);
  FTotals.AddRow('gross');
  FTotals.AddRow('discount');
  FTotals.AddRow('net');
  FTotals.AddRow('vat');
  FTotals.AddRow('total', True);
  pnlTotals.Height := FTotals.RequiredHeight;
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

  // Kalemler = Table.Lines (servis satır no sırasıyla okur); ekle / çıkar / hesap teklif servisinde,
  // satır formu modal, kayıt teklifle birlikte
  FPageLines := AddDetailPage(TLocalizationManager.Translate(TLangKeys.TSlsOffer.MenuLines, 'Lines'));
  FLines := AddDetail<TSlsOfferDetail>(FPageLines, 'vw_sls_offer_detail',
    function: TObjectList<TSlsOfferDetail>
    begin
      Result := Table.Lines;
    end,
    function: TSlsOfferDetail
    begin
      Result := Service.CreateLine(Table);
    end,
    procedure(ALine: TSlsOfferDetail)
    begin
      Service.AddLine(Table, ALine);
    end,
    procedure(ALine: TSlsOfferDetail)
    begin
      Service.RemoveLine(Table, ALine);
    end,
    function(ALine: TSlsOfferDetail; AMode: TInputFormMode): TForm
    begin
      Result := TfrmSlsOfferLine.Create(Self, TSlsOfferDetailService.Create, ALine, AMode, nil);
    end);

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

// Başlık toplamları: servis kalemlerden hesaplar (kayıtta yine aynı hesap)
destructor TfrmSlsOfferDetail.Destroy;
begin
  FreeAndNil(FTotals);
  inherited;
end;

procedure TfrmSlsOfferDetail.ShowTotalValues;
begin
  if not Assigned(FTotals) or not Assigned(Table) then
    Exit;
  FTotals.SetValue('gross', Table.GrossAmount, Table.Currency);
  FTotals.SetValue('discount', Table.DiscountAmount, Table.Currency);
  FTotals.SetValue('net', Table.NetAmount, Table.Currency);
  FTotals.SetValue('vat', Table.VatAmount, Table.Currency);
  FTotals.SetValue('total', Table.TotalAmount, Table.Currency);
end;

procedure TfrmSlsOfferDetail.ShowTotals;
begin
  if not Assigned(Table) then
    Exit;
  Service.Recalculate(Table);
  ShowTotalValues;
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
  if Assigned(FTotals) then
  begin
    FTotals.SetCaption('gross', TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColGrossAmount, 'Gross Amount'));
    FTotals.SetCaption('discount', TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColDiscountAmount, 'Discount Amount'));
    FTotals.SetCaption('net', TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColNetAmount, 'Net Amount'));
    FTotals.SetCaption('vat', TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColVatAmount, 'VAT Amount'));
    FTotals.SetCaption('total', TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColTotalAmount, 'Total'));
  end;
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
  LLine: TSlsOfferDetail;
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
      // kalemlerin para birimi (fiyat önerisi) ve toplamların gösterimi belgeyle aynı
      for LLine in Table.Lines do
        LLine.Currency := Table.Currency;
      ShowTotalValues;
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
  ShowTotalValues;
  edtDescription.Text := Table.Description;
  // bellekte kalem varsa toplamlar onlardan
  if Table.Lines.Count > 0 then
    ShowTotals
  else
    ShowTotalValues;
end;

end.
