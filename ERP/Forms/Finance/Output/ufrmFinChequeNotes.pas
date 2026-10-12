unit ufrmFinChequeNotes;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  FinChequeNote.Service, FinChequeNote, ufrmFinChequeNote;

type
  TfrmFinChequeNotes = class(TfrmGrid<TFinChequeNote, TFinChequeNoteService>)
  private
    FFixedKind: SmallInt;
    FFixedDirection: SmallInt;
    FmniTransactions: TMenuItem;
    procedure mniTransactionsClick(Sender: TObject);
    procedure DocKindGetText(Sender: TField; var Text: string; DisplayText: Boolean);
    procedure DirectionGetText(Sender: TField; var Text: string; DisplayText: Boolean);
    procedure StatusGetText(Sender: TField; var Text: string; DisplayText: Boolean);
  public
    procedure SetFixedKind(AKind, ADirection: SmallInt);
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
  ufrmFinChequeNoteTransactions, FinChequeNoteTransaction, FinChequeNoteTransaction.Service;

procedure TfrmFinChequeNotes.DocKindGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if Sender.IsNull then
    Text := ''
  else
    Text := TFinLookup.Text(flkDocKind, Sender.AsInteger);
end;

procedure TfrmFinChequeNotes.DirectionGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if Sender.IsNull then
    Text := ''
  else
    Text := TFinLookup.Text(flkDirection, Sender.AsInteger);
end;

procedure TfrmFinChequeNotes.StatusGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if Sender.IsNull then
    Text := ''
  else
    Text := TFinLookup.Text(flkChequeStatus, Sender.AsInteger);
end;
procedure TfrmFinChequeNotes.SetFixedKind(AKind, ADirection: SmallInt);
begin
  FFixedKind := AKind;
  FFixedDirection := ADirection;
  AddFixedFilter('doc_kind', AKind);
  AddFixedFilter('direction', ADirection);
end;

procedure TfrmFinChequeNotes.mniTransactionsClick(Sender: TObject);
var
  LFrm: TfrmFinChequeNoteTransactions;
begin
  if Grd.DataSource.DataSet.IsEmpty then
    Exit;

  SetSelectedItem;
  LFrm := TfrmFinChequeNoteTransactions.Create(Self, TFinChequeNoteTransactionService.Create, TFinChequeNoteTransaction.Create);
  LFrm.SetFixedChequeNote(Table.Id, Table.PortfolioNo + ' / ' + Table.SerialNo);
  LFrm.Show;
end;

procedure TfrmFinChequeNotes.PreparePopupMenu;
begin
  inherited;
  if IsHelper then
    Exit;

  AddPopupMenuSpliter();
  FmniTransactions := AddMenu(TLocalizationManager.Translate(TLangKeys.TFinChequeNote.MenuTransactions, 'Transactions'), 'mniTransactions', mniTransactionsClick);
end;

function TfrmFinChequeNotes.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
var
  LNew: TFinChequeNote;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmFinChequeNote.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
  begin
    LNew := TFinChequeNote.Create;
    if FFixedKind > 0 then
    begin
      LNew.DocKind := FFixedKind;
      LNew.Direction := FFixedDirection;
    end;
    Result := TfrmFinChequeNote.Create(Self, Service, LNew, AFormMode, Self.RefreshParentGrid);
  end
  else if (AFormMode = ifmCopyNewRecord) then
  begin
    LNew := Table.Clone;
    // Kopya: portföy no yeniden üretilir, durum açılıştan başlar
    LNew.PortfolioNo := '';
    LNew.Status := TFinLookup.InitialStatus(LNew.Direction);
    Result := TfrmFinChequeNote.Create(Self, Service, LNew, AFormMode, Self.RefreshParentGrid);
  end;
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmFinChequeNotes.SetSelectedItem;

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
  Table.AccountCode := FieldText('account_code');
  Table.AccountName := FieldText('account_name');
  Table.BankName := FieldText('bank_name');
  Table.BranchName := FieldText('branch_name');
  Table.CurrentHolder := FieldText('current_holder');
end;

procedure TfrmFinChequeNotes.DefineColumnWidths;
var
  LField: TField;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('acc_account_id', 0);
  SetColumnProperty('acc_bank_id', 0);
  SetColumnProperty('acc_bank_branch_id', 0);
  LField := Grd.DataSource.DataSet.FindField('doc_kind');
  if Assigned(LField) then
    LField.OnGetText := DocKindGetText;
  LField := Grd.DataSource.DataSet.FindField('direction');
  if Assigned(LField) then
    LField.OnGetText := DirectionGetText;
  LField := Grd.DataSource.DataSet.FindField('status');
  if Assigned(LField) then
    LField.OnGetText := StatusGetText;
end;

procedure TfrmFinChequeNotes.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmFinChequeNotes.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TFinChequeNote.TitlePlural, 'Cheques / Notes');
  if FFixedKind > 0 then
    Self.Caption := TFinLookup.ChequeNoteListTitle(FFixedKind, FFixedDirection);
  SetColumnTitle('doc_kind', TLocalizationManager.Translate(TLangKeys.TFinChequeNote.ColDocKind, 'Document Kind'));
  SetColumnTitle('direction', TLocalizationManager.Translate(TLangKeys.TFinChequeNote.ColDirection, 'Direction'));
  SetColumnTitle('portfolio_no', TLocalizationManager.Translate(TLangKeys.TFinChequeNote.ColPortfolioNo, 'Portfolio No'));
  SetColumnTitle('serial_no', TLocalizationManager.Translate(TLangKeys.TFinChequeNote.ColSerialNo, 'Serial No'));
  SetColumnTitle('issue_date', TLocalizationManager.Translate(TLangKeys.TFinChequeNote.ColIssueDate, 'Issue Date'));
  SetColumnTitle('due_date', TLocalizationManager.Translate(TLangKeys.TFinChequeNote.ColDueDate, 'Due Date'));
  SetColumnTitle('amount', TLocalizationManager.Translate(TLangKeys.TFinChequeNote.ColAmount, 'Amount'));
  SetColumnTitle('currency', TLocalizationManager.Translate(TLangKeys.TFinChequeNote.ColCurrency, 'Currency'));
  SetColumnTitle('drawer_name', TLocalizationManager.Translate(TLangKeys.TFinChequeNote.ColDrawerName, 'Drawer / Debtor'));
  SetColumnTitle('drawer_tax_no', TLocalizationManager.Translate(TLangKeys.TFinChequeNote.ColDrawerTaxNo, 'Drawer Tax No'));
  SetColumnTitle('issue_place', TLocalizationManager.Translate(TLangKeys.TFinChequeNote.ColIssuePlace, 'Place of Issue'));
  SetColumnTitle('bank_account_no', TLocalizationManager.Translate(TLangKeys.TFinChequeNote.ColBankAccountNo, 'Bank Account No'));
  SetColumnTitle('guarantor_name', TLocalizationManager.Translate(TLangKeys.TFinChequeNote.ColGuarantorName, 'Guarantor'));
  SetColumnTitle('status', TLocalizationManager.Translate(TLangKeys.TFinChequeNote.ColStatus, 'Status'));
  SetColumnTitle('notes', TLocalizationManager.Translate(TLangKeys.TFinChequeNote.ColNotes, 'Notes'));
  SetColumnTitle('account_code', TLocalizationManager.Translate(TLangKeys.TFinChequeNote.ColAccountCode, 'Account Code'));
  SetColumnTitle('account_name', TLocalizationManager.Translate(TLangKeys.TFinChequeNote.ColAccountName, 'Account'));
  SetColumnTitle('bank_name', TLocalizationManager.Translate(TLangKeys.TFinChequeNote.ColBankName, 'Bank'));
  SetColumnTitle('branch_name', TLocalizationManager.Translate(TLangKeys.TFinChequeNote.ColBranchName, 'Bank Branch'));
  SetColumnTitle('current_holder', TLocalizationManager.Translate(TLangKeys.TFinChequeNote.ColCurrentHolder, 'Current Holder'));
  SetColumnTitle('days_to_due', TLocalizationManager.Translate(TLangKeys.TFinChequeNote.ColDaysToDue, 'Days to Due'));
  SetColumnTitle('status_date', TLocalizationManager.Translate(TLangKeys.TFinChequeNote.ColStatusDate, 'Status Date'));
  if Assigned(FmniTransactions) then
    FmniTransactions.Caption := TLocalizationManager.Translate(TLangKeys.TFinChequeNote.MenuTransactions, 'Transactions');
end;

end.
