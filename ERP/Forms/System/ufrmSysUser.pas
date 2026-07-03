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
    lblusername: TLabel;
    edtusername: TEdit;
    lbluser_password: TLabel;
    edtuser_password: TEdit;
    lblactive: TLabel;
    chkactive: TCheckBox;
    lblmanager: TLabel;
    chkmanager: TCheckBox;
    lblsuper_user: TLabel;
    chksuper_user: TCheckBox;
    lbllp_address: TLabel;
    edtlp_address: TEdit;
    lblmac_address: TLabel;
    edtmac_address: TEdit;
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
  Table.Username := edtusername.Text;
  Table.UserPassword := edtuser_password.Text;
  Table.Active := chkactive.Checked;
  Table.Manager := chkmanager.Checked;
  Table.SuperUser := chksuper_user.Checked;
  Table.IpAddress := edtlp_address.Text;
  Table.MacAddress := edtmac_address.Text;
  inherited;
end;

procedure TfrmSysUser.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtuser_password.PasswordChar := '#';
end;

procedure TfrmSysUser.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'User';
  edtusername.SetFocus;
end;

procedure TfrmSysUser.RefreshData;
begin
  inherited;
  edtusername.Text := Table.Username;
  edtuser_password.Text := ''; // Password should not be displayed
  chkactive.Checked := Table.Active;
  chkmanager.Checked := Table.Manager;
  chksuper_user.Checked := Table.SuperUser;
  edtlp_address.Text := Table.IpAddress;
  edtmac_address.Text := Table.MacAddress;
end;

end.
