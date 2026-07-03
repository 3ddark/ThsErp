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
    lbluser_id: TLabel;
    edtuser_id: TEdit;
    btnuser_sec: TButton;
    lblpermission_id: TLabel;
    edtpermission_id: TEdit;
    btnpermission_sec: TButton;
    chkis_read: TCheckBox;
    chkis_add: TCheckBox;
    chkis_update: TCheckBox;
    chkis_delete: TCheckBox;
    chkis_special: TCheckBox;
  private
    FUserId: Int64;
    FPermissionId: Int64;
    procedure btnuser_secClick(Sender: TObject);
    procedure btnpermission_secClick(Sender: TObject);
  published
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure RefreshData; override;
  end;

implementation

{$R *.dfm}

procedure TfrmSysAccessRight.BtnAcceptClick(Sender: TObject);
begin
  Table.UserId := FUserId;
  Table.PermissionId := FPermissionId;
  Table.IsRead := chkis_read.Checked;
  Table.IsAdd := chkis_add.Checked;
  Table.IsUpdate := chkis_update.Checked;
  Table.IsDelete := chkis_delete.Checked;
  Table.IsSpecial := chkis_special.Checked;
  inherited;
end;

procedure TfrmSysAccessRight.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  btnuser_sec.OnClick := btnuser_secClick;
  btnpermission_sec.OnClick := btnpermission_secClick;
end;

procedure TfrmSysAccessRight.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'Access Right';
  edtuser_id.SetFocus;
end;

procedure TfrmSysAccessRight.btnuser_secClick(Sender: TObject);
var
  LId: Int64;
  LName: string;
begin
  // TODO: Show user selection helper form (ufrmSysUsers)
  LId := 0;
  LName := '';
  if LId > 0 then
  begin
    FUserId := LId;
    edtuser_id.Text := LName;
  end;
end;

procedure TfrmSysAccessRight.btnpermission_secClick(Sender: TObject);
var
  LId: Int64;
  LName: string;
begin
  // TODO: Show permission selection helper form (ufrmSysPermissions)
  LId := 0;
  LName := '';
  if LId > 0 then
  begin
    FPermissionId := LId;
    edtpermission_id.Text := LName;
  end;
end;

procedure TfrmSysAccessRight.RefreshData;
begin
  inherited;
  edtuser_id.Text := Table.UserId.ToString;
  edtpermission_id.Text := Table.PermissionId.ToString;
  FUserId := Table.UserId;
  FPermissionId := Table.PermissionId;
  chkis_read.Checked := Table.IsRead;
  chkis_add.Checked := Table.IsAdd;
  chkis_update.Checked := Table.IsUpdate;
  chkis_delete.Checked := Table.IsDelete;
  chkis_special.Checked := Table.IsSpecial;
end;

end.
