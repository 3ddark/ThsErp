unit ufrmFinMoneyAccounts;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  FinMoneyAccount.Service, FinMoneyAccount, ufrmFinMoneyAccount;

type
  TfrmFinMoneyAccounts = class(TfrmGrid<TFinMoneyAccount, TFinMoneyAccountService>)
  private
    FmniLedger: TMenuItem;
    FmniTransactions: TMenuItem;
    procedure mniLedgerClick(Sender: TObject);
    procedure mniTransactionsClick(Sender: TObject);
    procedure AccountKindGetText(Sender: TField; var Text: string; DisplayText: Boolean);
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
  ufrmFinMoneyLedgers, FinMoneyLedger, FinMoneyLedger.Service,
  ufrmFinMoneyTransactions, FinMoneyTransaction, FinMoneyTransaction.Service;

procedure TfrmFinMoneyAccounts.AccountKindGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if Sender.IsNull then
    Text := ''
  else
    Text := TFinLookup.Text(flkMoneyAccountKind, Sender.AsInteger);
end;
procedure TfrmFinMoneyAccounts.mniLedgerClick(Sender: TObject);
var
  LFrm: TfrmFinMoneyLedgers;
begin
  if Grd.DataSource.DataSet.IsEmpty then
    Exit;

  SetSelectedItem;
  LFrm := TfrmFinMoneyLedgers.Create(Self, TFinMoneyLedgerService.Create, TFinMoneyLedger.Create);
  LFrm.SetFixedMoneyAccount(Table.Id, Table.Name);
  LFrm.Show;
end;

procedure TfrmFinMoneyAccounts.mniTransactionsClick(Sender: TObject);
var
  LFrm: TfrmFinMoneyTransactions;
begin
  if Grd.DataSource.DataSet.IsEmpty then
    Exit;

  SetSelectedItem;
  LFrm := TfrmFinMoneyTransactions.Create(Self, TFinMoneyTransactionService.Create, TFinMoneyTransaction.Create);
  LFrm.SetFixedMoneyAccount(Table.Id, Table.Name, Table.Currency);
  LFrm.Show;
end;

procedure TfrmFinMoneyAccounts.PreparePopupMenu;
begin
  inherited;
  if IsHelper then
    Exit;

  AddPopupMenuSpliter();
  FmniLedger := AddMenu(TLocalizationManager.Translate(TLangKeys.TFinMoneyAccount.MenuLedger, 'Account Statement'), 'mniLedger', mniLedgerClick);
  FmniTransactions := AddMenu(TLocalizationManager.Translate(TLangKeys.TFinMoneyAccount.MenuTransactions, 'Transactions'), 'mniTransactions', mniTransactionsClick);
end;

function TfrmFinMoneyAccounts.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmFinMoneyAccount.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmFinMoneyAccount.Create(Self, Service, TFinMoneyAccount.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmFinMoneyAccount.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmFinMoneyAccounts.SetSelectedItem;

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
  Table.BranchName := FieldText('branch_name');
  Table.AccountName := FieldText('account_name');
end;

procedure TfrmFinMoneyAccounts.DefineColumnWidths;
var
  LField: TField;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('acc_bank_id', 0);
  SetColumnProperty('acc_bank_branch_id', 0);
  LField := Grd.DataSource.DataSet.FindField('account_kind');
  if Assigned(LField) then
    LField.OnGetText := AccountKindGetText;
end;

procedure TfrmFinMoneyAccounts.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmFinMoneyAccounts.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TFinMoneyAccount.TitlePlural, 'Cash / Bank Accounts');
  SetColumnTitle('account_kind', TLocalizationManager.Translate(TLangKeys.TFinMoneyAccount.ColAccountKind, 'Account Kind'));
  SetColumnTitle('code', TLocalizationManager.Translate(TLangKeys.TFinMoneyAccount.ColCode, 'Code'));
  SetColumnTitle('name', TLocalizationManager.Translate(TLangKeys.TFinMoneyAccount.ColName, 'Name'));
  SetColumnTitle('account_no', TLocalizationManager.Translate(TLangKeys.TFinMoneyAccount.ColAccountNo, 'Account No'));
  SetColumnTitle('iban', TLocalizationManager.Translate(TLangKeys.TFinMoneyAccount.ColIban, 'IBAN'));
  SetColumnTitle('currency', TLocalizationManager.Translate(TLangKeys.TFinMoneyAccount.ColCurrency, 'Currency'));
  SetColumnTitle('acc_account_code', TLocalizationManager.Translate(TLangKeys.TFinMoneyAccount.ColAccAccountCode, 'Accounting Account'));
  SetColumnTitle('is_active', TLocalizationManager.Translate(TLangKeys.TFinMoneyAccount.ColIsActive, 'Active'));
  SetColumnTitle('notes', TLocalizationManager.Translate(TLangKeys.TFinMoneyAccount.ColNotes, 'Notes'));
  SetColumnTitle('bank_name', TLocalizationManager.Translate(TLangKeys.TFinMoneyAccount.ColBankName, 'Bank'));
  SetColumnTitle('branch_name', TLocalizationManager.Translate(TLangKeys.TFinMoneyAccount.ColBranchName, 'Bank Branch'));
  SetColumnTitle('account_name', TLocalizationManager.Translate(TLangKeys.TFinMoneyAccount.ColAccountName, 'Accounting Account Name'));
  SetColumnTitle('total_in', TLocalizationManager.Translate(TLangKeys.TFinMoneyAccount.ColTotalIn, 'Total In'));
  SetColumnTitle('total_out', TLocalizationManager.Translate(TLangKeys.TFinMoneyAccount.ColTotalOut, 'Total Out'));
  SetColumnTitle('balance', TLocalizationManager.Translate(TLangKeys.TFinMoneyAccount.ColBalance, 'Balance'));
  if Assigned(FmniLedger) then
    FmniLedger.Caption := TLocalizationManager.Translate(TLangKeys.TFinMoneyAccount.MenuLedger, 'Account Statement');
  if Assigned(FmniTransactions) then
    FmniTransactions.Caption := TLocalizationManager.Translate(TLangKeys.TFinMoneyAccount.MenuTransactions, 'Transactions');
end;

end.
