unit ufrmSysPermissionGroup;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls,
  ufrmInputSimpleDB, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo,
  SysPermissionGroup.Service, SysPermissionGroup;

type
  TfrmSysPermissionGroup = class(TfrmInputSimpleDB<TSysPermissionGroup, TSysPermissionGroupService>)
    pnlContent: TPanel;
    lblgroup_name: TLabel;
    edtgroup_name: TEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure InitializeInputCase; override;
    procedure RefreshData; override;
  end;

implementation

{$R *.dfm}

procedure TfrmSysPermissionGroup.BtnAcceptClick(Sender: TObject);
begin
  Table.GroupName := edtgroup_name.Text;
  inherited;
end;

procedure TfrmSysPermissionGroup.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
end;

procedure TfrmSysPermissionGroup.FormShow(Sender: TObject);
begin
  inherited;

  Self.Caption := 'Permission Group';

  edtgroup_name.SetFocus;
end;

procedure TfrmSysPermissionGroup.InitializeInputCase;
begin
  inherited;
  edtgroup_name.thsInputDataType := itString;
  edtgroup_name.MaxLength := 64;
end;

procedure TfrmSysPermissionGroup.RefreshData;
begin
  inherited;
  edtgroup_name.Text := Table.GroupName;
end;

end.
