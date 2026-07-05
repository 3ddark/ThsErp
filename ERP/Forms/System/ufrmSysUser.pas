unit ufrmSysUser;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Samples.Spin, Vcl.ComCtrls, ufrmInputSimpleDB, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  SysUser.Service, SysUser;

type
  TfrmSysUser = class(TfrmInputSimpleDB<TSysUser, TSysUserService>)
    pnlContent: TPanel;
    lblUsername: TLabel;
    edtUsername: TEdit;
    lblUserPassword: TLabel;
    edtUserPassword: TEdit;
    lblActive: TLabel;
    chkActive: TCheckBox;
    lblManager: TLabel;
    chkManager: TCheckBox;
    lblSuperUser: TLabel;
    chkSuperUser: TCheckBox;
    lblIpAddress: TLabel;
    edtIpAddress: TEdit;
    lblMacAddress: TLabel;
    edtMacAddress: TEdit;
  published
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure RefreshData; override;
  end;

implementation

{$R *.dfm}

procedure TfrmSysUser.BtnAcceptClick(Sender: TObject);
begin
  Table.Username := edtUsername.Text;
  Table.UserPassword := edtUserPassword.Text;
  Table.Active := chkActive.Checked;
  Table.Manager := chkManager.Checked;
  Table.SuperUser := chkSuperUser.Checked;
  Table.IpAddress := edtIpAddress.Text;
  Table.MacAddress := edtMacAddress.Text;
  inherited;
end;

procedure TfrmSysUser.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtUserPassword.PasswordChar := '#';
end;

procedure TfrmSysUser.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'User';
  edtUsername.SetFocus;
end;

procedure TfrmSysUser.RefreshData;
begin
  inherited;
  edtUsername.Text := Table.Username;
  edtUserPassword.Text := ''; // Password should not be displayed
  chkActive.Checked := Table.Active;
  chkManager.Checked := Table.Manager;
  chkSuperUser.Checked := Table.SuperUser;
  edtIpAddress.Text := Table.IpAddress;
  edtMacAddress.Text := Table.MacAddress;
end;

end.
