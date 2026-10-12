unit ufrmFinPosTransactions;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  FinPosTransaction.Service, FinPosTransaction, ufrmFinPosTransaction;

type
  TfrmFinPosTransactions = class(TfrmGrid<TFinPosTransaction, TFinPosTransactionService>)
  private
    FFixedMasterId: Int64;
    FFixedMasterName: string;
    FFixedCommissionRate: Currency;
    procedure TransactionTypeGetText(Sender: TField; var Text: string; DisplayText: Boolean);
  public
    procedure SetFixedPosTerminal(AMasterId: Int64; const AMasterName: string; ACommissionRate: Currency);
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure SetSelectedItem; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  FinLookup;

procedure TfrmFinPosTransactions.TransactionTypeGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if Sender.IsNull then
    Text := ''
  else
    Text := TFinLookup.Text(flkPosTxType, Sender.AsInteger);
end;
procedure TfrmFinPosTransactions.SetFixedPosTerminal(AMasterId: Int64; const AMasterName: string; ACommissionRate: Currency);
begin
  FFixedMasterId := AMasterId;
  FFixedMasterName := AMasterName;
  FFixedCommissionRate := ACommissionRate;
  AddFixedFilter('fin_pos_terminal_id', AMasterId);
end;

function TfrmFinPosTransactions.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
var
  LNew: TFinPosTransaction;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmFinPosTransaction.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
  begin
    LNew := TFinPosTransaction.Create;
    if FFixedMasterId > 0 then
    begin
      LNew.FinPosTerminalId := FFixedMasterId;
      LNew.PosName := FFixedMasterName;
      LNew.CommissionRate := FFixedCommissionRate;
    end;
    Result := TfrmFinPosTransaction.Create(Self, Service, LNew, AFormMode, Self.RefreshParentGrid);
  end
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmFinPosTransaction.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmFinPosTransactions.SetSelectedItem;

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
  Table.PosName := FieldText('pos_name');
  Table.Currency := FieldText('currency');
  Table.AccountCode := FieldText('account_code');
  Table.AccountName := FieldText('account_name');
end;

procedure TfrmFinPosTransactions.DefineColumnWidths;
var
  LField: TField;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('fin_pos_terminal_id', 0);
  SetColumnProperty('acc_account_id', 0);
  LField := Grd.DataSource.DataSet.FindField('transaction_type');
  if Assigned(LField) then
    LField.OnGetText := TransactionTypeGetText;
end;

procedure TfrmFinPosTransactions.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmFinPosTransactions.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TFinPosTransaction.TitlePlural, 'POS Collections');
  if FFixedMasterName <> '' then
    Self.Caption := Self.Caption + ' - ' + FFixedMasterName;
  SetColumnTitle('transaction_date', TLocalizationManager.Translate(TLangKeys.TFinPosTransaction.ColTransactionDate, 'Date'));
  SetColumnTitle('transaction_type', TLocalizationManager.Translate(TLangKeys.TFinPosTransaction.ColTransactionType, 'Transaction Type'));
  SetColumnTitle('amount', TLocalizationManager.Translate(TLangKeys.TFinPosTransaction.ColAmount, 'Amount'));
  SetColumnTitle('installment_count', TLocalizationManager.Translate(TLangKeys.TFinPosTransaction.ColInstallmentCount, 'Installments'));
  SetColumnTitle('commission_rate', TLocalizationManager.Translate(TLangKeys.TFinPosTransaction.ColCommissionRate, 'Commission Rate (%)'));
  SetColumnTitle('commission_amount', TLocalizationManager.Translate(TLangKeys.TFinPosTransaction.ColCommissionAmount, 'Commission Amount'));
  SetColumnTitle('net_amount', TLocalizationManager.Translate(TLangKeys.TFinPosTransaction.ColNetAmount, 'Net Amount'));
  SetColumnTitle('value_date', TLocalizationManager.Translate(TLangKeys.TFinPosTransaction.ColValueDate, 'Value Date'));
  SetColumnTitle('card_holder', TLocalizationManager.Translate(TLangKeys.TFinPosTransaction.ColCardHolder, 'Card Holder'));
  SetColumnTitle('card_last_digits', TLocalizationManager.Translate(TLangKeys.TFinPosTransaction.ColCardLastDigits, 'Card Last 4 Digits'));
  SetColumnTitle('description', TLocalizationManager.Translate(TLangKeys.TFinPosTransaction.ColDescription, 'Description'));
  SetColumnTitle('pos_name', TLocalizationManager.Translate(TLangKeys.TFinPosTransaction.ColPosName, 'POS'));
  SetColumnTitle('currency', TLocalizationManager.Translate(TLangKeys.TFinPosTransaction.ColCurrency, 'Currency'));
  SetColumnTitle('account_code', TLocalizationManager.Translate(TLangKeys.TFinPosTransaction.ColAccountCode, 'Account Code'));
  SetColumnTitle('account_name', TLocalizationManager.Translate(TLangKeys.TFinPosTransaction.ColAccountName, 'Account'));
end;

end.
