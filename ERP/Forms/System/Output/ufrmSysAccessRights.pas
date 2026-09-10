unit ufrmSysAccessRights;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes, System.UITypes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  SysAccessRight.Service, SysAccessRight, ufrmSysAccessRight;

type
  TfrmSysAccessRights = class(TfrmGrid<TSysAccessRight, TSysAccessRightService>)
  private
    FmniCopyUserRights: TMenuItem;
    procedure mniCopyUserRightsClick(Sender: TObject);
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure PreparePopupMenu; override;
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

uses
  ufrmSysUsers, SysUser, SysUser.Service, Vcl.DBGrids;

{$R *.dfm}

function TfrmSysAccessRights.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmSysAccessRight.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSysAccessRight.Create(Self, Service, TSysAccessRight.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSysAccessRight.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmSysAccessRights.PreparePopupMenu;
begin
  inherited;
  AddPopupMenuSpliter();
  FmniCopyUserRights := AddMenu(TLocalizationManager.Translate(TLangKeys.TSysAccessRight.MenuCopUserRights, 'Copy User Rights'), 'mniCopyUserRights', mniCopyUserRightsClick, True, TextToShortCut('Ctrl+C'));
end;

procedure TfrmSysAccessRights.mniCopyUserRightsClick(Sender: TObject);
var
  LFrmSourceUser, LFrmTargetUser: TfrmSysUsers;
  LSourceUserId, LTargetUserId: Int64;
  LSourceUsername, LTargetUsername: string;
begin
  LSourceUserId := 0;
  LTargetUserId := 0;
  LSourceUsername := '';
  LTargetUsername := '';

  LFrmSourceUser := TfrmSysUsers.Create(Self, TSysUserService.Create, TSysUser.Create);
  try
    LFrmSourceUser.IsHelper := True;
    LFrmSourceUser.Caption := TLocalizationManager.Translate(TLangKeys.TSysAccessRight.MsgSelectSourceUser, 'Select the source user whose rights will be copied.');
    LFrmSourceUser.ShowModal;
    if LFrmSourceUser.DataTransfer and not LFrmSourceUser.CleanAndClose then
    begin
      LSourceUserId := LFrmSourceUser.Table.Id;
      LSourceUsername := LFrmSourceUser.Table.Username;
    end;
  finally
    LFrmSourceUser.Free;
  end;

  if LSourceUserId = 0 then Exit;

  LFrmTargetUser := TfrmSysUsers.Create(Self, TSysUserService.Create, TSysUser.Create);
  try
    LFrmTargetUser.IsHelper := True;
    LFrmTargetUser.Caption := TLocalizationManager.Translate(TLangKeys.TSysAccessRight.MsgSelectTargetUser, 'Select the target user to whom the rights will be transferred.');
    LFrmTargetUser.ShowModal;
    if LFrmTargetUser.DataTransfer and not LFrmTargetUser.CleanAndClose then
    begin
      LTargetUserId := LFrmTargetUser.Table.Id;
      LTargetUsername := LFrmTargetUser.Table.Username;
    end;
  finally
    LFrmTargetUser.Free;
  end;

  if LTargetUserId = 0 then Exit;

  if LSourceUserId = LTargetUserId then
  begin
    ShowMessage(TLocalizationManager.Translate(TLangKeys.TSysAccessRight.MsgSourceTargetSame, 'The source and target users cannot be the same.'));
    Exit;
  end;

  if MessageDlg(Format(TLocalizationManager.Translate(TLangKeys.TSysAccessRight.MsgConfirmCopy, 'Are you sure you want to copy all rights of user "%s" to user "%s"?' + sLineBreak +
                       'Note: The target user is existing rights will be deleted, and the source user is rights will be copied.'),
                       [LSourceUsername, LTargetUsername]),
                mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    try
      Service.CopyUserAccessRights(LSourceUserId, LTargetUserId);
      ShowMessage(TLocalizationManager.Translate(TLangKeys.TSysAccessRight.MsgCopySuccess, 'The rights were successfully copied.'));
      RefreshData();
    except
      on E: Exception do
        ShowMessage(TLocalizationManager.Translate(TLangKeys.TSysAccessRight.MsgCopyError, 'An error occurred: ') + E.Message);
    end;
  end;
end;

procedure TfrmSysAccessRights.DefineColumnWidths;
  procedure SetColumnIndex(const AFieldName: string; AIndex: Integer);
  var
    i: Integer;
  begin
    for i := 0 to Grd.Columns.Count - 1 do
    begin
      if SameText(Grd.Columns[i].FieldName, AFieldName) then
      begin
        Grd.Columns[i].Index := AIndex;
        Break;
      end;
    end;
  end;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('sys_permission_id', 0);
  SetColumnProperty('sys_user_id', 0);
  SetColumnProperty('locale', 0);
end;

procedure TfrmSysAccessRights.DefineFooterColumns;
begin
  inherited;
  AddFooterColumn('id', atCount, '#,##0');
end;

procedure TfrmSysAccessRights.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmSysAccessRights.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSysAccessRight.TitlePlural, 'User Access Rights');
  if Assigned(FmniCopyUserRights) then
    FmniCopyUserRights.Caption := TLocalizationManager.Translate(TLangKeys.TSysAccessRight.MenuCopUserRights, 'Copy User Rights');

  SetColumnTitle('username', TLocalizationManager.Translate(TLangKeys.TSysUser.ColUserName, 'Username'));
  SetColumnTitle('full_name', TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColFullName, 'Full Name'));
  SetColumnTitle('permission_code', TLocalizationManager.Translate(TLangKeys.TSysPermission.ColPermissionCode, 'Permission Code'));
  SetColumnTitle('permission_name', TLocalizationManager.Translate(TLangKeys.TSysPermission.ColPermissionName, 'Permission Name'));
  SetColumnTitle('permission_group_name', TLocalizationManager.Translate(TLangKeys.TSysPermissionGroup.ColGroupName, 'Permission Group'));
  SetColumnTitle('sys_permission_id', TLocalizationManager.Translate(TLangKeys.TSysUser.ColSysPermissionId, 'SysPermission Id'));
  SetColumnTitle('is_read', TLocalizationManager.Translate(TLangKeys.TSysAccessRight.ColRead, 'Read'));
  SetColumnTitle('is_add', TLocalizationManager.Translate(TLangKeys.TSysAccessRight.ColAdd, 'Add'));
  SetColumnTitle('is_update', TLocalizationManager.Translate(TLangKeys.TSysAccessRight.ColUpdate, 'Update'));
  SetColumnTitle('is_delete', TLocalizationManager.Translate(TLangKeys.TSysAccessRight.ColDelete, 'Delete'));
  SetColumnTitle('is_special', TLocalizationManager.Translate(TLangKeys.TSysAccessRight.ColSpecial, 'Special'));
  SetColumnTitle('sys_user_id', TLocalizationManager.Translate(TLangKeys.TSysUser.ColSysUserId, 'SysUser Id'));
  SetColumnTitle('locale', TLocalizationManager.Translate(TLangKeys.TSysLanguage.ColLocale, 'Locale'));
end;

end.
