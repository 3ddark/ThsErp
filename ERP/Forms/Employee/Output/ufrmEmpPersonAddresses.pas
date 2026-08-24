unit ufrmEmpPersonAddresses;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, EmpPersonAddress.Service, EmpPersonAddress, ufrmEmpPersonAddress,
  LocalizationManager;

type
  TfrmEmpPersonAddresses = class(TfrmGrid<TEmpPersonAddress, TEmpPersonAddressService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

function TfrmEmpPersonAddresses.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmEmpPersonAddress.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmEmpPersonAddress.Create(Self, Service, TEmpPersonAddress.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmEmpPersonAddress.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmEmpPersonAddresses.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0, TLocalizationManager.Translate('emp_person_address.col_id', 'Id'));
  SetColumnProperty('person_id', 0, TLocalizationManager.Translate('emp_person_address.col_person_id', 'Personel Id'));
  SetColumnProperty('address_id', 0, TLocalizationManager.Translate('emp_person_address.col_address_id', 'Adres Id'));
  SetColumnProperty('address_type', 100, TLocalizationManager.Translate('emp_person_address.col_address_type', 'Adres Tipi'));
  SetColumnProperty('is_primary', 80, TLocalizationManager.Translate('emp_person_address.col_is_primary', 'Birincil'));
  SetColumnProperty('valid_from', 90, TLocalizationManager.Translate('emp_person_address.col_valid_from', 'Başlangıç'));
  SetColumnProperty('valid_to', 90, TLocalizationManager.Translate('emp_person_address.col_valid_to', 'Bitiş'));
end;

procedure TfrmEmpPersonAddresses.DefineFooterColumns;
begin
  inherited;
  AddFooterColumn('id', atCount, '#,##0');
end;

procedure TfrmEmpPersonAddresses.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
end;

procedure TfrmEmpPersonAddresses.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate('emp_person_address.title_plural', 'Personel Adresleri');
end;

end.
