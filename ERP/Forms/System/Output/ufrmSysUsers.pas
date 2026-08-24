unit ufrmSysUsers;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, SysUser.Service, SysUser, ufrmSysUser, LocalizationManager;

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
    Result := TfrmSysUser.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSysUser.Create(Self, Service, TSysUser.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSysUser.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmSysUsers.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id',              0, TLocalizationManager.Translate('sys_user.col_id', 'Id'));
  SetColumnProperty('username',      120, TLocalizationManager.Translate('sys_user.col_username', 'Kullanıcı Adı'));
  SetColumnProperty('person_id',       0, TLocalizationManager.Translate('sys_user.col_person_id', 'Personel ID'));
  SetColumnProperty('person_name',   120, TLocalizationManager.Translate('sys_user.col_person_name', 'Adı'));
  SetColumnProperty('person_surname',120, TLocalizationManager.Translate('sys_user.col_person_surname', 'Soyadı'));
  SetColumnProperty('person_section',120, TLocalizationManager.Translate('sys_user.col_person_section', 'Bölümü'));
  SetColumnProperty('person_unit',   120, TLocalizationManager.Translate('sys_user.col_person_unit', 'Birimi'));
  SetColumnProperty('active',         60, TLocalizationManager.Translate('sys_user.col_is_active', 'Aktif'));
  SetColumnProperty('manager',        70, TLocalizationManager.Translate('sys_user.col_is_admin', 'Yönetici'));
  SetColumnProperty('super_user',     80, TLocalizationManager.Translate('sys_user.col_is_superuser', 'Süper Kullanıcı'));
  SetColumnProperty('ip_address',    100, TLocalizationManager.Translate('sys_user.col_ip_address', 'IP Adresi'));
  SetColumnProperty('mac_address',   100, TLocalizationManager.Translate('sys_user.col_mac_address', 'MAC Adresi'));
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
  Self.Caption := TLocalizationManager.Translate('sys_user.title_plural', 'Users');
end;

end.
