unit ufrmAccAccountAddresses;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  AccAccountAddress.Service, AccAccountAddress, ufrmAccAccountAddress;

type
  TfrmAccAccountAddresses = class(TfrmGrid<TAccAccountAddress, TAccAccountAddressService>)
  private
    FFixedAccountId: Int64;
    FFixedAccountName: string;
  public
    procedure SetFixedAccount(AAccountId: Int64; const AAccountName: string);

    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure SetSelectedItem; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

procedure TfrmAccAccountAddresses.SetFixedAccount(AAccountId: Int64; const AAccountName: string);
begin
  FFixedAccountId := AAccountId;
  FFixedAccountName := AAccountName;
  AddFixedFilter('acc_account_id', AAccountId);
end;

function TfrmAccAccountAddresses.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
var
  LNew: TAccAccountAddress;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmAccAccountAddress.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
  begin
    LNew := TAccAccountAddress.Create;
    if FFixedAccountId > 0 then
    begin
      LNew.AccAccountId := FFixedAccountId;
      LNew.AccountName := FFixedAccountName;
    end;
    Result := TfrmAccAccountAddress.Create(Self, Service, LNew, AFormMode, Self.RefreshParentGrid);
  end
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmAccAccountAddress.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmAccAccountAddresses.SetSelectedItem;

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
  Table.AccountName := FieldText('account_name');
  Table.AddressText := FieldText('address_text');
  Table.AccountCode := FieldText('account_code');
end;

procedure TfrmAccAccountAddresses.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('acc_account_id', 0);
  SetColumnProperty('sys_address_id', 0);
end;

procedure TfrmAccAccountAddresses.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmAccAccountAddresses.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccountAddress.TitlePlural, 'Account Addresses');
  if FFixedAccountName <> '' then
    Self.Caption := Self.Caption + ' - ' + FFixedAccountName;
  SetColumnTitle('account_name', TLocalizationManager.Translate(TLangKeys.TAccAccountAddress.ColAccount, 'Account'));
  SetColumnTitle('address_text', TLocalizationManager.Translate(TLangKeys.TAccAccountAddress.ColAddress, 'Address'));
  SetColumnTitle('address_type', TLocalizationManager.Translate(TLangKeys.TAccAccountAddress.ColAddressType, 'Address Type'));
  SetColumnTitle('is_primary', TLocalizationManager.Translate(TLangKeys.TAccAccountAddress.ColIsPrimary, 'Primary'));
  SetColumnTitle('valid_from', TLocalizationManager.Translate(TLangKeys.TAccAccountAddress.ColValidFrom, 'Valid From'));
  SetColumnTitle('valid_to', TLocalizationManager.Translate(TLangKeys.TAccAccountAddress.ColValidTo, 'Valid To'));
  SetColumnTitle('account_code', TLocalizationManager.Translate(TLangKeys.TAccAccountAddress.ColAccountCode, 'Account Code'));
end;

end.
