unit ufrmSysPermission;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Samples.Spin, Vcl.ComCtrls, ufrmInputSimpleDB, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  SysPermission.Service, SysPermission;

type
  TfrmSysPermission = class(TfrmInputSimpleDB<TSysPermission, TSysPermissionService>)
    pnlContent: TPanel;
    lblpermission_code: TLabel;
    edtpermission_code: TEdit;
    lblpermission_name: TLabel;
    edtpermission_name: TEdit;
    lblpermission_group_id: TLabel;
    edtpermission_group_id: TEdit;
    btnpermission_group_sec: TButton;
  private
    FPermissionGroupId: Int64;
    procedure btnpermission_group_secClick(Sender: TObject);
  published
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure RefreshData; override;
  end;

implementation

{$R *.dfm}

procedure TfrmSysPermission.BtnAcceptClick(Sender: TObject);
begin
  Table.PermissionCode := StrToIntDef(edtpermission_code.Text, 0);
  Table.PermissionName := edtpermission_name.Text;
  Table.PermissionGroupId := FPermissionGroupId;
  inherited;
end;

procedure TfrmSysPermission.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  btnpermission_group_sec.OnClick := btnpermission_group_secClick;
end;

procedure TfrmSysPermission.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'Permission';
  edtpermission_code.SetFocus;
end;

procedure TfrmSysPermission.btnpermission_group_secClick(Sender: TObject);
var
  LId: Int64;
  LName: string;
begin
  // TODO: Show permission group selection helper form (ufrmSysPermissionGroups)
  LId := 0;
  LName := '';
  if LId > 0 then
  begin
    FPermissionGroupId := LId;
    edtpermission_group_id.Text := LName;
  end;
end;

procedure TfrmSysPermission.RefreshData;
begin
  inherited;
  edtpermission_code.Text := IntToStr(Table.PermissionCode);
  edtpermission_name.Text := Table.PermissionName;
  edtpermission_group_id.Text := Table.PermissionGroupId.ToString;
  FPermissionGroupId := Table.PermissionGroupId;
end;

end.
