unit ufrmSysResourceGroup;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.Samples.Spin, Vcl.StdCtrls, Vcl.ComCtrls,
  ufrmInputSimpleDB, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  SysResourceGroup.Service, SysResourceGroup;

type
  TfrmSysResourceGroup = class(TfrmInputSimpleDB<TSysResourceGroup, TSysResourceGroupService>)
    pnlContent: TPanel;
    lblgroup_name: TLabel;
    edtgroup_name: TEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure RefreshData; override;
  end;

implementation

{$R *.dfm}

procedure TfrmSysResourceGroup.BtnAcceptClick(Sender: TObject);
begin
  Table.GroupName := edtgroup_name.Text;
  inherited;
end;

procedure TfrmSysResourceGroup.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
end;

procedure TfrmSysResourceGroup.FormShow(Sender: TObject);
begin
  inherited;

  Self.Caption := 'System Resource Group';

  edtgroup_name.SetFocus;
end;

procedure TfrmSysResourceGroup.RefreshData;
begin
  inherited;
  edtgroup_name.Text := Table.GroupName;
end;

end.
