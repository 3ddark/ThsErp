unit ufrmSysPermissions;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, SysPermission.Service, SysPermission, ufrmSysPermission,
  LocalizationManager;

type
  TfrmSysPermissions = class(TfrmGrid<TSysPermission, TSysPermissionService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

function TfrmSysPermissions.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmSysPermission.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSysPermission.Create(Self, Service, TSysPermission.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSysPermission.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmSysPermissions.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id',          0, TLocalizationManager.Translate('sys_permission.col_id', 'Id'));
  SetColumnProperty('code',      100, TLocalizationManager.Translate(TLangKeys.TSysPermission.ColCode, 'Permission Code'));
  SetColumnProperty('key',       150, TLocalizationManager.Translate(TLangKeys.TSysPermission.ColKey, 'Key'));
  SetColumnProperty('name',      250, TLocalizationManager.Translate(TLangKeys.TSysPermission.ColName, 'Permission Name'));
  SetColumnProperty('group_id',    0, TLocalizationManager.Translate('sys_permission.col_group_id', 'Group ID'));
  SetColumnProperty('group_key', 120, TLocalizationManager.Translate(TLangKeys.TSysPermission.ColGroupKey, 'Group Key'));
  SetColumnProperty('group_name', 200, TLocalizationManager.Translate(TLangKeys.TSysPermission.ColGroupName, 'Group Name'));
  SetColumnProperty('locale',      0, TLocalizationManager.Translate('sys_permission.col_locale', 'Locale'));
end;

procedure TfrmSysPermissions.DefineFooterColumns;
begin
  // No footer columns
end;

procedure TfrmSysPermissions.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmSysPermissions.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSysPermission.TitlePlural, 'Permissions');
end;

end.
