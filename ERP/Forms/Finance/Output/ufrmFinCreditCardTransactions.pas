unit ufrmFinCreditCardTransactions;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  FinCreditCardTransaction.Service, FinCreditCardTransaction, ufrmFinCreditCardTransaction;

type
  TfrmFinCreditCardTransactions = class(TfrmGrid<TFinCreditCardTransaction, TFinCreditCardTransactionService>)
  private
    FFixedMasterId: Int64;
    FFixedMasterName: string;
    procedure TransactionTypeGetText(Sender: TField; var Text: string; DisplayText: Boolean);
  public
    procedure SetFixedCreditCard(AMasterId: Int64; const AMasterName: string);
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

procedure TfrmFinCreditCardTransactions.TransactionTypeGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if Sender.IsNull then
    Text := ''
  else
    Text := TFinLookup.Text(flkCardTxType, Sender.AsInteger);
end;
procedure TfrmFinCreditCardTransactions.SetFixedCreditCard(AMasterId: Int64; const AMasterName: string);
begin
  FFixedMasterId := AMasterId;
  FFixedMasterName := AMasterName;
  AddFixedFilter('fin_credit_card_id', AMasterId);
end;

function TfrmFinCreditCardTransactions.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
var
  LNew: TFinCreditCardTransaction;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmFinCreditCardTransaction.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
  begin
    LNew := TFinCreditCardTransaction.Create;
    if FFixedMasterId > 0 then
    begin
      LNew.FinCreditCardId := FFixedMasterId;
      LNew.CardName := FFixedMasterName;
    end;
    Result := TfrmFinCreditCardTransaction.Create(Self, Service, LNew, AFormMode, Self.RefreshParentGrid);
  end
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmFinCreditCardTransaction.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmFinCreditCardTransactions.SetSelectedItem;

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
  Table.CardName := FieldText('card_name');
  Table.Currency := FieldText('currency');
  Table.AccountCode := FieldText('account_code');
  Table.AccountName := FieldText('account_name');
end;

procedure TfrmFinCreditCardTransactions.DefineColumnWidths;
var
  LField: TField;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('fin_credit_card_id', 0);
  SetColumnProperty('acc_account_id', 0);
  LField := Grd.DataSource.DataSet.FindField('transaction_type');
  if Assigned(LField) then
    LField.OnGetText := TransactionTypeGetText;
end;

procedure TfrmFinCreditCardTransactions.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmFinCreditCardTransactions.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TFinCreditCardTransaction.TitlePlural, 'Credit Card Transactions');
  if FFixedMasterName <> '' then
    Self.Caption := Self.Caption + ' - ' + FFixedMasterName;
  SetColumnTitle('transaction_date', TLocalizationManager.Translate(TLangKeys.TFinCreditCardTransaction.ColTransactionDate, 'Date'));
  SetColumnTitle('transaction_type', TLocalizationManager.Translate(TLangKeys.TFinCreditCardTransaction.ColTransactionType, 'Transaction Type'));
  SetColumnTitle('amount', TLocalizationManager.Translate(TLangKeys.TFinCreditCardTransaction.ColAmount, 'Amount'));
  SetColumnTitle('installment_count', TLocalizationManager.Translate(TLangKeys.TFinCreditCardTransaction.ColInstallmentCount, 'Installments'));
  SetColumnTitle('description', TLocalizationManager.Translate(TLangKeys.TFinCreditCardTransaction.ColDescription, 'Description'));
  SetColumnTitle('card_name', TLocalizationManager.Translate(TLangKeys.TFinCreditCardTransaction.ColCardName, 'Credit Card'));
  SetColumnTitle('currency', TLocalizationManager.Translate(TLangKeys.TFinCreditCardTransaction.ColCurrency, 'Currency'));
  SetColumnTitle('account_code', TLocalizationManager.Translate(TLangKeys.TFinCreditCardTransaction.ColAccountCode, 'Account Code'));
  SetColumnTitle('account_name', TLocalizationManager.Translate(TLangKeys.TFinCreditCardTransaction.ColAccountName, 'Account'));
  SetColumnTitle('installment_amount', TLocalizationManager.Translate(TLangKeys.TFinCreditCardTransaction.ColInstallmentAmount, 'Installment Amount'));
end;

end.
