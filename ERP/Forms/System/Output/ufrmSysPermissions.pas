unit ufrmSysPermissions;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  SysPermission.Service, SysPermission, ufrmSysPermission;

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
    Result := TfrmSysPermission.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSysPermission.Create(Self, Service, TSysPermission.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSysPermission.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmSysPermissions.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('code', 100);
  SetColumnProperty('key', 150);
  SetColumnProperty('name', 250);
  SetColumnProperty('group_id', 0);
  SetColumnProperty('group_key', 120);
  SetColumnProperty('group_name', 200);
  SetColumnProperty('locale', 0);
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

  SetColumnTitle('code',      TLocalizationManager.Translate(TLangKeys.TSysPermission.ColPermissionCode, 'Permission Code'));
  SetColumnTitle('key',       TLocalizationManager.Translate(TLangKeys.TSysPermission.ColKey, 'Key'));
  SetColumnTitle('name',      TLocalizationManager.Translate(TLangKeys.TSysPermission.ColPermissionName, 'Permission Name'));
  SetColumnTitle('group_id',  TLocalizationManager.Translate(TLangKeys.TSysPermission.ColGroupId, 'Group Id'));
  SetColumnTitle('group_key',  TLocalizationManager.Translate(TLangKeys.TSysPermissionGroup.ColGroupKey, 'Group Key'));
  SetColumnTitle('group_name', TLocalizationManager.Translate(TLangKeys.TSysPermissionGroup.ColGroupName, 'Group Name'));
  SetColumnTitle('locale',     TLocalizationManager.Translate(TLangKeys.TSysLanguage.ColLocale, 'Locale'));
end;

end.
