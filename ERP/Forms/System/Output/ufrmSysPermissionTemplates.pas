unit ufrmSysPermissionTemplates;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  SysPermissionTemplate.Service, SysPermissionTemplate, ufrmSysPermissionTemplate;

type
  TfrmSysPermissionTemplates = class(TfrmGrid<TSysPermissionTemplate, TSysPermissionTemplateService>)
  private
    FmniRights: TMenuItem;
    FmniUsers: TMenuItem;
    procedure mniRightsClick(Sender: TObject);
    procedure mniUsersClick(Sender: TObject);
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure PreparePopupMenu; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  ufrmSysPermissionTemplateRights, SysPermissionTemplateRight, SysPermissionTemplateRight.Service,  // şablon yetkileri
  ufrmSysUserPermissionTemplates, SysUserPermissionTemplate, SysUserPermissionTemplate.Service;     // şablonu kullanan kullanıcılar

function TfrmSysPermissionTemplates.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmSysPermissionTemplate.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSysPermissionTemplate.Create(Self, Service, TSysPermissionTemplate.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSysPermissionTemplate.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmSysPermissionTemplates.PreparePopupMenu;
begin
  inherited;
  AddPopupMenuSpliter();
  FmniRights := AddMenu(TLocalizationManager.Translate(TLangKeys.TSysPermissionTemplate.MenuRights, 'Template Rights'), 'mniTemplateRights', mniRightsClick);
  FmniUsers := AddMenu(TLocalizationManager.Translate(TLangKeys.TSysPermissionTemplate.MenuUsers, 'Users of Template'), 'mniTemplateUsers', mniUsersClick);
end;

procedure TfrmSysPermissionTemplates.mniRightsClick(Sender: TObject);
var
  LFrm: TfrmSysPermissionTemplateRights;
begin
  if Grd.DataSource.DataSet.IsEmpty then
    Exit;

  SetSelectedItem;
  LFrm := TfrmSysPermissionTemplateRights.Create(Self, TSysPermissionTemplateRightService.Create, TSysPermissionTemplateRight.Create);
  LFrm.SetFixedTemplate(Table.Id, Table.TemplateName);
  LFrm.Show;
end;

procedure TfrmSysPermissionTemplates.mniUsersClick(Sender: TObject);
var
  LFrm: TfrmSysUserPermissionTemplates;
begin
  if Grd.DataSource.DataSet.IsEmpty then
    Exit;

  SetSelectedItem;
  LFrm := TfrmSysUserPermissionTemplates.Create(Self, TSysUserPermissionTemplateService.Create, TSysUserPermissionTemplate.Create);
  LFrm.SetFixedTemplate(Table.Id, Table.TemplateName);
  LFrm.Show;
end;

procedure TfrmSysPermissionTemplates.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);
end;

procedure TfrmSysPermissionTemplates.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmSysPermissionTemplates.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSysPermissionTemplate.TitlePlural, 'Permission Templates');
  if Assigned(FmniRights) then
    FmniRights.Caption := TLocalizationManager.Translate(TLangKeys.TSysPermissionTemplate.MenuRights, 'Template Rights');
  if Assigned(FmniUsers) then
    FmniUsers.Caption := TLocalizationManager.Translate(TLangKeys.TSysPermissionTemplate.MenuUsers, 'Users of Template');

  SetColumnTitle('template_key', TLocalizationManager.Translate(TLangKeys.TSysPermissionTemplate.ColTemplateKey, 'Template Key'));
  SetColumnTitle('template_name', TLocalizationManager.Translate(TLangKeys.TSysPermissionTemplate.ColTemplateName, 'Template Name'));
  SetColumnTitle('description', TLocalizationManager.Translate(TLangKeys.TSysPermissionTemplate.ColDescription, 'Description'));
  SetColumnTitle('active', TLocalizationManager.Translate(TLangKeys.TSysPermissionTemplate.ColActive, 'Active'));
  SetColumnTitle('right_count', TLocalizationManager.Translate(TLangKeys.TSysPermissionTemplate.ColRightCount, 'Right Count'));
  SetColumnTitle('user_count', TLocalizationManager.Translate(TLangKeys.TSysPermissionTemplate.ColUserCount, 'User Count'));
end;

end.
