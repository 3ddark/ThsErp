unit ufrmSysPermissionGroups;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, SysPermissionGroup.Service, SysPermissionGroup, ufrmSysPermissionGroup,
  LocalizationManager;

type
  TfrmSysPermissionGroups = class(TfrmGrid<TSysPermissionGroup, TSysPermissionGroupService>)
  public
    procedure DefineColumnWidths; override;
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

function TfrmSysPermissionGroups.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmSysPermissionGroup.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSysPermissionGroup.Create(Self, Service, TSysPermissionGroup.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSysPermissionGroup.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmSysPermissionGroups.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id',     0, TLocalizationManager.Translate('sys_permission_group.col_id', 'Id'));
  SetColumnProperty('key',  150, TLocalizationManager.Translate(TLangKeys.TPermissionGroup.ColKey, 'Group Key'));
  SetColumnProperty('name', 250, TLocalizationManager.Translate(TLangKeys.TPermissionGroup.ColName, 'Group Name'));
  SetColumnProperty('locale', 0, TLocalizationManager.Translate('sys_permission_group.col_locale', 'Locale'));
end;

procedure TfrmSysPermissionGroups.DefineFooterColumns;
begin
  inherited;
  AddFooterColumn('id', atCount, '#,##0');
end;

procedure TfrmSysPermissionGroups.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmSysPermissionGroups.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TPermissionGroup.TitlePlural, 'Permission Groups');
end;

end.
