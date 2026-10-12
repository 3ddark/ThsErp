unit ufrmPurInvoice;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  PurInvoice.Service, PurInvoice;

type
  TfrmPurInvoice = class(TfrmInputSimpleDB<TPurInvoice, TPurInvoiceService>)
    pnlContent: TPanel;
    lblInvoiceNo: TLabel;
    edtInvoiceNo: TEdit;
    lblInvoiceDate: TLabel;
    edtInvoiceDate: TEdit;
    lblAccAccountId: TLabel;
    edtAccAccountId: TEdit;
    lblDueDate: TLabel;
    edtDueDate: TEdit;
    lblCurrency: TLabel;
    edtCurrency: TEdit;
    lblExchangeRate: TLabel;
    edtExchangeRate: TEdit;
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
  public
    procedure HelperProcess(Sender: TObject);
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  PurLookup,
  AccAccount, AccAccount.Service, ufrmAccAccounts,
  SysCurrency, SysCurrency.Service, ufrmSysCurrencies;

procedure TfrmPurInvoice.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.InvoiceNo := edtInvoiceNo.Text;
  Table.InvoiceDate := StrToDateDef(edtInvoiceDate.Text, 0);
  Table.DueDate := StrToDateDef(edtDueDate.Text, 0);
  Table.ExchangeRate := StrToCurrDef(edtExchangeRate.Text, 0);
  Table.Description := edtDescription.Text;
  inherited;
end;

procedure TfrmPurInvoice.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtInvoiceNo.thsInputDataType := itString;
  edtInvoiceNo.CharCase := TEditCharCase.ecUpperCase;
  edtInvoiceDate.thsInputDataType := itDate;
  edtAccAccountId.OnHelperProcess := HelperProcess;
  edtDueDate.thsInputDataType := itDate;
  edtCurrency.OnHelperProcess := HelperProcess;
  edtExchangeRate.thsInputDataType := itFloat;
  edtDescription.thsInputDataType := itString;
end;

procedure TfrmPurInvoice.FormShow(Sender: TObject);
begin
  inherited;
  if edtInvoiceNo.CanFocus then
    edtInvoiceNo.SetFocus;
end;

procedure TfrmPurInvoice.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TPurInvoice.TitleSingular, 'Purchase Invoice');
  lblInvoiceNo.Caption := TLocalizationManager.Translate(TLangKeys.TPurInvoice.ColInvoiceNo, 'Invoice No');
  lblInvoiceDate.Caption := TLocalizationManager.Translate(TLangKeys.TPurInvoice.ColInvoiceDate, 'Invoice Date');
  lblAccAccountId.Caption := TLocalizationManager.Translate(TLangKeys.TPurInvoice.ColAccAccountId, 'Supplier');
  lblDueDate.Caption := TLocalizationManager.Translate(TLangKeys.TPurInvoice.ColDueDate, 'Due Date');
  lblCurrency.Caption := TLocalizationManager.Translate(TLangKeys.TPurInvoice.ColCurrency, 'Currency');
  lblExchangeRate.Caption := TLocalizationManager.Translate(TLangKeys.TPurInvoice.ColExchangeRate, 'Exchange Rate');
  lblDescription.Caption := TLocalizationManager.Translate(TLangKeys.TPurInvoice.ColDescription, 'Description');
  lblGrossAmount.Caption := TLocalizationManager.Translate(TLangKeys.TPurInvoice.ColGrossAmount, 'Gross Amount');
  lblDiscountAmount.Caption := TLocalizationManager.Translate(TLangKeys.TPurInvoice.ColDiscountAmount, 'Discount Amount');
  lblNetAmount.Caption := TLocalizationManager.Translate(TLangKeys.TPurInvoice.ColNetAmount, 'Net Amount');
  lblVatAmount.Caption := TLocalizationManager.Translate(TLangKeys.TPurInvoice.ColVatAmount, 'VAT Amount');
  lblTotalAmount.Caption := TLocalizationManager.Translate(TLangKeys.TPurInvoice.ColTotalAmount, 'Total');
end;

procedure TfrmPurInvoice.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmAccAccountId: TfrmAccAccounts;
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

procedure TfrmPurInvoice.RefreshData;
begin
  inherited;
  edtInvoiceNo.Text := Table.InvoiceNo;
  if Table.InvoiceDate > 0 then
    edtInvoiceDate.Text := DateToStr(Table.InvoiceDate)
  else
    edtInvoiceDate.Text := '';
  edtAccAccountId.Text := Table.AccountName;
  if Table.DueDate > 0 then
    edtDueDate.Text := DateToStr(Table.DueDate)
  else
    edtDueDate.Text := '';
  edtCurrency.Text := Table.Currency;
  edtExchangeRate.Text := CurrToStr(Table.ExchangeRate);
  edtDescription.Text := Table.Description;
  edtGrossAmount.Text := CurrToStr(Table.GrossAmount);
  edtDiscountAmount.Text := CurrToStr(Table.DiscountAmount);
  edtNetAmount.Text := CurrToStr(Table.NetAmount);
  edtVatAmount.Text := CurrToStr(Table.VatAmount);
  edtTotalAmount.Text := CurrToStr(Table.TotalAmount);
end;

end.
