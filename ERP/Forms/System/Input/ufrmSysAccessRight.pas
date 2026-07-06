unit ufrmSysAccessRight;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Samples.Spin, Vcl.ComCtrls, ufrmInputSimpleDB, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  SysAccessRight.Service, SysAccessRight;

type
  TfrmSysAccessRight = class(TfrmInputSimpleDB<TSysAccessRight, TSysAccessRightService>)
    pnlContent: TPanel;
    lblUserId: TLabel;
    edtUserId: TEdit;
    lblPermissionId: TLabel;
    edtPermissionId: TEdit;
    chkIsRead: TCheckBox;
    chkIsAdd: TCheckBox;
    chkIsUpdate: TCheckBox;
    chkIsDelete: TCheckBox;
    chkIsSpecial: TCheckBox;
  published
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure InitializeInputCase; override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure RefreshData; override;
    procedure HelperProcess(Sender: TObject);
  end;

implementation

{$R *.dfm}

uses
  ufrmSysUsers, SysUser, SysUser.Service,
  ufrmSysPermissions, SysPermission, SysPermission.Service;

procedure TfrmSysAccessRight.BtnAcceptClick(Sender: TObject);
begin
  Table.UserId := edtUserId.Tag;
  Table.PermissionId := edtPermissionId.Tag;
  Table.IsRead := chkIsRead.Checked;
  Table.IsAdd := chkIsAdd.Checked;
  Table.IsUpdate := chkIsUpdate.Checked;
  Table.IsDelete := chkIsDelete.Checked;
  Table.IsSpecial := chkIsSpecial.Checked;
  inherited;
end;

procedure TfrmSysAccessRight.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtUserId.OnHelperProcess := HelperProcess;
  edtPermissionId.OnHelperProcess := HelperProcess;
end;

procedure TfrmSysAccessRight.InitializeInputCase;
begin
  inherited;
  edtUserId.thsInputDataType := itInteger;
  edtPermissionId.thsInputDataType := itInteger;
end;

procedure TfrmSysAccessRight.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'Access Right';
  edtUserId.SetFocus;
end;

procedure TfrmSysAccessRight.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmUser: TfrmSysUsers;
  LFrmPermission: TfrmSysPermissions;
begin
  if Sender is TEdit then
  begin
    LEdit := (Sender as TEdit);
    if LEdit.Name = edtUserId.Name then
    begin
      LFrmUser := TfrmSysUsers.Create(LEdit, TSysUserService.Create, TSysUser.Create);
      try
        LFrmUser.IsHelper := True;
        LFrmUser.ShowModal;
        if LFrmUser.DataTransfer then
          if LFrmUser.CleanAndClose then
          begin
            edtUserId.Tag := 0;
            LEdit.Clear;
          end
          else
          begin
            edtUserId.Tag := LFrmUser.Table.Id;
            (Sender as TEdit).Text := LFrmUser.Table.Username;
          end;
      finally
        LFrmUser.Free;
      end;
    end
    else if (Sender as TEdit).Name = edtPermissionId.Name then
    begin
      LFrmPermission := TfrmSysPermissions.Create((Sender as TEdit), TSysPermissionService.Create, TSysPermission.Create);
      try
        LFrmPermission.IsHelper := True;
        LFrmPermission.ShowModal;
        if LFrmPermission.DataTransfer then
          if LFrmPermission.CleanAndClose then
          begin
            edtPermissionId.Tag := 0;
            (Sender as TEdit).Clear;
          end
          else
          begin
            edtPermissionId.Tag := LFrmPermission.Table.Id;
            (Sender as TEdit).Text := LFrmPermission.Table.PermissionName;
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
  edtUserId.Text := Table.UserId.ToString;
  edtPermissionId.Text := Table.PermissionId.ToString;
  edtUserId.Tag := Table.UserId;
  edtPermissionId.Tag := Table.PermissionId;
  chkIsRead.Checked := Table.IsRead;
  chkIsAdd.Checked := Table.IsAdd;
  chkIsUpdate.Checked := Table.IsUpdate;
  chkIsDelete.Checked := Table.IsDelete;
  chkIsSpecial.Checked := Table.IsSpecial;
end;

end.
