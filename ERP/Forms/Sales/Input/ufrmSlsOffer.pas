unit ufrmSlsOffer;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  SlsOffer.Service, SlsOffer;

type
  TfrmSlsOffer = class(TfrmInputSimpleDB<TSlsOffer, TSlsOfferService>)
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
  public
    procedure HelperProcess(Sender: TObject);
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  SlsLookup,
  AccAccount, AccAccount.Service, ufrmAccAccounts,
  EmpEmployee, EmpEmployee.Service, ufrmEmpEmployees,
  SysCurrency, SysCurrency.Service, ufrmSysCurrencies;

procedure TfrmSlsOffer.BtnAcceptClick(Sender: TObject);
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

procedure TfrmSlsOffer.FormCreate(Sender: TObject);
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
end;

procedure TfrmSlsOffer.FormShow(Sender: TObject);
begin
  inherited;
  if edtOfferDate.CanFocus then
    edtOfferDate.SetFocus;
end;

procedure TfrmSlsOffer.ApplyLocalization;
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
end;

procedure TfrmSlsOffer.HelperProcess(Sender: TObject);
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

procedure TfrmSlsOffer.RefreshData;
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
end;

end.
