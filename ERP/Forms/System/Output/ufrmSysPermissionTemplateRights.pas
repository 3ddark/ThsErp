unit ufrmSysPermissionTemplateRights;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes, System.UITypes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  SysPermissionTemplateRight.Service, SysPermissionTemplateRight, ufrmSysPermissionTemplateRight;

type
  TfrmSysPermissionTemplateRights = class(TfrmGrid<TSysPermissionTemplateRight, TSysPermissionTemplateRightService>)
  private
    FFixedTemplateId: Int64;
    FFixedTemplateName: string;
    FmniAddMissing: TMenuItem;
    FmniGrantAll: TMenuItem;
    FmniRevokeAll: TMenuItem;
    function ResolveTemplate(out ATemplateId: Int64; out ATemplateName: string): Boolean;
    procedure SetAllFlags(AValue: Boolean);
    procedure mniAddMissingClick(Sender: TObject);
    procedure mniGrantAllClick(Sender: TObject);
    procedure mniRevokeAllClick(Sender: TObject);
  public
    /// <summary>Grid'i tek bir şablonun yetkileriyle sınırlar. Show'dan önce çağrılmalıdır.</summary>
    procedure SetFixedTemplate(ATemplateId: Int64; const ATemplateName: string);

    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure PreparePopupMenu; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

procedure TfrmSysPermissionTemplateRights.SetFixedTemplate(ATemplateId: Int64; const ATemplateName: string);
begin
  FFixedTemplateId := ATemplateId;
  FFixedTemplateName := ATemplateName;
  AddFixedFilter('sys_permission_template_id', ATemplateId);
end;

function TfrmSysPermissionTemplateRights.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
var
  LNew: TSysPermissionTemplateRight;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmSysPermissionTemplateRight.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
  begin
    LNew := TSysPermissionTemplateRight.Create;
    if FFixedTemplateId > 0 then
    begin
      LNew.SysPermissionTemplateId := FFixedTemplateId;
      LNew.TemplateName := FFixedTemplateName;
    end;
    Result := TfrmSysPermissionTemplateRight.Create(Self, Service, LNew, AFormMode, Self.RefreshParentGrid);
  end
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSysPermissionTemplateRight.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmSysPermissionTemplateRights.PreparePopupMenu;
begin
  inherited;
  AddPopupMenuSpliter();
  FmniAddMissing := AddMenu(TLocalizationManager.Translate(TLangKeys.TSysPermissionTemplateRight.MenuAddMissing, 'Add Missing Permissions'), 'mniAddMissing', mniAddMissingClick);
  FmniGrantAll := AddMenu(TLocalizationManager.Translate(TLangKeys.TSysPermissionTemplateRight.MenuGrantAll, 'Grant All Rights'), 'mniGrantAll', mniGrantAllClick);
  FmniRevokeAll := AddMenu(TLocalizationManager.Translate(TLangKeys.TSysPermissionTemplateRight.MenuRevokeAll, 'Revoke All Rights'), 'mniRevokeAll', mniRevokeAllClick);
end;

function TfrmSysPermissionTemplateRights.ResolveTemplate(out ATemplateId: Int64; out ATemplateName: string): Boolean;
begin
  // Sabit şablon yoksa seçili satırın şablonu kullanılır
  ATemplateId := FFixedTemplateId;
  ATemplateName := FFixedTemplateName;
  if (ATemplateId <= 0) and not Grd.DataSource.DataSet.IsEmpty then
  begin
    ATemplateId := Grd.DataSource.DataSet.FieldByName('sys_permission_template_id').AsLargeInt;
    ATemplateName := Grd.DataSource.DataSet.FieldByName('template_name').AsString;
  end;

  Result := ATemplateId > 0;
  if not Result then
    ShowMessage(TLocalizationManager.Translate(TLangKeys.TSysPermissionTemplateRight.MsgSelectTemplate, 'Select a template first.'));
end;

procedure TfrmSysPermissionTemplateRights.mniAddMissingClick(Sender: TObject);
var
  LTemplateId: Int64;
  LTemplateName: string;
  LCount: Integer;
begin
  if not ResolveTemplate(LTemplateId, LTemplateName) then
    Exit;

  LCount := Service.AddMissingPermissions(LTemplateId);
  RefreshData;
  ShowMessage(Format(TLocalizationManager.Translate(TLangKeys.TSysPermissionTemplateRight.MsgAddedCount, '%d permissions added to the template.'), [LCount]));
end;

procedure TfrmSysPermissionTemplateRights.SetAllFlags(AValue: Boolean);
var
  LTemplateId: Int64;
  LTemplateName: string;
begin
  if not ResolveTemplate(LTemplateId, LTemplateName) then
    Exit;

  if MessageDlg(
       Format(TLocalizationManager.Translate(TLangKeys.TSysPermissionTemplateRight.MsgConfirmAll, 'All rights of template "%s" will be updated. Continue?'), [LTemplateName]),
       mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  Service.SetAllFlags(LTemplateId, AValue);
  RefreshData;
end;

procedure TfrmSysPermissionTemplateRights.mniGrantAllClick(Sender: TObject);
begin
  SetAllFlags(True);
end;

procedure TfrmSysPermissionTemplateRights.mniRevokeAllClick(Sender: TObject);
begin
  SetAllFlags(False);
end;

procedure TfrmSysPermissionTemplateRights.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('sys_permission_template_id', 0);
  SetColumnProperty('sys_permission_id', 0);
  SetColumnProperty('template_key', 0);
  SetColumnProperty('locale', 0);
end;

procedure TfrmSysPermissionTemplateRights.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmSysPermissionTemplateRights.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSysPermissionTemplateRight.TitlePlural, 'Template Rights');
  if FFixedTemplateName <> '' then
    Self.Caption := Self.Caption + ' - ' + FFixedTemplateName;

  if Assigned(FmniAddMissing) then
    FmniAddMissing.Caption := TLocalizationManager.Translate(TLangKeys.TSysPermissionTemplateRight.MenuAddMissing, 'Add Missing Permissions');
  if Assigned(FmniGrantAll) then
    FmniGrantAll.Caption := TLocalizationManager.Translate(TLangKeys.TSysPermissionTemplateRight.MenuGrantAll, 'Grant All Rights');
  if Assigned(FmniRevokeAll) then
    FmniRevokeAll.Caption := TLocalizationManager.Translate(TLangKeys.TSysPermissionTemplateRight.MenuRevokeAll, 'Revoke All Rights');

  SetColumnTitle('template_name', TLocalizationManager.Translate(TLangKeys.TSysPermissionTemplate.ColTemplateName, 'Template Name'));
  SetColumnTitle('permission_code', TLocalizationManager.Translate(TLangKeys.TSysPermission.ColPermissionCode, 'Permission Code'));
  SetColumnTitle('permission_key', TLocalizationManager.Translate(TLangKeys.TSysPermission.ColKey, 'Permission Key'));
  SetColumnTitle('permission_name', TLocalizationManager.Translate(TLangKeys.TSysPermission.ColPermissionName, 'Permission Name'));
  SetColumnTitle('permission_group_name', TLocalizationManager.Translate(TLangKeys.TSysPermissionGroup.ColGroupName, 'Permission Group'));
  SetColumnTitle('is_read', TLocalizationManager.Translate(TLangKeys.TSysAccessRight.ColRead, 'Read'));
  SetColumnTitle('is_add', TLocalizationManager.Translate(TLangKeys.TSysAccessRight.ColAdd, 'Add'));
  SetColumnTitle('is_update', TLocalizationManager.Translate(TLangKeys.TSysAccessRight.ColUpdate, 'Update'));
  SetColumnTitle('is_delete', TLocalizationManager.Translate(TLangKeys.TSysAccessRight.ColDelete, 'Delete'));
  SetColumnTitle('is_special', TLocalizationManager.Translate(TLangKeys.TSysAccessRight.ColSpecial, 'Special'));
end;

end.
