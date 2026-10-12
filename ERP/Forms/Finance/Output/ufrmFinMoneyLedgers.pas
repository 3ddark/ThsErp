unit ufrmFinMoneyLedgers;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  FinMoneyLedger.Service, FinMoneyLedger;

type
  TfrmFinMoneyLedgers = class(TfrmGrid<TFinMoneyLedger, TFinMoneyLedgerService>)
  private
    FFixedMasterName: string;
    procedure TransactionTypeGetText(Sender: TField; var Text: string; DisplayText: Boolean);
    procedure TransferMethodGetText(Sender: TField; var Text: string; DisplayText: Boolean);
    procedure DirectionGetText(Sender: TField; var Text: string; DisplayText: Boolean);
  public
    procedure SetFixedMoneyAccount(AMasterId: Int64; const AMasterName: string);
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

procedure TfrmFinMoneyLedgers.TransactionTypeGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if Sender.IsNull then
    Text := ''
  else
    Text := TFinLookup.Text(flkMoneyTxType, Sender.AsInteger);
end;

procedure TfrmFinMoneyLedgers.TransferMethodGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if Sender.IsNull then
    Text := ''
  else
    Text := TFinLookup.Text(flkTransferMethod, Sender.AsInteger);
end;

procedure TfrmFinMoneyLedgers.DirectionGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if Sender.IsNull then
    Text := ''
  else
    Text := TFinLookup.Text(flkMoneyDirection, Sender.AsInteger);
end;
procedure TfrmFinMoneyLedgers.SetFixedMoneyAccount(AMasterId: Int64; const AMasterName: string);
begin
  FFixedMasterName := AMasterName;
  AddFixedFilter('fin_money_account_id', AMasterId);
end;

function TfrmFinMoneyLedgers.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  // Salt okunur liste: giriş formu yok
  Result := nil;
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmFinMoneyLedgers.SetSelectedItem;

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
  Table.OtherMoneyAccountName := FieldText('other_money_account_name');
  Table.AccountCode := FieldText('account_code');
  Table.AccountName := FieldText('account_name');
end;

procedure TfrmFinMoneyLedgers.DefineColumnWidths;
var
  LField: TField;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('fin_money_transaction_id', 0);
  SetColumnProperty('fin_money_account_id', 0);
  SetColumnProperty('other_fin_money_account_id', 0);
  SetColumnProperty('acc_account_id', 0);
  LField := Grd.DataSource.DataSet.FindField('transaction_type');
  if Assigned(LField) then
    LField.OnGetText := TransactionTypeGetText;
  LField := Grd.DataSource.DataSet.FindField('transfer_method');
  if Assigned(LField) then
    LField.OnGetText := TransferMethodGetText;
  LField := Grd.DataSource.DataSet.FindField('direction');
  if Assigned(LField) then
    LField.OnGetText := DirectionGetText;
end;

procedure TfrmFinMoneyLedgers.FormShow(Sender: TObject);
begin
  inherited;
  if Assigned(BtnAdd) then
    BtnAdd.Visible := False;
  if Assigned(mniDuplicate) then
    mniDuplicate.Visible := False;
  ApplyLocalization;
end;

procedure TfrmFinMoneyLedgers.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TFinMoneyLedger.TitlePlural, 'Cash / Bank Statement');
  if FFixedMasterName <> '' then
    Self.Caption := Self.Caption + ' - ' + FFixedMasterName;
  SetColumnTitle('transaction_date', TLocalizationManager.Translate(TLangKeys.TFinMoneyLedger.ColTransactionDate, 'Date'));
  SetColumnTitle('transaction_type', TLocalizationManager.Translate(TLangKeys.TFinMoneyLedger.ColTransactionType, 'Transaction Type'));
  SetColumnTitle('transfer_method', TLocalizationManager.Translate(TLangKeys.TFinMoneyLedger.ColTransferMethod, 'Transfer Method'));
  SetColumnTitle('direction', TLocalizationManager.Translate(TLangKeys.TFinMoneyLedger.ColDirection, 'Direction'));
  SetColumnTitle('amount_in', TLocalizationManager.Translate(TLangKeys.TFinMoneyLedger.ColAmountIn, 'In'));
  SetColumnTitle('amount_out', TLocalizationManager.Translate(TLangKeys.TFinMoneyLedger.ColAmountOut, 'Out'));
  SetColumnTitle('balance', TLocalizationManager.Translate(TLangKeys.TFinMoneyLedger.ColBalance, 'Balance'));
  SetColumnTitle('document_no', TLocalizationManager.Translate(TLangKeys.TFinMoneyLedger.ColDocumentNo, 'Document / Receipt No'));
  SetColumnTitle('counterparty_name', TLocalizationManager.Translate(TLangKeys.TFinMoneyLedger.ColCounterpartyName, 'Sender / Receiver'));
  SetColumnTitle('description', TLocalizationManager.Translate(TLangKeys.TFinMoneyLedger.ColDescription, 'Description'));
  SetColumnTitle('money_account_name', TLocalizationManager.Translate(TLangKeys.TFinMoneyLedger.ColMoneyAccountName, 'Cash / Bank Account'));
  SetColumnTitle('currency', TLocalizationManager.Translate(TLangKeys.TFinMoneyLedger.ColCurrency, 'Currency'));
  SetColumnTitle('other_money_account_name', TLocalizationManager.Translate(TLangKeys.TFinMoneyLedger.ColOtherMoneyAccountName, 'Counter Account'));
  SetColumnTitle('account_code', TLocalizationManager.Translate(TLangKeys.TFinMoneyLedger.ColAccountCode, 'Account Code'));
  SetColumnTitle('account_name', TLocalizationManager.Translate(TLangKeys.TFinMoneyLedger.ColAccountName, 'Account'));
end;

end.
