unit ufrmFinChequeNoteTransactions;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  FinChequeNoteTransaction.Service, FinChequeNoteTransaction, ufrmFinChequeNoteTransaction;

type
  TfrmFinChequeNoteTransactions = class(TfrmGrid<TFinChequeNoteTransaction, TFinChequeNoteTransactionService>)
  private
    FFixedMasterId: Int64;
    FFixedMasterName: string;
    procedure DocKindGetText(Sender: TField; var Text: string; DisplayText: Boolean);
    procedure DirectionGetText(Sender: TField; var Text: string; DisplayText: Boolean);
    procedure TransactionTypeGetText(Sender: TField; var Text: string; DisplayText: Boolean);
  public
    procedure SetFixedChequeNote(AMasterId: Int64; const AMasterName: string);
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

procedure TfrmFinChequeNoteTransactions.DocKindGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if Sender.IsNull then
    Text := ''
  else
    Text := TFinLookup.Text(flkDocKind, Sender.AsInteger);
end;

procedure TfrmFinChequeNoteTransactions.DirectionGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if Sender.IsNull then
    Text := ''
  else
    Text := TFinLookup.Text(flkDirection, Sender.AsInteger);
end;

procedure TfrmFinChequeNoteTransactions.TransactionTypeGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if Sender.IsNull then
    Text := ''
  else
    Text := TFinLookup.Text(flkChequeStatus, Sender.AsInteger);
end;
procedure TfrmFinChequeNoteTransactions.SetFixedChequeNote(AMasterId: Int64; const AMasterName: string);
begin
  FFixedMasterId := AMasterId;
  FFixedMasterName := AMasterName;
  AddFixedFilter('fin_cheque_note_id', AMasterId);
end;

function TfrmFinChequeNoteTransactions.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
var
  LNew: TFinChequeNoteTransaction;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmFinChequeNoteTransaction.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
  begin
    LNew := TFinChequeNoteTransaction.Create;
    if FFixedMasterId > 0 then
    begin
      LNew.FinChequeNoteId := FFixedMasterId;
      LNew.PortfolioNo := FFixedMasterName;
    end;
    Result := TfrmFinChequeNoteTransaction.Create(Self, Service, LNew, AFormMode, Self.RefreshParentGrid);
  end
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmFinChequeNoteTransaction.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmFinChequeNoteTransactions.SetSelectedItem;

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
  Table.PortfolioNo := FieldText('portfolio_no');
  Table.SerialNo := FieldText('serial_no');
  Table.AccountCode := FieldText('account_code');
  Table.AccountName := FieldText('account_name');
  Table.BankName := FieldText('bank_name');
end;

procedure TfrmFinChequeNoteTransactions.DefineColumnWidths;
var
  LField: TField;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('fin_cheque_note_id', 0);
  SetColumnProperty('acc_account_id', 0);
  SetColumnProperty('acc_bank_id', 0);
  LField := Grd.DataSource.DataSet.FindField('doc_kind');
  if Assigned(LField) then
    LField.OnGetText := DocKindGetText;
  LField := Grd.DataSource.DataSet.FindField('direction');
  if Assigned(LField) then
    LField.OnGetText := DirectionGetText;
  LField := Grd.DataSource.DataSet.FindField('transaction_type');
  if Assigned(LField) then
    LField.OnGetText := TransactionTypeGetText;
end;

procedure TfrmFinChequeNoteTransactions.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmFinChequeNoteTransactions.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TFinChequeNoteTransaction.TitlePlural, 'Cheque / Note Transactions');
  if FFixedMasterName <> '' then
    Self.Caption := Self.Caption + ' - ' + FFixedMasterName;
  SetColumnTitle('transaction_date', TLocalizationManager.Translate(TLangKeys.TFinChequeNoteTransaction.ColTransactionDate, 'Date'));
  SetColumnTitle('transaction_type', TLocalizationManager.Translate(TLangKeys.TFinChequeNoteTransaction.ColTransactionType, 'Transaction Type'));
  SetColumnTitle('description', TLocalizationManager.Translate(TLangKeys.TFinChequeNoteTransaction.ColDescription, 'Description'));
  SetColumnTitle('portfolio_no', TLocalizationManager.Translate(TLangKeys.TFinChequeNoteTransaction.ColPortfolioNo, 'Portfolio No'));
  SetColumnTitle('serial_no', TLocalizationManager.Translate(TLangKeys.TFinChequeNoteTransaction.ColSerialNo, 'Serial No'));
  SetColumnTitle('account_code', TLocalizationManager.Translate(TLangKeys.TFinChequeNoteTransaction.ColAccountCode, 'Account Code'));
  SetColumnTitle('account_name', TLocalizationManager.Translate(TLangKeys.TFinChequeNoteTransaction.ColAccountName, 'Account'));
  SetColumnTitle('bank_name', TLocalizationManager.Translate(TLangKeys.TFinChequeNoteTransaction.ColBankName, 'Bank'));
  SetColumnTitle('doc_kind', TLocalizationManager.Translate(TLangKeys.TFinChequeNoteTransaction.ColDocKind, 'Document Kind'));
  SetColumnTitle('direction', TLocalizationManager.Translate(TLangKeys.TFinChequeNoteTransaction.ColDirection, 'Direction'));
  SetColumnTitle('due_date', TLocalizationManager.Translate(TLangKeys.TFinChequeNoteTransaction.ColDueDate, 'Due Date'));
  SetColumnTitle('amount', TLocalizationManager.Translate(TLangKeys.TFinChequeNoteTransaction.ColAmount, 'Amount'));
  SetColumnTitle('currency', TLocalizationManager.Translate(TLangKeys.TFinChequeNoteTransaction.ColCurrency, 'Currency'));
end;

end.
