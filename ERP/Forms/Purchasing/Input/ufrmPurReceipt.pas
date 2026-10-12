unit ufrmPurReceipt;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  PurReceipt.Service, PurReceipt;

type
  TfrmPurReceipt = class(TfrmInputSimpleDB<TPurReceipt, TPurReceiptService>)
    pnlContent: TPanel;
    lblReceiptNo: TLabel;
    edtReceiptNo: TEdit;
    lblReceiptDate: TLabel;
    edtReceiptDate: TEdit;
    lblAccAccountId: TLabel;
    edtAccAccountId: TEdit;
    lblStkWarehouseId: TLabel;
    edtStkWarehouseId: TEdit;
    lblWaybillNo: TLabel;
    edtWaybillNo: TEdit;
    lblPurOrderId: TLabel;
    edtPurOrderId: TEdit;
    lblCurrency: TLabel;
    edtCurrency: TEdit;
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
  PurOrder, PurOrder.Service, ufrmPurOrders,
  SysCurrency, SysCurrency.Service, ufrmSysCurrencies;

procedure TfrmPurReceipt.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.ReceiptNo := edtReceiptNo.Text;
  Table.ReceiptDate := StrToDateDef(edtReceiptDate.Text, 0);
  Table.WaybillNo := edtWaybillNo.Text;
  Table.Description := edtDescription.Text;
  inherited;
end;

procedure TfrmPurReceipt.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtReceiptNo.thsInputDataType := itString;
  edtReceiptNo.CharCase := TEditCharCase.ecUpperCase;
  edtReceiptDate.thsInputDataType := itDate;
  edtAccAccountId.OnHelperProcess := HelperProcess;
  edtStkWarehouseId.OnHelperProcess := HelperProcess;
  edtWaybillNo.thsInputDataType := itString;
  edtWaybillNo.CharCase := TEditCharCase.ecUpperCase;
  edtPurOrderId.OnHelperProcess := HelperProcess;
  edtCurrency.OnHelperProcess := HelperProcess;
  edtDescription.thsInputDataType := itString;
end;

procedure TfrmPurReceipt.FormShow(Sender: TObject);
begin
  inherited;
  if edtReceiptDate.CanFocus then
    edtReceiptDate.SetFocus;
end;

procedure TfrmPurReceipt.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TPurReceipt.TitleSingular, 'Goods Receipt');
  lblReceiptNo.Caption := TLocalizationManager.Translate(TLangKeys.TPurReceipt.ColReceiptNo, 'Receipt No');
  lblReceiptDate.Caption := TLocalizationManager.Translate(TLangKeys.TPurReceipt.ColReceiptDate, 'Receipt Date');
  lblAccAccountId.Caption := TLocalizationManager.Translate(TLangKeys.TPurReceipt.ColAccAccountId, 'Supplier');
  lblStkWarehouseId.Caption := TLocalizationManager.Translate(TLangKeys.TPurReceipt.ColStkWarehouseId, 'Warehouse');
  lblWaybillNo.Caption := TLocalizationManager.Translate(TLangKeys.TPurReceipt.ColWaybillNo, 'Supplier Waybill No');
  lblPurOrderId.Caption := TLocalizationManager.Translate(TLangKeys.TPurReceipt.ColPurOrderId, 'Order');
  lblCurrency.Caption := TLocalizationManager.Translate(TLangKeys.TPurReceipt.ColCurrency, 'Currency');
  lblDescription.Caption := TLocalizationManager.Translate(TLangKeys.TPurReceipt.ColDescription, 'Description');
end;

procedure TfrmPurReceipt.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmAccAccountId: TfrmAccAccounts;
  LFrmStkWarehouseId: TfrmStkWarehouses;
  LFrmPurOrderId: TfrmPurOrders;
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
  else if LEdit.Name = edtPurOrderId.Name then
  begin
    LFrmPurOrderId := TfrmPurOrders.Create(LEdit, TPurOrderService.Create, TPurOrder.Create);
    try
      LFrmPurOrderId.IsHelper := True;
      LFrmPurOrderId.ShowModal;
      if LFrmPurOrderId.DataTransfer then
        if LFrmPurOrderId.CleanAndClose then
        begin
          Table.PurOrderId := 0;
          Table.OrderNo := '';
          LEdit.Clear;
        end
        else
        begin
          Table.PurOrderId := LFrmPurOrderId.Table.Id;
          Table.OrderNo := LFrmPurOrderId.Table.OrderNo;
          LEdit.Text := Table.OrderNo;
        end;
      // Sipariş seçilince tedarikçi / ambar / para birimi siparişten gelir
      if LFrmPurOrderId.DataTransfer and not LFrmPurOrderId.CleanAndClose then
      begin
        Table.AccAccountId := LFrmPurOrderId.Table.AccAccountId;
        Table.AccountName := LFrmPurOrderId.Table.AccountName;
        edtAccAccountId.Text := Table.AccountName;
        Table.Currency := LFrmPurOrderId.Table.Currency;
        edtCurrency.Text := Table.Currency;
        if LFrmPurOrderId.Table.StkWarehouseId > 0 then
        begin
          Table.StkWarehouseId := LFrmPurOrderId.Table.StkWarehouseId;
          Table.WarehouseName := LFrmPurOrderId.Table.WarehouseName;
          edtStkWarehouseId.Text := Table.WarehouseName;
        end;
      end;
    finally
      LFrmPurOrderId.Free;
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

procedure TfrmPurReceipt.RefreshData;
begin
  inherited;
  edtReceiptNo.Text := Table.ReceiptNo;
  if Table.ReceiptDate > 0 then
    edtReceiptDate.Text := DateToStr(Table.ReceiptDate)
  else
    edtReceiptDate.Text := '';
  edtAccAccountId.Text := Table.AccountName;
  edtStkWarehouseId.Text := Table.WarehouseName;
  edtWaybillNo.Text := Table.WaybillNo;
  edtPurOrderId.Text := Table.OrderNo;
  edtCurrency.Text := Table.Currency;
  edtDescription.Text := Table.Description;
end;

end.
