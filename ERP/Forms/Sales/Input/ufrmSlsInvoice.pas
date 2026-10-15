unit ufrmSlsInvoice;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  SlsInvoice.Service, SlsInvoice;

type
  TfrmSlsInvoice = class(TfrmInputSimpleDB<TSlsInvoice, TSlsInvoiceService>)
    pnlContent: TPanel;
    lblInvoiceNo: TLabel;
    edtInvoiceNo: TEdit;
    lblInvoiceDate: TLabel;
    edtInvoiceDate: TEdit;
    lblAccAccountId: TLabel;
    edtAccAccountId: TEdit;
    lblDueDate: TLabel;
    edtDueDate: TEdit;
    lblStkWarehouseId: TLabel;
    edtStkWarehouseId: TEdit;
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
  SlsLookup,
  AccAccount, AccAccount.Service, ufrmAccAccounts,
  StkWarehouse, StkWarehouse.Service, ufrmStkWarehouses,
  SysCurrency, SysCurrency.Service, ufrmSysCurrencies;

procedure TfrmSlsInvoice.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.InvoiceNo := edtInvoiceNo.Text;
  Table.InvoiceDate := StrToDateDef(edtInvoiceDate.Text, 0);
  Table.DueDate := StrToDateDef(edtDueDate.Text, 0);
  Table.ExchangeRate := StrToCurrDef(edtExchangeRate.Text, 0);
  Table.Description := edtDescription.Text;
  inherited;
end;

procedure TfrmSlsInvoice.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtInvoiceNo.thsInputDataType := itString;
  edtInvoiceNo.CharCase := TEditCharCase.ecUpperCase;
  edtInvoiceDate.thsInputDataType := itDate;
  edtAccAccountId.OnHelperProcess := HelperProcess;
  edtDueDate.thsInputDataType := itDate;
  edtStkWarehouseId.OnHelperProcess := HelperProcess;
  edtCurrency.OnHelperProcess := HelperProcess;
  edtExchangeRate.thsInputDataType := itFloat;
  edtDescription.thsInputDataType := itString;
end;

procedure TfrmSlsInvoice.FormShow(Sender: TObject);
begin
  inherited;
  if edtInvoiceDate.CanFocus then
    edtInvoiceDate.SetFocus;
end;

procedure TfrmSlsInvoice.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoice.TitleSingular, 'Sales Invoice');
  lblInvoiceNo.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColInvoiceNo, 'Invoice No');
  lblInvoiceDate.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColInvoiceDate, 'Invoice Date');
  lblAccAccountId.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColAccAccountId, 'Customer');
  lblDueDate.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColDueDate, 'Due Date');
  lblStkWarehouseId.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColStkWarehouseId, 'Shipping Warehouse');
  lblCurrency.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColCurrency, 'Currency');
  lblExchangeRate.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColExchangeRate, 'Exchange Rate');
  lblDescription.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColDescription, 'Description');
  lblGrossAmount.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColGrossAmount, 'Gross Amount');
  lblDiscountAmount.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColDiscountAmount, 'Discount Amount');
  lblNetAmount.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColNetAmount, 'Net Amount');
  lblVatAmount.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColVatAmount, 'VAT Amount');
  lblTotalAmount.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColTotalAmount, 'Total');
end;

procedure TfrmSlsInvoice.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmAccAccountId: TfrmAccAccounts;
  LFrmStkWarehouseId: TfrmStkWarehouses;
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
  else if LEdit.Name = edtStkWarehouseId.Name then
  begin
    LFrmStkWarehouseId := TfrmStkWarehouses.Create(LEdit, TStkWarehouseService.Create, TStkWarehouse.Create);
    try
      LFrmStkWarehouseId.IsHelper := True;
      LFrmStkWarehouseId.ShowModal;
      if LFrmStkWarehouseId.DataTransfer then
        if LFrmStkWarehouseId.CleanAndClose then
        begin
          Table.StkWarehouseId := 0;
          Table.WarehouseName := '';
          LEdit.Clear;
        end
        else
        begin
          Table.StkWarehouseId := LFrmStkWarehouseId.Table.Id;
          Table.WarehouseName := LFrmStkWarehouseId.Table.WarehouseName;
          LEdit.Text := Table.WarehouseName;
        end;
    finally
      LFrmStkWarehouseId.Free;
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

procedure TfrmSlsInvoice.RefreshData;
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
  edtStkWarehouseId.Text := Table.WarehouseName;
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
