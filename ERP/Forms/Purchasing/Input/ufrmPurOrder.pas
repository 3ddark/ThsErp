unit ufrmPurOrder;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  PurOrder.Service, PurOrder;

type
  TfrmPurOrder = class(TfrmInputSimpleDB<TPurOrder, TPurOrderService>)
    pnlContent: TPanel;
    lblOrderNo: TLabel;
    edtOrderNo: TEdit;
    lblOrderDate: TLabel;
    edtOrderDate: TEdit;
    lblAccAccountId: TLabel;
    edtAccAccountId: TEdit;
    lblSupplierRefNo: TLabel;
    edtSupplierRefNo: TEdit;
    lblDeliveryDate: TLabel;
    edtDeliveryDate: TEdit;
    lblStkWarehouseId: TLabel;
    edtStkWarehouseId: TEdit;
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
  PurLookup,
  AccAccount, AccAccount.Service, ufrmAccAccounts,
  StkWarehouse, StkWarehouse.Service, ufrmStkWarehouses,
  SysCurrency, SysCurrency.Service, ufrmSysCurrencies;

procedure TfrmPurOrder.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.OrderNo := edtOrderNo.Text;
  Table.OrderDate := StrToDateDef(edtOrderDate.Text, 0);
  Table.SupplierRefNo := edtSupplierRefNo.Text;
  Table.DeliveryDate := StrToDateDef(edtDeliveryDate.Text, 0);
  Table.ExchangeRate := StrToCurrDef(edtExchangeRate.Text, 0);
  Table.PaymentTermDays := StrToIntDef(edtPaymentTermDays.Text, 0);
  Table.Description := edtDescription.Text;
  inherited;
end;

procedure TfrmPurOrder.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtOrderNo.thsInputDataType := itString;
  edtOrderNo.CharCase := TEditCharCase.ecUpperCase;
  edtOrderDate.thsInputDataType := itDate;
  edtAccAccountId.OnHelperProcess := HelperProcess;
  edtSupplierRefNo.thsInputDataType := itString;
  edtDeliveryDate.thsInputDataType := itDate;
  edtStkWarehouseId.OnHelperProcess := HelperProcess;
  edtCurrency.OnHelperProcess := HelperProcess;
  edtExchangeRate.thsInputDataType := itFloat;
  edtPaymentTermDays.thsInputDataType := itInteger;
  edtDescription.thsInputDataType := itString;
end;

procedure TfrmPurOrder.FormShow(Sender: TObject);
begin
  inherited;
  if edtOrderDate.CanFocus then
    edtOrderDate.SetFocus;
end;

procedure TfrmPurOrder.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrder.TitleSingular, 'Purchase Order');
  lblOrderNo.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrder.ColOrderNo, 'Order No');
  lblOrderDate.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrder.ColOrderDate, 'Order Date');
  lblAccAccountId.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrder.ColAccAccountId, 'Supplier');
  lblSupplierRefNo.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrder.ColSupplierRefNo, 'Supplier Ref. No');
  lblDeliveryDate.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrder.ColDeliveryDate, 'Delivery Date');
  lblStkWarehouseId.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrder.ColStkWarehouseId, 'Delivery Warehouse');
  lblCurrency.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrder.ColCurrency, 'Currency');
  lblExchangeRate.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrder.ColExchangeRate, 'Exchange Rate');
  lblPaymentTermDays.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrder.ColPaymentTermDays, 'Payment Term (Days)');
  lblStatusText.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrder.ColStatus, 'Status');
  lblGrossAmount.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrder.ColGrossAmount, 'Gross Amount');
  lblDiscountAmount.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrder.ColDiscountAmount, 'Discount Amount');
  lblNetAmount.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrder.ColNetAmount, 'Net Amount');
  lblVatAmount.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrder.ColVatAmount, 'VAT Amount');
  lblTotalAmount.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrder.ColTotalAmount, 'Total');
  lblDescription.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrder.ColDescription, 'Description');
end;

procedure TfrmPurOrder.HelperProcess(Sender: TObject);
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

procedure TfrmPurOrder.RefreshData;
begin
  inherited;
  edtOrderNo.Text := Table.OrderNo;
  if Table.OrderDate > 0 then
    edtOrderDate.Text := DateToStr(Table.OrderDate)
  else
    edtOrderDate.Text := '';
  edtAccAccountId.Text := Table.AccountName;
  edtSupplierRefNo.Text := Table.SupplierRefNo;
  if Table.DeliveryDate > 0 then
    edtDeliveryDate.Text := DateToStr(Table.DeliveryDate)
  else
    edtDeliveryDate.Text := '';
  edtStkWarehouseId.Text := Table.WarehouseName;
  edtCurrency.Text := Table.Currency;
  edtExchangeRate.Text := CurrToStr(Table.ExchangeRate);
  edtPaymentTermDays.Text := IntToStr(Table.PaymentTermDays);
  edtStatusText.Text := TPurLookup.Text(plkOrderStatus, Table.Status);
  edtGrossAmount.Text := CurrToStr(Table.GrossAmount);
  edtDiscountAmount.Text := CurrToStr(Table.DiscountAmount);
  edtNetAmount.Text := CurrToStr(Table.NetAmount);
  edtVatAmount.Text := CurrToStr(Table.VatAmount);
  edtTotalAmount.Text := CurrToStr(Table.TotalAmount);
  edtDescription.Text := Table.Description;
end;

end.
