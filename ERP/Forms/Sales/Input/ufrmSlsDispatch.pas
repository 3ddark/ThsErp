unit ufrmSlsDispatch;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  SlsDispatch.Service, SlsDispatch;

type
  TfrmSlsDispatch = class(TfrmInputSimpleDB<TSlsDispatch, TSlsDispatchService>)
    pnlContent: TPanel;
    lblDispatchNo: TLabel;
    edtDispatchNo: TEdit;
    lblDispatchDate: TLabel;
    edtDispatchDate: TEdit;
    lblAccAccountId: TLabel;
    edtAccAccountId: TEdit;
    lblStkWarehouseId: TLabel;
    edtStkWarehouseId: TEdit;
    lblSlsOrderId: TLabel;
    edtSlsOrderId: TEdit;
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
  SlsLookup,
  AccAccount, AccAccount.Service, ufrmAccAccounts,
  StkWarehouse, StkWarehouse.Service, ufrmStkWarehouses,
  SlsOrder, SlsOrder.Service, ufrmSlsOrders,
  SysCurrency, SysCurrency.Service, ufrmSysCurrencies;

procedure TfrmSlsDispatch.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.DispatchNo := edtDispatchNo.Text;
  Table.DispatchDate := StrToDateDef(edtDispatchDate.Text, 0);
  Table.Description := edtDescription.Text;
  inherited;
end;

procedure TfrmSlsDispatch.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtDispatchNo.thsInputDataType := itString;
  edtDispatchNo.CharCase := TEditCharCase.ecUpperCase;
  edtDispatchDate.thsInputDataType := itDate;
  edtAccAccountId.OnHelperProcess := HelperProcess;
  edtStkWarehouseId.OnHelperProcess := HelperProcess;
  edtSlsOrderId.OnHelperProcess := HelperProcess;
  edtCurrency.OnHelperProcess := HelperProcess;
  edtDescription.thsInputDataType := itString;
end;

procedure TfrmSlsDispatch.FormShow(Sender: TObject);
begin
  inherited;
  if edtDispatchDate.CanFocus then
    edtDispatchDate.SetFocus;
end;

procedure TfrmSlsDispatch.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.TitleSingular, 'Delivery Note');
  lblDispatchNo.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColDispatchNo, 'Delivery Note No');
  lblDispatchDate.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColDispatchDate, 'Delivery Note Date');
  lblAccAccountId.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColAccAccountId, 'Customer');
  lblStkWarehouseId.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColStkWarehouseId, 'Warehouse');
  lblSlsOrderId.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColSlsOrderId, 'Order');
  lblCurrency.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColCurrency, 'Currency');
  lblDescription.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColDescription, 'Description');
end;

procedure TfrmSlsDispatch.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmAccAccountId: TfrmAccAccounts;
  LFrmStkWarehouseId: TfrmStkWarehouses;
  LFrmSlsOrderId: TfrmSlsOrders;
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
  else if LEdit.Name = edtSlsOrderId.Name then
  begin
    LFrmSlsOrderId := TfrmSlsOrders.Create(LEdit, TSlsOrderService.Create, TSlsOrder.Create);
    try
      LFrmSlsOrderId.IsHelper := True;
      LFrmSlsOrderId.ShowModal;
      if LFrmSlsOrderId.DataTransfer then
        if LFrmSlsOrderId.CleanAndClose then
        begin
          Table.SlsOrderId := 0;
          Table.OrderNo := '';
          LEdit.Clear;
        end
        else
        begin
          Table.SlsOrderId := LFrmSlsOrderId.Table.Id;
          Table.OrderNo := LFrmSlsOrderId.Table.OrderNo;
          LEdit.Text := Table.OrderNo;
        end;
      // Sipariş seçilince müşteri / ambar / para birimi siparişten gelir
      if LFrmSlsOrderId.DataTransfer and not LFrmSlsOrderId.CleanAndClose then
      begin
        Table.AccAccountId := LFrmSlsOrderId.Table.AccAccountId;
        Table.AccountName := LFrmSlsOrderId.Table.AccountName;
        edtAccAccountId.Text := Table.AccountName;
        Table.Currency := LFrmSlsOrderId.Table.Currency;
        edtCurrency.Text := Table.Currency;
        if LFrmSlsOrderId.Table.StkWarehouseId > 0 then
        begin
          Table.StkWarehouseId := LFrmSlsOrderId.Table.StkWarehouseId;
          Table.WarehouseName := LFrmSlsOrderId.Table.WarehouseName;
          edtStkWarehouseId.Text := Table.WarehouseName;
        end;
      end;
    finally
      LFrmSlsOrderId.Free;
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

procedure TfrmSlsDispatch.RefreshData;
begin
  inherited;
  edtDispatchNo.Text := Table.DispatchNo;
  if Table.DispatchDate > 0 then
    edtDispatchDate.Text := DateToStr(Table.DispatchDate)
  else
    edtDispatchDate.Text := '';
  edtAccAccountId.Text := Table.AccountName;
  edtStkWarehouseId.Text := Table.WarehouseName;
  edtSlsOrderId.Text := Table.OrderNo;
  edtCurrency.Text := Table.Currency;
  edtDescription.Text := Table.Description;
end;

end.
