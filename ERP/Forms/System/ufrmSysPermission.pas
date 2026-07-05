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
    lblPermissionCode: TLabel;
    edtPermissionCode: TEdit;
    lblPermissionName: TLabel;
    edtPermissionName: TEdit;
    lblPermissionGroupId: TLabel;
    edtPermissionGroupId: TEdit;
    btnPermissionGroupSelect: TButton;
  private
    FPermissionGroupId: Int64;
    procedure btnPermissionGroupSelectClick(Sender: TObject);
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
  Table.PermissionCode := StrToIntDef(edtPermissionCode.Text, 0);
  Table.PermissionName := edtPermissionName.Text;
  Table.PermissionGroupId := FPermissionGroupId;
  inherited;
end;

procedure TfrmSysPermission.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  btnPermissionGroupSelect.OnClick := btnPermissionGroupSelectClick;
end;

procedure TfrmSysPermission.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'Permission';
  edtPermissionCode.SetFocus;
end;

procedure TfrmSysPermission.btnPermissionGroupSelectClick(Sender: TObject);
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
    edtPermissionGroupId.Text := LName;
  end;
end;

procedure TfrmSysPermission.RefreshData;
begin
  inherited;
  edtPermissionCode.Text := IntToStr(Table.PermissionCode);
  edtPermissionName.Text := Table.PermissionName;
  edtPermissionGroupId.Text := Table.PermissionGroupId.ToString;
  FPermissionGroupId := Table.PermissionGroupId;
end;

end.
