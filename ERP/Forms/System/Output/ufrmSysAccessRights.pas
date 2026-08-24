unit ufrmSysAccessRights;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.UITypes, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus,
  ufrmGrid, SharedFormTypes, SysAccessRight.Service, SysAccessRight,
  ufrmSysAccessRight, LocalizationManager;

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
    Result := TfrmSysAccessRight.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSysAccessRight.Create(Self, Service, TSysAccessRight.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSysAccessRight.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmSysAccessRights.PreparePopupMenu;
begin
  inherited;
  AddPopupMenuSpliter();
  FmniCopyUserRights := AddMenu(TLocalizationManager.Translate('sys_access_right.popup.copy_user_rights', 'Kullanıcı Haklarını Kopyala'), 'mniCopyUserRights', mniCopyUserRightsClick, True, TextToShortCut('Ctrl+C'));
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

  // 1. Select Source User
  LFrmSourceUser := TfrmSysUsers.Create(Self, TSysUserService.Create, TSysUser.Create);
  try
    LFrmSourceUser.IsHelper := True;
    LFrmSourceUser.Caption := TLocalizationManager.Translate('sys_access_right.msg.select_source_user', 'Hakları Kopyalanacak Kaynak Kullanıcıyı Seçin');
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

  // 2. Select Target User
  LFrmTargetUser := TfrmSysUsers.Create(Self, TSysUserService.Create, TSysUser.Create);
  try
    LFrmTargetUser.IsHelper := True;
    LFrmTargetUser.Caption := TLocalizationManager.Translate('sys_access_right.msg.select_target_user', 'Hakların Aktarılacağı Hedef Kullanıcıyı Seçin');
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
    ShowMessage(TLocalizationManager.Translate('sys_access_right.msg.source_target_same', 'Kaynak ve hedef kullanıcı aynı olamaz.'));
    Exit;
  end;

  // 3. Confirm and copy
  if MessageDlg(Format(TLocalizationManager.Translate('sys_access_right.msg.confirm_copy', '"%s" kullanıcısının tüm haklarını "%s" kullanıcısına kopyalamak istediğinizden emin misiniz?' + sLineBreak + 
                       'Not: Hedef kullanıcının var olan hakları silinip kaynak kullanıcının hakları kopyalanacaktır.'), 
                       [LSourceUsername, LTargetUsername]), 
                mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    try
      Service.CopyUserAccessRights(LSourceUserId, LTargetUserId);
      ShowMessage(TLocalizationManager.Translate('sys_access_right.msg.copy_success', 'Haklar başarıyla kopyalandı.'));
      RefreshData();
    except
      on E: Exception do
        ShowMessage(TLocalizationManager.Translate('sys_access_right.msg.copy_error', 'Hata oluştu: ') + E.Message);
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
  SetColumnProperty('id',              0, '');
  SetColumnProperty('permission_id',   0, '');
  SetColumnProperty('user_id',         0, '');
  SetColumnProperty('locale',          0, '');

  SetColumnProperty('username',      120, TLocalizationManager.Translate('sys_access_right.col_username', 'Username'));
  SetColumnProperty('full_name', 150, TLocalizationManager.Translate('sys_access_right.col_user_full_name', 'Full Name'));
  SetColumnProperty('permission_name', 160, TLocalizationManager.Translate('sys_access_right.col_permission_name', 'Permission Name'));
  SetColumnProperty('permission_group', 160, TLocalizationManager.Translate('sys_access_right.col_permission_group', 'Permission Group'));
  SetColumnProperty('code', 70, TLocalizationManager.Translate('sys_access_right.col_code', 'Code'));
  SetColumnProperty('is_read',        50, TLocalizationManager.Translate('sys_access_right.col_is_read', 'Read'));
  SetColumnProperty('is_add',         50, TLocalizationManager.Translate('sys_access_right.col_is_add', 'Add'));
  SetColumnProperty('is_update',      60, TLocalizationManager.Translate('sys_access_right.col_is_update', 'Update'));
  SetColumnProperty('is_delete',      60, TLocalizationManager.Translate('sys_access_right.col_is_delete', 'Delete'));
  SetColumnProperty('is_special',     70, TLocalizationManager.Translate('sys_access_right.col_is_special', 'Special'));

  SetColumnIndex('username', 0);
  SetColumnIndex('full_name', 1);
  SetColumnIndex('permission_name', 2);
  SetColumnIndex('permission_group', 3);
  SetColumnIndex('code', 4);
  SetColumnIndex('is_read', 5);
  SetColumnIndex('is_add', 6);
  SetColumnIndex('is_update', 7);
  SetColumnIndex('is_delete', 8);
  SetColumnIndex('is_special', 9);
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
  Self.Caption := TLocalizationManager.Translate('sys_access_right.title_plural', 'User Access Rights');
  if Assigned(FmniCopyUserRights) then
    FmniCopyUserRights.Caption := TLocalizationManager.Translate('sys_access_right.popup.copy_user_rights', 'Kullanıcı Haklarını Kopyala');
end;

end.
