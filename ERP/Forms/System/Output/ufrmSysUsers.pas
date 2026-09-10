unit ufrmSysUsers;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  SysUser.Service, SysUser, ufrmSysUser;

type
  TfrmSysUsers = class(TfrmGrid<TSysUser, TSysUserService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

function TfrmSysUsers.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmSysUser.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSysUser.Create(Self, Service, TSysUser.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSysUser.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmSysUsers.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('username', 120);
  SetColumnProperty('user_password', 0);
  SetColumnProperty('emp_employee_id', 0);
  SetColumnProperty('person_name', 120);
  SetColumnProperty('person_surname', 120);
  SetColumnProperty('person_section', 120);
  SetColumnProperty('person_unit', 120);
  SetColumnProperty('active', 60);
  SetColumnProperty('manager', 70);
  SetColumnProperty('super_user', 80);
  SetColumnProperty('ip_address', 100);
  SetColumnProperty('mac_address', 100);
end;

procedure TfrmSysUsers.DefineFooterColumns;
begin
  inherited;
  AddFooterColumn('id', atCount, '#,##0');
end;

procedure TfrmSysUsers.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmSysUsers.ApplyLocalization;
begin
  inherited;

  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSysUser.TitlePlural, 'Users');

  SetColumnTitle('id',              'Id');
  SetColumnTitle('username',        TLocalizationManager.Translate(TLangKeys.TSysUser.ColUserName, 'Username'));
  SetColumnTitle('emp_employee_id', TLocalizationManager.Translate(TLangKeys.TSysUser.ColEmployeeId, 'Employee ID'));
  SetColumnTitle('person_name',     TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColName, 'First Name'));
  SetColumnTitle('person_surname',  TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColSurname, 'Surname'));
  SetColumnTitle('person_section',  TLocalizationManager.Translate(TLangKeys.TEmpSection.ColSectionName, 'Section'));
  SetColumnTitle('person_unit',     TLocalizationManager.Translate(TLangKeys.TEmpUnit.ColUnitName, 'Unit'));
  SetColumnTitle('active',          TLocalizationManager.Translate(TLangKeys.TSysUser.ColActive, 'Active'));
  SetColumnTitle('manager',         TLocalizationManager.Translate(TLangKeys.TSysUser.ColManager, 'Manager'));
  SetColumnTitle('super_user',      TLocalizationManager.Translate(TLangKeys.TSysUser.ColSuperUser, 'Super User'));
  SetColumnTitle('ip_address',      TLocalizationManager.Translate(TLangKeys.TSysUser.ColIpAddress, 'IP Address'));
  SetColumnTitle('mac_address',     TLocalizationManager.Translate(TLangKeys.TSysUser.ColMacAddress, 'MAC Address'));
end;

end.
