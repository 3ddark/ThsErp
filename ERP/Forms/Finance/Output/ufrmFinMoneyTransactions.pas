unit ufrmFinMoneyTransactions;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  FinMoneyTransaction.Service, FinMoneyTransaction, ufrmFinMoneyTransaction;

type
  TfrmFinMoneyTransactions = class(TfrmGrid<TFinMoneyTransaction, TFinMoneyTransactionService>)
  private
    FFixedMasterId: Int64;
    FFixedMasterName: string;
    FFixedCurrency: string;
    procedure TransactionTypeGetText(Sender: TField; var Text: string; DisplayText: Boolean);
    procedure TransferMethodGetText(Sender: TField; var Text: string; DisplayText: Boolean);
    procedure AccountKindGetText(Sender: TField; var Text: string; DisplayText: Boolean);
  public
    procedure SetFixedMoneyAccount(AMasterId: Int64; const AMasterName, ACurrency: string);
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

procedure TfrmFinMoneyTransactions.TransactionTypeGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if Sender.IsNull then
    Text := ''
  else
    Text := TFinLookup.Text(flkMoneyTxType, Sender.AsInteger);
end;

procedure TfrmFinMoneyTransactions.TransferMethodGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if Sender.IsNull then
    Text := ''
  else
    Text := TFinLookup.Text(flkTransferMethod, Sender.AsInteger);
end;

procedure TfrmFinMoneyTransactions.AccountKindGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if Sender.IsNull then
    Text := ''
  else
    Text := TFinLookup.Text(flkMoneyAccountKind, Sender.AsInteger);
end;
procedure TfrmFinMoneyTransactions.SetFixedMoneyAccount(AMasterId: Int64; const AMasterName, ACurrency: string);
begin
  FFixedMasterId := AMasterId;
  FFixedMasterName := AMasterName;
  FFixedCurrency := ACurrency;
  AddFixedFilter('fin_money_account_id', AMasterId);
end;

function TfrmFinMoneyTransactions.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
var
  LNew: TFinMoneyTransaction;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmFinMoneyTransaction.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
  begin
    LNew := TFinMoneyTransaction.Create;
    if FFixedMasterId > 0 then
    begin
      LNew.FinMoneyAccountId := FFixedMasterId;
      LNew.MoneyAccountName := FFixedMasterName;
      LNew.Currency := FFixedCurrency;
    end;
    Result := TfrmFinMoneyTransaction.Create(Self, Service, LNew, AFormMode, Self.RefreshParentGrid);
  end
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmFinMoneyTransaction.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmFinMoneyTransactions.SetSelectedItem;

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
  Table.MoneyAccountName := FieldText('money_account_name');
  Table.Currency := FieldText('currency');
  Table.AccountCode := FieldText('account_code');
  Table.AccountName := FieldText('account_name');
  Table.TargetMoneyAccountName := FieldText('target_money_account_name');
end;

procedure TfrmFinMoneyTransactions.DefineColumnWidths;
var
  LField: TField;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('fin_money_account_id', 0);
  SetColumnProperty('acc_account_id', 0);
  SetColumnProperty('target_fin_money_account_id', 0);
  LField := Grd.DataSource.DataSet.FindField('transaction_type');
  if Assigned(LField) then
    LField.OnGetText := TransactionTypeGetText;
  LField := Grd.DataSource.DataSet.FindField('transfer_method');
  if Assigned(LField) then
    LField.OnGetText := TransferMethodGetText;
  LField := Grd.DataSource.DataSet.FindField('account_kind');
  if Assigned(LField) then
    LField.OnGetText := AccountKindGetText;
end;

procedure TfrmFinMoneyTransactions.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmFinMoneyTransactions.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TFinMoneyTransaction.TitlePlural, 'Receipts / Payments / Transfers');
  if FFixedMasterName <> '' then
    Self.Caption := Self.Caption + ' - ' + FFixedMasterName;
  SetColumnTitle('transaction_date', TLocalizationManager.Translate(TLangKeys.TFinMoneyTransaction.ColTransactionDate, 'Date'));
  SetColumnTitle('transaction_type', TLocalizationManager.Translate(TLangKeys.TFinMoneyTransaction.ColTransactionType, 'Transaction Type'));
  SetColumnTitle('transfer_method', TLocalizationManager.Translate(TLangKeys.TFinMoneyTransaction.ColTransferMethod, 'Transfer Method'));
  SetColumnTitle('amount', TLocalizationManager.Translate(TLangKeys.TFinMoneyTransaction.ColAmount, 'Amount'));
  SetColumnTitle('document_no', TLocalizationManager.Translate(TLangKeys.TFinMoneyTransaction.ColDocumentNo, 'Document / Receipt No'));
  SetColumnTitle('counterparty_name', TLocalizationManager.Translate(TLangKeys.TFinMoneyTransaction.ColCounterpartyName, 'Sender / Receiver'));
  SetColumnTitle('counterparty_iban', TLocalizationManager.Translate(TLangKeys.TFinMoneyTransaction.ColCounterpartyIban, 'Sender / Receiver IBAN'));
  SetColumnTitle('description', TLocalizationManager.Translate(TLangKeys.TFinMoneyTransaction.ColDescription, 'Description'));
  SetColumnTitle('money_account_name', TLocalizationManager.Translate(TLangKeys.TFinMoneyTransaction.ColMoneyAccountName, 'Cash / Bank Account'));
  SetColumnTitle('currency', TLocalizationManager.Translate(TLangKeys.TFinMoneyTransaction.ColCurrency, 'Currency'));
  SetColumnTitle('account_code', TLocalizationManager.Translate(TLangKeys.TFinMoneyTransaction.ColAccountCode, 'Account Code'));
  SetColumnTitle('account_name', TLocalizationManager.Translate(TLangKeys.TFinMoneyTransaction.ColAccountName, 'Account'));
  SetColumnTitle('target_money_account_name', TLocalizationManager.Translate(TLangKeys.TFinMoneyTransaction.ColTargetMoneyAccountName, 'Target Account (Transfer)'));
  SetColumnTitle('account_kind', TLocalizationManager.Translate(TLangKeys.TFinMoneyTransaction.ColAccountKind, 'Account Kind'));
end;

end.
