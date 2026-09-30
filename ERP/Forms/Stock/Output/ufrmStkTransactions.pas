unit ufrmStkTransactions;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  StkTransaction.Service, StkTransaction, ufrmStkTransaction;

type
  TfrmStkTransactions = class(TfrmGrid<TStkTransaction, TStkTransactionService>)
  private
    FFixedInventoryId: Int64;
    FFixedInventoryName: string;
    procedure TransactionTypeGetText(Sender: TField; var Text: string; DisplayText: Boolean);
  public
    procedure SetFixedInventory(AInventoryId: Int64; const AInventoryName: string);

    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure SetSelectedItem; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  StkLookup;

procedure TfrmStkTransactions.TransactionTypeGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if Sender.IsNull then
    Text := ''
  else
    Text := TStkLookup.Text(slkTransactionType, Sender.AsInteger);
end;

procedure TfrmStkTransactions.SetFixedInventory(AInventoryId: Int64; const AInventoryName: string);
begin
  FFixedInventoryId := AInventoryId;
  FFixedInventoryName := AInventoryName;
  AddFixedFilter('stk_inventory_id', AInventoryId);
end;

function TfrmStkTransactions.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
var
  LNew: TStkTransaction;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmStkTransaction.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
  begin
    LNew := TStkTransaction.Create;
    if FFixedInventoryId > 0 then
    begin
      LNew.StkInventoryId := FFixedInventoryId;
      LNew.InventoryName := FFixedInventoryName;
    end;
    Result := TfrmStkTransaction.Create(Self, Service, LNew, AFormMode, Self.RefreshParentGrid);
  end
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmStkTransaction.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmStkTransactions.SetSelectedItem;

  function FieldText(const AFieldName: string): string;
  var
    LField: TField;
  begin
    LField := Grd.DataSource.DataSet.FindField(AFieldName);
    if Assigned(LField) then
      Result := LField.AsString
    else
      Result := '';
  end;

begin
  inherited;
  Table.InventoryName := FieldText('inventory_name');
  Table.FromWarehouseName := FieldText('from_warehouse_name');
  Table.ToWarehouseName := FieldText('to_warehouse_name');
  Table.InventoryCode := FieldText('inventory_code');
end;

procedure TfrmStkTransactions.DefineColumnWidths;
var
  LField: TField;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('stk_inventory_id', 0);
  SetColumnProperty('from_stk_warehouse_id', 0);
  SetColumnProperty('to_stk_warehouse_id', 0);
  SetColumnProperty('dispatch_id', 0);
  SetColumnProperty('production_id', 0);

  // Sayısal seçenek değerleri aktif dile göre metin olarak gösterilir
  LField := Grd.DataSource.DataSet.FindField('transaction_type');
  if Assigned(LField) then
    LField.OnGetText := TransactionTypeGetText;
end;

procedure TfrmStkTransactions.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmStkTransactions.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TStkTransaction.TitlePlural, 'Stock Transactions');
  if FFixedInventoryName <> '' then
    Self.Caption := Self.Caption + ' - ' + FFixedInventoryName;
  SetColumnTitle('transaction_date', TLocalizationManager.Translate(TLangKeys.TStkTransaction.ColTransactionDate, 'Date'));
  SetColumnTitle('transaction_type', TLocalizationManager.Translate(TLangKeys.TStkTransaction.ColTransactionType, 'Transaction Type'));
  SetColumnTitle('inventory_name', TLocalizationManager.Translate(TLangKeys.TStkTransaction.ColInventory, 'Stock Card'));
  SetColumnTitle('from_warehouse_name', TLocalizationManager.Translate(TLangKeys.TStkTransaction.ColFromWarehouse, 'From Warehouse'));
  SetColumnTitle('to_warehouse_name', TLocalizationManager.Translate(TLangKeys.TStkTransaction.ColToWarehouse, 'To Warehouse'));
  SetColumnTitle('quantity', TLocalizationManager.Translate(TLangKeys.TStkTransaction.ColQuantity, 'Quantity'));
  SetColumnTitle('amount', TLocalizationManager.Translate(TLangKeys.TStkTransaction.ColAmount, 'Amount'));
  SetColumnTitle('amount_foreign', TLocalizationManager.Translate(TLangKeys.TStkTransaction.ColAmountForeign, 'Foreign Amount'));
  SetColumnTitle('currency', TLocalizationManager.Translate(TLangKeys.TStkTransaction.ColCurrency, 'Currency'));
  SetColumnTitle('is_opening', TLocalizationManager.Translate(TLangKeys.TStkTransaction.ColIsOpening, 'Opening Balance'));
  SetColumnTitle('description', TLocalizationManager.Translate(TLangKeys.TStkTransaction.ColDescription, 'Description'));
  SetColumnTitle('inventory_code', TLocalizationManager.Translate(TLangKeys.TStkTransaction.ColInventoryCode, 'Stock Code'));
end;

end.
