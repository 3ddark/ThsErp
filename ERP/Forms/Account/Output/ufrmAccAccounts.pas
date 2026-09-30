unit ufrmAccAccounts;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  AccAccount.Service, AccAccount, ufrmAccAccount;

type
  TfrmAccAccounts = class(TfrmGrid<TAccAccount, TAccAccountService>)
  private
    FFixedAccountTypeId: Int64;
    FFixedAccountTypeName: string;
    FmniAddresses: TMenuItem;
    procedure mniAddressesClick(Sender: TObject);
    procedure TaxpayerTypeGetText(Sender: TField; var Text: string; DisplayText: Boolean);
  public
    procedure SetFixedAccountType(AAccountTypeId: Int64; const AAccountTypeName: string);

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
  ufrmAccAccountAddresses, AccAccountAddress, AccAccountAddress.Service,        // TfrmAccAccountAddresses
  AccLookup;

procedure TfrmAccAccounts.TaxpayerTypeGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if Sender.IsNull then
    Text := ''
  else
    Text := TAccLookup.Text(alkTaxpayerType, Sender.AsInteger);
end;

procedure TfrmAccAccounts.SetFixedAccountType(AAccountTypeId: Int64; const AAccountTypeName: string);
begin
  FFixedAccountTypeId := AAccountTypeId;
  FFixedAccountTypeName := AAccountTypeName;
  AddFixedFilter('acc_set_account_type_id', AAccountTypeId);
end;

function TfrmAccAccounts.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
var
  LNew: TAccAccount;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmAccAccount.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
  begin
    LNew := TAccAccount.Create;
    if FFixedAccountTypeId > 0 then
    begin
      LNew.AccSetAccountTypeId := FFixedAccountTypeId;
      LNew.AccountTypeName := FFixedAccountTypeName;
    end;
    Result := TfrmAccAccount.Create(Self, Service, LNew, AFormMode, Self.RefreshParentGrid);
  end
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmAccAccount.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmAccAccounts.PreparePopupMenu;
begin
  inherited;
  if IsHelper then
    Exit;

  AddPopupMenuSpliter();
  FmniAddresses := AddMenu(TLocalizationManager.Translate(TLangKeys.TAccAccount.MenuAddresses, 'Addresses'), 'mniAddresses', mniAddressesClick);
end;

procedure TfrmAccAccounts.mniAddressesClick(Sender: TObject);
var
  LFrm: TfrmAccAccountAddresses;
begin
  if Grd.DataSource.DataSet.IsEmpty then
    Exit;

  SetSelectedItem;
  LFrm := TfrmAccAccountAddresses.Create(Self, TAccAccountAddressService.Create, TAccAccountAddress.Create);
  LFrm.SetFixedAccount(Table.Id, Table.Code + ' ' + Table.Name);
  LFrm.Show;
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmAccAccounts.SetSelectedItem;

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
  Table.AccountTypeName := FieldText('account_type_name');
  Table.GroupName := FieldText('group_name');
  Table.RegionName := FieldText('region_name');
end;

procedure TfrmAccAccounts.DefineColumnWidths;
var
  LField: TField;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('acc_set_account_type_id', 0);
  SetColumnProperty('acc_group_id', 0);
  SetColumnProperty('acc_region_id', 0);
  SetColumnProperty('locale', 0);

  // Sayısal seçenek değerleri aktif dile göre metin olarak gösterilir
  LField := Grd.DataSource.DataSet.FindField('taxpayer_type');
  if Assigned(LField) then
    LField.OnGetText := TaxpayerTypeGetText;
end;

procedure TfrmAccAccounts.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmAccAccounts.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccount.TitlePlural, 'Account Cards');
  if FFixedAccountTypeName <> '' then
    Self.Caption := Self.Caption + ' - ' + FFixedAccountTypeName;
  if Assigned(FmniAddresses) then
    FmniAddresses.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccount.MenuAddresses, 'Addresses');
  SetColumnTitle('code', TLocalizationManager.Translate(TLangKeys.TAccAccount.ColCode, 'Account Code'));
  SetColumnTitle('name', TLocalizationManager.Translate(TLangKeys.TAccAccount.ColName, 'Account Name'));
  SetColumnTitle('account_type_name', TLocalizationManager.Translate(TLangKeys.TAccAccount.ColAccountType, 'Account Type'));
  SetColumnTitle('group_name', TLocalizationManager.Translate(TLangKeys.TAccAccount.ColGroup, 'Group'));
  SetColumnTitle('region_name', TLocalizationManager.Translate(TLangKeys.TAccAccount.ColRegion, 'Region'));
  SetColumnTitle('root_code', TLocalizationManager.Translate(TLangKeys.TAccAccount.ColRootCode, 'Root Code'));
  SetColumnTitle('sub_code', TLocalizationManager.Translate(TLangKeys.TAccAccount.ColSubCode, 'Parent Code'));
  SetColumnTitle('iban', TLocalizationManager.Translate(TLangKeys.TAccAccount.ColIban, 'IBAN'));
  SetColumnTitle('iban_currency', TLocalizationManager.Translate(TLangKeys.TAccAccount.ColIbanCurrency, 'IBAN Currency'));
  SetColumnTitle('discount_rate', TLocalizationManager.Translate(TLangKeys.TAccAccount.ColDiscountRate, 'Discount Rate'));
  SetColumnTitle('e_invoice_active', TLocalizationManager.Translate(TLangKeys.TAccAccount.ColEInvoiceActive, 'E-Invoice Active'));
  SetColumnTitle('e_invoice_package_name', TLocalizationManager.Translate(TLangKeys.TAccAccount.ColEInvoicePackageName, 'E-Invoice Package'));
  SetColumnTitle('is_passive', TLocalizationManager.Translate(TLangKeys.TAccAccount.ColIsPassive, 'Passive'));
  SetColumnTitle('notes', TLocalizationManager.Translate(TLangKeys.TAccAccount.ColNotes, 'Notes'));
  SetColumnTitle('taxpayer_type', TLocalizationManager.Translate(TLangKeys.TAccAccount.ColTaxpayerType, 'Taxpayer Type'));
  SetColumnTitle('taxpayer_name', TLocalizationManager.Translate(TLangKeys.TAccAccount.ColTaxpayerName, 'Taxpayer Name'));
  SetColumnTitle('taxpayer_name2', TLocalizationManager.Translate(TLangKeys.TAccAccount.ColTaxpayerName2, 'Taxpayer Name 2'));
  SetColumnTitle('taxpayer_surname', TLocalizationManager.Translate(TLangKeys.TAccAccount.ColTaxpayerSurname, 'Taxpayer Surname'));
  SetColumnTitle('tax_office', TLocalizationManager.Translate(TLangKeys.TAccAccount.ColTaxOffice, 'Tax Office'));
  SetColumnTitle('tax_no', TLocalizationManager.Translate(TLangKeys.TAccAccount.ColTaxNo, 'Tax No'));
  SetColumnTitle('nace_code', TLocalizationManager.Translate(TLangKeys.TAccAccount.ColNaceCode, 'NACE Code'));
  SetColumnTitle('authorized_person_1', TLocalizationManager.Translate(TLangKeys.TAccAccount.ColAuthorizedPerson1, 'Contact Person 1'));
  SetColumnTitle('authorized_phone_1', TLocalizationManager.Translate(TLangKeys.TAccAccount.ColAuthorizedPhone1, 'Contact Phone 1'));
  SetColumnTitle('authorized_person_2', TLocalizationManager.Translate(TLangKeys.TAccAccount.ColAuthorizedPerson2, 'Contact Person 2'));
  SetColumnTitle('authorized_phone_2', TLocalizationManager.Translate(TLangKeys.TAccAccount.ColAuthorizedPhone2, 'Contact Phone 2'));
  SetColumnTitle('authorized_person_3', TLocalizationManager.Translate(TLangKeys.TAccAccount.ColAuthorizedPerson3, 'Contact Person 3'));
  SetColumnTitle('authorized_phone_3', TLocalizationManager.Translate(TLangKeys.TAccAccount.ColAuthorizedPhone3, 'Contact Phone 3'));
  SetColumnTitle('fax', TLocalizationManager.Translate(TLangKeys.TAccAccount.ColFax, 'Fax'));
  SetColumnTitle('accountant_phone', TLocalizationManager.Translate(TLangKeys.TAccAccount.ColAccountantPhone, 'Accountant Phone'));
  SetColumnTitle('accountant_email', TLocalizationManager.Translate(TLangKeys.TAccAccount.ColAccountantEmail, 'Accountant E-Mail'));
  SetColumnTitle('accountant_authorized', TLocalizationManager.Translate(TLangKeys.TAccAccount.ColAccountantAuthorized, 'Accountant Contact'));
end;

end.
