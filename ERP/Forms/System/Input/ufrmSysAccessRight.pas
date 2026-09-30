unit ufrmSysAccessRight;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Samples.Spin, Vcl.ComCtrls,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  SysAccessRight.Service, SysAccessRight;

type
  TfrmSysAccessRight = class(TfrmInputSimpleDB<TSysAccessRight, TSysAccessRightService>)
    pnlContent: TPanel;
    lblSysUserId: TLabel;
    edtSysUserId: TEdit;
    lblSysPermissionId: TLabel;
    edtSysPermissionId: TEdit;
    chkIsRead: TCheckBox;
    chkIsAdd: TCheckBox;
    chkIsUpdate: TCheckBox;
    chkIsDelete: TCheckBox;
    chkIsSpecial: TCheckBox;
    lblGrant: TLabel;
    lblDeny: TLabel;
    chkDenyRead: TCheckBox;
    chkDenyAdd: TCheckBox;
    chkDenyUpdate: TCheckBox;
    chkDenyDelete: TCheckBox;
    chkDenySpecial: TCheckBox;
  published
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure RefreshData; override;
    procedure HelperProcess(Sender: TObject);
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  Data.DB,
  ufrmSysUsers, SysUser, SysUser.Service,                    // TfrmSysUsers helper output form
  ufrmSysPermissions, SysPermission, SysPermission.Service;  // TfrmSysPermissions helper output form

procedure TfrmSysAccessRight.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.IsRead := chkIsRead.Checked;
  Table.IsAdd := chkIsAdd.Checked;
  Table.IsUpdate := chkIsUpdate.Checked;
  Table.IsDelete := chkIsDelete.Checked;
  Table.IsSpecial := chkIsSpecial.Checked;
  Table.DenyRead := chkDenyRead.Checked;
  Table.DenyAdd := chkDenyAdd.Checked;
  Table.DenyUpdate := chkDenyUpdate.Checked;
  Table.DenyDelete := chkDenyDelete.Checked;
  Table.DenySpecial := chkDenySpecial.Checked;
  inherited;
end;

procedure TfrmSysAccessRight.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtSysUserId.OnHelperProcess := HelperProcess;
  edtSysPermissionId.OnHelperProcess := HelperProcess;
end;

procedure TfrmSysAccessRight.FormShow(Sender: TObject);
begin
  inherited;
  if edtSysUserId.CanFocus then
    edtSysUserId.SetFocus;
end;

procedure TfrmSysAccessRight.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSysAccessRight.TitleSingular, 'User Access Right');
  lblSysUserId.Caption := TLocalizationManager.Translate(TLangKeys.TSysUser.ColUserName, 'User');
  lblSysPermissionId.Caption := TLocalizationManager.Translate(TLangKeys.TSysPermission.ColPermissionName, 'Permission Name');
  chkIsRead.Caption := TLocalizationManager.Translate(TLangKeys.TSysAccessRight.ColRead, 'Read');
  chkIsAdd.Caption := TLocalizationManager.Translate(TLangKeys.TSysAccessRight.ColAdd, 'Add');
  chkIsUpdate.Caption := TLocalizationManager.Translate(TLangKeys.TSysAccessRight.ColUpdate, 'Update');
  chkIsDelete.Caption := TLocalizationManager.Translate(TLangKeys.TSysAccessRight.ColDelete, 'Delete');
  chkIsSpecial.Caption := TLocalizationManager.Translate(TLangKeys.TSysAccessRight.ColSpecial, 'Special');

  // Override: şablon haklarına ek izin / engelleme
  lblGrant.Caption := TLocalizationManager.Translate(TLangKeys.TSysAccessRight.LblGrant, 'Extra Grant (on top of templates)');
  lblDeny.Caption := TLocalizationManager.Translate(TLangKeys.TSysAccessRight.LblDeny, 'Deny (even if granted by template)');
  chkDenyRead.Caption := chkIsRead.Caption;
  chkDenyAdd.Caption := chkIsAdd.Caption;
  chkDenyUpdate.Caption := chkIsUpdate.Caption;
  chkDenyDelete.Caption := chkIsDelete.Caption;
  chkDenySpecial.Caption := chkIsSpecial.Caption;
end;

procedure TfrmSysAccessRight.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmUser: TfrmSysUsers;
  LFrmPermission: TfrmSysPermissions;
  LField: TField;
begin
  if Sender is TEdit then
  begin
    LEdit := (Sender as TEdit);
    if LEdit.Name = edtSysUserId.Name then
    begin
      LFrmUser := TfrmSysUsers.Create(LEdit, TSysUserService.Create, TSysUser.Create);
      try
        LFrmUser.IsHelper := True;
        LFrmUser.ShowModal;
        if LFrmUser.DataTransfer then
          if LFrmUser.CleanAndClose then
          begin
            Table.SysUserId := 0;
            Table.Username := '';
            LEdit.Clear;
          end
          else
          begin
            Table.SysUserId := LFrmUser.Table.Id;
            Table.Username := LFrmUser.Table.Username;
            LEdit.Text := Table.Username;
          end;
      finally
        LFrmUser.Free;
      end;
    end
    else if LEdit.Name = edtSysPermissionId.Name then
    begin
      LFrmPermission := TfrmSysPermissions.Create(LEdit, TSysPermissionService.Create, TSysPermission.Create);
      try
        LFrmPermission.IsHelper := True;
        LFrmPermission.ShowModal;
        if LFrmPermission.DataTransfer then
          if LFrmPermission.CleanAndClose then
          begin
            Table.SysPermissionId := 0;
            Table.PermissionName := '';
            LEdit.Clear;
          end
          else
          begin
            Table.SysPermissionId := LFrmPermission.Table.Id;
            // Review ekranıyla aynı metni göster: çevrilmiş izin adı, yoksa anahtar
            LField := nil;
            if Assigned(LFrmPermission.Qry) and LFrmPermission.Qry.Active then
              LField := LFrmPermission.Qry.FindField('permission_name');
            if Assigned(LField) and (LField.AsString <> '') then
              Table.PermissionName := LField.AsString
            else
              Table.PermissionName := LFrmPermission.Table.PermissionKey;
            LEdit.Text := Table.PermissionName;
          end;
      finally
        LFrmPermission.Free;
      end;
    end;
  end;
end;

procedure TfrmSysAccessRight.RefreshData;
begin
  inherited;
  if Table.SysUserId > 0 then
    edtSysUserId.Text := Table.Username
  else
    edtSysUserId.Text := '';

  if Table.SysPermissionId > 0 then
    edtSysPermissionId.Text := Table.PermissionName
  else
    edtSysPermissionId.Text := '';

  chkIsRead.Checked := Table.IsRead;
  chkIsAdd.Checked := Table.IsAdd;
  chkIsUpdate.Checked := Table.IsUpdate;
  chkIsDelete.Checked := Table.IsDelete;
  chkIsSpecial.Checked := Table.IsSpecial;
  chkDenyRead.Checked := Table.DenyRead;
  chkDenyAdd.Checked := Table.DenyAdd;
  chkDenyUpdate.Checked := Table.DenyUpdate;
  chkDenyDelete.Checked := Table.DenyDelete;
  chkDenySpecial.Checked := Table.DenySpecial;
end;

end.
