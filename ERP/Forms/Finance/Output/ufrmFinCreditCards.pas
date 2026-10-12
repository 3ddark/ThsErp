unit ufrmFinCreditCards;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  FinCreditCard.Service, FinCreditCard, ufrmFinCreditCard;

type
  TfrmFinCreditCards = class(TfrmGrid<TFinCreditCard, TFinCreditCardService>)
  private
    FmniTransactions: TMenuItem;
    procedure mniTransactionsClick(Sender: TObject);

  public
    procedure PreparePopupMenu; override;
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure SetSelectedItem; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  FinLookup,
  ufrmFinCreditCardTransactions, FinCreditCardTransaction, FinCreditCardTransaction.Service;

procedure TfrmFinCreditCards.mniTransactionsClick(Sender: TObject);
var
  LFrm: TfrmFinCreditCardTransactions;
begin
  if Grd.DataSource.DataSet.IsEmpty then
    Exit;

  SetSelectedItem;
  LFrm := TfrmFinCreditCardTransactions.Create(Self, TFinCreditCardTransactionService.Create, TFinCreditCardTransaction.Create);
  LFrm.SetFixedCreditCard(Table.Id, Table.CardName);
  LFrm.Show;
end;

procedure TfrmFinCreditCards.PreparePopupMenu;
begin
  inherited;
  if IsHelper then
    Exit;

  AddPopupMenuSpliter();
  FmniTransactions := AddMenu(TLocalizationManager.Translate(TLangKeys.TFinCreditCard.MenuTransactions, 'Transactions'), 'mniTransactions', mniTransactionsClick);
end;

function TfrmFinCreditCards.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmFinCreditCard.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmFinCreditCard.Create(Self, Service, TFinCreditCard.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmFinCreditCard.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmFinCreditCards.SetSelectedItem;

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
  Table.BankName := FieldText('bank_name');
  Table.AccountName := FieldText('account_name');
end;

procedure TfrmFinCreditCards.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('acc_bank_id', 0);

end;

procedure TfrmFinCreditCards.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmFinCreditCards.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TFinCreditCard.TitlePlural, 'Company Credit Cards');
  SetColumnTitle('card_name', TLocalizationManager.Translate(TLangKeys.TFinCreditCard.ColCardName, 'Card Name'));
  SetColumnTitle('card_holder', TLocalizationManager.Translate(TLangKeys.TFinCreditCard.ColCardHolder, 'Card Holder'));
  SetColumnTitle('card_last_digits', TLocalizationManager.Translate(TLangKeys.TFinCreditCard.ColCardLastDigits, 'Card Last 4 Digits'));
  SetColumnTitle('card_limit', TLocalizationManager.Translate(TLangKeys.TFinCreditCard.ColCardLimit, 'Card Limit'));
  SetColumnTitle('statement_day', TLocalizationManager.Translate(TLangKeys.TFinCreditCard.ColStatementDay, 'Statement Day'));
  SetColumnTitle('payment_day', TLocalizationManager.Translate(TLangKeys.TFinCreditCard.ColPaymentDay, 'Payment Day'));
  SetColumnTitle('currency', TLocalizationManager.Translate(TLangKeys.TFinCreditCard.ColCurrency, 'Currency'));
  SetColumnTitle('acc_account_code', TLocalizationManager.Translate(TLangKeys.TFinCreditCard.ColAccAccountCode, 'Accounting Account'));
  SetColumnTitle('is_active', TLocalizationManager.Translate(TLangKeys.TFinCreditCard.ColIsActive, 'Active'));
  SetColumnTitle('notes', TLocalizationManager.Translate(TLangKeys.TFinCreditCard.ColNotes, 'Notes'));
  SetColumnTitle('bank_name', TLocalizationManager.Translate(TLangKeys.TFinCreditCard.ColBankName, 'Bank'));
  SetColumnTitle('account_name', TLocalizationManager.Translate(TLangKeys.TFinCreditCard.ColAccountName, 'Accounting Account Name'));
  SetColumnTitle('total_spending', TLocalizationManager.Translate(TLangKeys.TFinCreditCard.ColTotalSpending, 'Total Spending'));
  SetColumnTitle('total_payment', TLocalizationManager.Translate(TLangKeys.TFinCreditCard.ColTotalPayment, 'Total Payment'));
  SetColumnTitle('balance', TLocalizationManager.Translate(TLangKeys.TFinCreditCard.ColBalance, 'Balance'));
  SetColumnTitle('available_limit', TLocalizationManager.Translate(TLangKeys.TFinCreditCard.ColAvailableLimit, 'Available Limit'));
  if Assigned(FmniTransactions) then
    FmniTransactions.Caption := TLocalizationManager.Translate(TLangKeys.TFinCreditCard.MenuTransactions, 'Transactions');
end;

end.
