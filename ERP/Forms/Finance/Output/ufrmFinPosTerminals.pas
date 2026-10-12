unit ufrmFinPosTerminals;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  FinPosTerminal.Service, FinPosTerminal, ufrmFinPosTerminal;

type
  TfrmFinPosTerminals = class(TfrmGrid<TFinPosTerminal, TFinPosTerminalService>)
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
  ufrmFinPosTransactions, FinPosTransaction, FinPosTransaction.Service;

procedure TfrmFinPosTerminals.mniTransactionsClick(Sender: TObject);
var
  LFrm: TfrmFinPosTransactions;
begin
  if Grd.DataSource.DataSet.IsEmpty then
    Exit;

  SetSelectedItem;
  LFrm := TfrmFinPosTransactions.Create(Self, TFinPosTransactionService.Create, TFinPosTransaction.Create);
  LFrm.SetFixedPosTerminal(Table.Id, Table.PosName, Table.CommissionRate);
  LFrm.Show;
end;

procedure TfrmFinPosTerminals.PreparePopupMenu;
begin
  inherited;
  if IsHelper then
    Exit;

  AddPopupMenuSpliter();
  FmniTransactions := AddMenu(TLocalizationManager.Translate(TLangKeys.TFinPosTerminal.MenuTransactions, 'Collections'), 'mniTransactions', mniTransactionsClick);
end;

function TfrmFinPosTerminals.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmFinPosTerminal.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmFinPosTerminal.Create(Self, Service, TFinPosTerminal.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmFinPosTerminal.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmFinPosTerminals.SetSelectedItem;

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
  if Assigned(Grd.DataSource.DataSet.FindField('commission_rate')) then
    Table.CommissionRate := Grd.DataSource.DataSet.FindField('commission_rate').AsCurrency;
  if Assigned(Grd.DataSource.DataSet.FindField('blocked_days')) then
    Table.BlockedDays := Grd.DataSource.DataSet.FindField('blocked_days').AsInteger;
end;

procedure TfrmFinPosTerminals.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('acc_bank_id', 0);

end;

procedure TfrmFinPosTerminals.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmFinPosTerminals.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TFinPosTerminal.TitlePlural, 'POS Terminals');
  SetColumnTitle('pos_name', TLocalizationManager.Translate(TLangKeys.TFinPosTerminal.ColPosName, 'POS Name'));
  SetColumnTitle('terminal_no', TLocalizationManager.Translate(TLangKeys.TFinPosTerminal.ColTerminalNo, 'Terminal No'));
  SetColumnTitle('commission_rate', TLocalizationManager.Translate(TLangKeys.TFinPosTerminal.ColCommissionRate, 'Commission Rate (%)'));
  SetColumnTitle('blocked_days', TLocalizationManager.Translate(TLangKeys.TFinPosTerminal.ColBlockedDays, 'Blocked Days'));
  SetColumnTitle('currency', TLocalizationManager.Translate(TLangKeys.TFinPosTerminal.ColCurrency, 'Currency'));
  SetColumnTitle('acc_account_code', TLocalizationManager.Translate(TLangKeys.TFinPosTerminal.ColAccAccountCode, 'Accounting Account'));
  SetColumnTitle('is_active', TLocalizationManager.Translate(TLangKeys.TFinPosTerminal.ColIsActive, 'Active'));
  SetColumnTitle('notes', TLocalizationManager.Translate(TLangKeys.TFinPosTerminal.ColNotes, 'Notes'));
  SetColumnTitle('bank_name', TLocalizationManager.Translate(TLangKeys.TFinPosTerminal.ColBankName, 'Bank'));
  SetColumnTitle('account_name', TLocalizationManager.Translate(TLangKeys.TFinPosTerminal.ColAccountName, 'Accounting Account Name'));
  SetColumnTitle('total_amount', TLocalizationManager.Translate(TLangKeys.TFinPosTerminal.ColTotalAmount, 'Total Collection'));
  SetColumnTitle('total_commission', TLocalizationManager.Translate(TLangKeys.TFinPosTerminal.ColTotalCommission, 'Total Commission'));
  SetColumnTitle('total_net', TLocalizationManager.Translate(TLangKeys.TFinPosTerminal.ColTotalNet, 'Total Net'));
  if Assigned(FmniTransactions) then
    FmniTransactions.Caption := TLocalizationManager.Translate(TLangKeys.TFinPosTerminal.MenuTransactions, 'Collections');
end;

end.
