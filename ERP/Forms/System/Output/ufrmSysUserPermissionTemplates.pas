unit ufrmSysUserPermissionTemplates;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  SysUserPermissionTemplate.Service, SysUserPermissionTemplate, ufrmSysUserPermissionTemplate;

type
  TfrmSysUserPermissionTemplates = class(TfrmGrid<TSysUserPermissionTemplate, TSysUserPermissionTemplateService>)
  private
    FFixedUserId: Int64;
    FFixedUsername: string;
    FFixedTemplateId: Int64;
    FFixedTemplateName: string;
  public
    /// <summary>Grid'i tek kullanıcının şablonlarıyla sınırlar. Show'dan önce çağrılmalıdır.</summary>
    procedure SetFixedUser(AUserId: Int64; const AUsername: string);
    /// <summary>Grid'i tek şablonu kullanan kullanıcılarla sınırlar. Show'dan önce çağrılmalıdır.</summary>
    procedure SetFixedTemplate(ATemplateId: Int64; const ATemplateName: string);

    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

procedure TfrmSysUserPermissionTemplates.SetFixedUser(AUserId: Int64; const AUsername: string);
begin
  FFixedUserId := AUserId;
  FFixedUsername := AUsername;
  AddFixedFilter('sys_user_id', AUserId);
end;

procedure TfrmSysUserPermissionTemplates.SetFixedTemplate(ATemplateId: Int64; const ATemplateName: string);
begin
  FFixedTemplateId := ATemplateId;
  FFixedTemplateName := ATemplateName;
  AddFixedFilter('sys_permission_template_id', ATemplateId);
end;

function TfrmSysUserPermissionTemplates.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
var
  LNew: TSysUserPermissionTemplate;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmSysUserPermissionTemplate.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
  begin
    LNew := TSysUserPermissionTemplate.Create;
    if FFixedUserId > 0 then
    begin
      LNew.SysUserId := FFixedUserId;
      LNew.Username := FFixedUsername;
    end;
    if FFixedTemplateId > 0 then
    begin
      LNew.SysPermissionTemplateId := FFixedTemplateId;
      LNew.TemplateName := FFixedTemplateName;
    end;
    Result := TfrmSysUserPermissionTemplate.Create(Self, Service, LNew, AFormMode, Self.RefreshParentGrid);
  end
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSysUserPermissionTemplate.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmSysUserPermissionTemplates.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('sys_user_id', 0);
  SetColumnProperty('sys_permission_template_id', 0);
  SetColumnProperty('template_key', 0);
end;

procedure TfrmSysUserPermissionTemplates.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmSysUserPermissionTemplates.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSysUserPermissionTemplate.TitlePlural, 'User Permission Templates');
  if FFixedUsername <> '' then
    Self.Caption := Self.Caption + ' - ' + FFixedUsername;
  if FFixedTemplateName <> '' then
    Self.Caption := Self.Caption + ' - ' + FFixedTemplateName;

  SetColumnTitle('username', TLocalizationManager.Translate(TLangKeys.TSysUser.ColUserName, 'Username'));
  SetColumnTitle('full_name', TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColFullName, 'Full Name'));
  SetColumnTitle('template_name', TLocalizationManager.Translate(TLangKeys.TSysPermissionTemplate.ColTemplateName, 'Template Name'));
  SetColumnTitle('active', TLocalizationManager.Translate(TLangKeys.TSysPermissionTemplate.ColActive, 'Active'));
end;

end.
