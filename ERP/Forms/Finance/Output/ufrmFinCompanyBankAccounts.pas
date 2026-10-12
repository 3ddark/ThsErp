unit ufrmFinCompanyBankAccounts;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  FinCompanyBankAccount.Service, FinCompanyBankAccount, ufrmFinCompanyBankAccount;

type
  TfrmFinCompanyBankAccounts = class(TfrmGrid<TFinCompanyBankAccount, TFinCompanyBankAccountService>)
  private

  public
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


function TfrmFinCompanyBankAccounts.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmFinCompanyBankAccount.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmFinCompanyBankAccount.Create(Self, Service, TFinCompanyBankAccount.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmFinCompanyBankAccount.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmFinCompanyBankAccounts.SetSelectedItem;

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
  Table.CityName := FieldText('city_name');
  Table.PrintText := FieldText('print_text');
end;

procedure TfrmFinCompanyBankAccounts.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('acc_bank_id', 0);
  SetColumnProperty('sys_city_id', 0);

end;

procedure TfrmFinCompanyBankAccounts.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmFinCompanyBankAccounts.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TFinCompanyBankAccount.TitlePlural, 'Company Bank Accounts');
  SetColumnTitle('branch_code', TLocalizationManager.Translate(TLangKeys.TFinCompanyBankAccount.ColBranchCode, 'Branch Code'));
  SetColumnTitle('branch_name', TLocalizationManager.Translate(TLangKeys.TFinCompanyBankAccount.ColBranchName, 'Branch Name'));
  SetColumnTitle('account_no', TLocalizationManager.Translate(TLangKeys.TFinCompanyBankAccount.ColAccountNo, 'Account No'));
  SetColumnTitle('iban', TLocalizationManager.Translate(TLangKeys.TFinCompanyBankAccount.ColIban, 'IBAN'));
  SetColumnTitle('currency', TLocalizationManager.Translate(TLangKeys.TFinCompanyBankAccount.ColCurrency, 'Currency'));
  SetColumnTitle('account_holder', TLocalizationManager.Translate(TLangKeys.TFinCompanyBankAccount.ColAccountHolder, 'Account Holder'));
  SetColumnTitle('show_on_cheque', TLocalizationManager.Translate(TLangKeys.TFinCompanyBankAccount.ColShowOnCheque, 'Show on Cheques'));
  SetColumnTitle('show_on_note', TLocalizationManager.Translate(TLangKeys.TFinCompanyBankAccount.ColShowOnNote, 'Show on Promissory Notes'));
  SetColumnTitle('show_on_print', TLocalizationManager.Translate(TLangKeys.TFinCompanyBankAccount.ColShowOnPrint, 'Show on Printouts'));
  SetColumnTitle('sort_order', TLocalizationManager.Translate(TLangKeys.TFinCompanyBankAccount.ColSortOrder, 'Sort Order'));
  SetColumnTitle('is_active', TLocalizationManager.Translate(TLangKeys.TFinCompanyBankAccount.ColIsActive, 'Active'));
  SetColumnTitle('description', TLocalizationManager.Translate(TLangKeys.TFinCompanyBankAccount.ColDescription, 'Description'));
  SetColumnTitle('bank_name', TLocalizationManager.Translate(TLangKeys.TFinCompanyBankAccount.ColBankName, 'Bank'));
  SetColumnTitle('city_name', TLocalizationManager.Translate(TLangKeys.TFinCompanyBankAccount.ColCityName, 'Branch City'));
  SetColumnTitle('print_text', TLocalizationManager.Translate(TLangKeys.TFinCompanyBankAccount.ColPrintText, 'Print Text'));
  SetColumnTitle('swift_code', TLocalizationManager.Translate(TLangKeys.TFinCompanyBankAccount.ColSwiftCode, 'SWIFT'));
end;

end.
