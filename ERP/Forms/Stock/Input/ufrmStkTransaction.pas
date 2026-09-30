unit ufrmStkTransaction;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox,
  StkTransaction.Service, StkTransaction;

type
  TfrmStkTransaction = class(TfrmInputSimpleDB<TStkTransaction, TStkTransactionService>)
    pnlContent: TPanel;
    lblTransactionDate: TLabel;
    edtTransactionDate: TEdit;
    lblTransactionType: TLabel;
    cbbTransactionType: TComboBox;
    lblStkInventoryId: TLabel;
    edtStkInventoryId: TEdit;
    lblFromStkWarehouseId: TLabel;
    edtFromStkWarehouseId: TEdit;
    lblToStkWarehouseId: TLabel;
    edtToStkWarehouseId: TEdit;
    lblQuantity: TLabel;
    edtQuantity: TEdit;
    lblAmount: TLabel;
    edtAmount: TEdit;
    lblAmountForeign: TLabel;
    edtAmountForeign: TEdit;
    lblCurrency: TLabel;
    edtCurrency: TEdit;
    lblIsOpening: TLabel;
    chkIsOpening: TCheckBox;
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
  StkLookup,
  StkInventory, StkInventory.Service, ufrmStkInventories,                       // TfrmStkInventories helper output form
  StkWarehouse, StkWarehouse.Service, ufrmStkWarehouses,                        // TfrmStkWarehouses helper output form
  SysCurrency, SysCurrency.Service, ufrmSysCurrencies;                          // TfrmSysCurrencies helper output form

procedure TfrmStkTransaction.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.TransactionDate := StrToDateDef(edtTransactionDate.Text, 0);
  Table.TransactionType := cbbTransactionType.ItemIndex + 1;  // seçim yoksa 0 -> zorunluluk kontrolü
  Table.Quantity := StrToCurrDef(edtQuantity.Text, 0);
  Table.Amount := StrToCurrDef(edtAmount.Text, 0);
  Table.AmountForeign := StrToCurrDef(edtAmountForeign.Text, 0);
  Table.IsOpening := chkIsOpening.Checked;
  Table.Description := edtDescription.Text;
  inherited;
end;

procedure TfrmStkTransaction.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtStkInventoryId.OnHelperProcess := HelperProcess;
  edtFromStkWarehouseId.OnHelperProcess := HelperProcess;
  edtToStkWarehouseId.OnHelperProcess := HelperProcess;
  edtCurrency.OnHelperProcess := HelperProcess;
  edtTransactionDate.thsInputDataType := itDate;
  TStkLookup.FillItems(cbbTransactionType.Items, slkTransactionType);
  edtQuantity.thsInputDataType := itFloat;
  edtAmount.thsInputDataType := itFloat;
  edtAmountForeign.thsInputDataType := itFloat;
  edtDescription.thsInputDataType := itString;
end;

procedure TfrmStkTransaction.FormShow(Sender: TObject);
begin
  inherited;
  if edtTransactionDate.CanFocus then
    edtTransactionDate.SetFocus;
end;

procedure TfrmStkTransaction.ApplyLocalization;
var
  LIndex: Integer;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TStkTransaction.TitleSingular, 'Stock Transaction');
  lblTransactionDate.Caption := TLocalizationManager.Translate(TLangKeys.TStkTransaction.ColTransactionDate, 'Date');
  lblTransactionType.Caption := TLocalizationManager.Translate(TLangKeys.TStkTransaction.ColTransactionType, 'Transaction Type');
  lblStkInventoryId.Caption := TLocalizationManager.Translate(TLangKeys.TStkTransaction.ColInventory, 'Stock Card');
  lblFromStkWarehouseId.Caption := TLocalizationManager.Translate(TLangKeys.TStkTransaction.ColFromWarehouse, 'From Warehouse');
  lblToStkWarehouseId.Caption := TLocalizationManager.Translate(TLangKeys.TStkTransaction.ColToWarehouse, 'To Warehouse');
  lblQuantity.Caption := TLocalizationManager.Translate(TLangKeys.TStkTransaction.ColQuantity, 'Quantity');
  lblAmount.Caption := TLocalizationManager.Translate(TLangKeys.TStkTransaction.ColAmount, 'Amount');
  lblAmountForeign.Caption := TLocalizationManager.Translate(TLangKeys.TStkTransaction.ColAmountForeign, 'Foreign Amount');
  lblCurrency.Caption := TLocalizationManager.Translate(TLangKeys.TStkTransaction.ColCurrency, 'Currency');
  lblIsOpening.Caption := TLocalizationManager.Translate(TLangKeys.TStkTransaction.ColIsOpening, 'Opening Balance');
  lblDescription.Caption := TLocalizationManager.Translate(TLangKeys.TStkTransaction.ColDescription, 'Description');
  LIndex := cbbTransactionType.ItemIndex;
  TStkLookup.FillItems(cbbTransactionType.Items, slkTransactionType);
  cbbTransactionType.ItemIndex := LIndex;
end;

procedure TfrmStkTransaction.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmStkInventoryId: TfrmStkInventories;
  LFrmFromStkWarehouseId: TfrmStkWarehouses;
  LFrmToStkWarehouseId: TfrmStkWarehouses;
  LFrmCurrency: TfrmSysCurrencies;
begin
  if not (Sender is TEdit) then
    Exit;

  LEdit := (Sender as TEdit);
  if LEdit.Name = edtStkInventoryId.Name then
  begin
    LFrmStkInventoryId := TfrmStkInventories.Create(LEdit, TStkInventoryService.Create, TStkInventory.Create);
    try
      LFrmStkInventoryId.IsHelper := True;
      LFrmStkInventoryId.ShowModal;
      if LFrmStkInventoryId.DataTransfer then
        if LFrmStkInventoryId.CleanAndClose then
        begin
          Table.StkInventoryId := 0;
          Table.InventoryName := '';
          LEdit.Clear;
        end
        else
        begin
          Table.StkInventoryId := LFrmStkInventoryId.Table.Id;
          Table.InventoryName := LFrmStkInventoryId.Table.Name;
          LEdit.Text := Table.InventoryName;
        end;
    finally
      LFrmStkInventoryId.Free;
    end;
  end
  else if LEdit.Name = edtFromStkWarehouseId.Name then
  begin
    LFrmFromStkWarehouseId := TfrmStkWarehouses.Create(LEdit, TStkWarehouseService.Create, TStkWarehouse.Create);
    try
      LFrmFromStkWarehouseId.IsHelper := True;
      LFrmFromStkWarehouseId.ShowModal;
      if LFrmFromStkWarehouseId.DataTransfer then
        if LFrmFromStkWarehouseId.CleanAndClose then
        begin
          Table.FromStkWarehouseId := 0;
          Table.FromWarehouseName := '';
          LEdit.Clear;
        end
        else
        begin
          Table.FromStkWarehouseId := LFrmFromStkWarehouseId.Table.Id;
          Table.FromWarehouseName := LFrmFromStkWarehouseId.Table.WarehouseName;
          LEdit.Text := Table.FromWarehouseName;
        end;
    finally
      LFrmFromStkWarehouseId.Free;
    end;
  end
  else if LEdit.Name = edtToStkWarehouseId.Name then
  begin
    LFrmToStkWarehouseId := TfrmStkWarehouses.Create(LEdit, TStkWarehouseService.Create, TStkWarehouse.Create);
    try
      LFrmToStkWarehouseId.IsHelper := True;
      LFrmToStkWarehouseId.ShowModal;
      if LFrmToStkWarehouseId.DataTransfer then
        if LFrmToStkWarehouseId.CleanAndClose then
        begin
          Table.ToStkWarehouseId := 0;
          Table.ToWarehouseName := '';
          LEdit.Clear;
        end
        else
        begin
          Table.ToStkWarehouseId := LFrmToStkWarehouseId.Table.Id;
          Table.ToWarehouseName := LFrmToStkWarehouseId.Table.WarehouseName;
          LEdit.Text := Table.ToWarehouseName;
        end;
    finally
      LFrmToStkWarehouseId.Free;
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

procedure TfrmStkTransaction.RefreshData;
begin
  inherited;
  if Table.TransactionDate > 0 then
    edtTransactionDate.Text := DateToStr(Table.TransactionDate)
  else
    edtTransactionDate.Text := '';
  cbbTransactionType.ItemIndex := Table.TransactionType - 1;
  edtStkInventoryId.Text := Table.InventoryName;
  edtFromStkWarehouseId.Text := Table.FromWarehouseName;
  edtToStkWarehouseId.Text := Table.ToWarehouseName;
  edtQuantity.Text := CurrToStr(Table.Quantity);
  edtAmount.Text := CurrToStr(Table.Amount);
  edtAmountForeign.Text := CurrToStr(Table.AmountForeign);
  edtCurrency.Text := Table.Currency;
  chkIsOpening.Checked := Table.IsOpening;
  edtDescription.Text := Table.Description;
end;

end.
