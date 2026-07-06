unit ufrmSysPermission;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Samples.Spin, Vcl.ComCtrls, ufrmInputSimpleDB, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  SysPermission.Service, SysPermission, SysPermissionGroup, SysPermissionGroup.Service;

type
  TfrmSysPermission = class(TfrmInputSimpleDB<TSysPermission, TSysPermissionService>)
    pnlContent: TPanel;
    lblCode: TLabel;
    edtCode: TEdit;
    lblName: TLabel;
    edtName: TEdit;
    lblGroupId: TLabel;
    edtGroupId: TEdit;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure HelperProcess(Sender: TObject);
    procedure RefreshData; override;
  end;

implementation

{$R *.dfm}

uses
  ufrmSysPermissionGroups; // TfrmSysPermissionGroups helper output form (permission group selection)

procedure TfrmSysPermission.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmGroup: TfrmSysPermissionGroups;
begin
  if Sender is TEdit then
  begin
    LEdit := (Sender as TEdit);
    if LEdit.Name = edtGroupId.Name then
    begin
      LFrmGroup := TfrmSysPermissionGroups.Create(LEdit, TSysPermissionGroupService.Create, TSysPermissionGroup.Create);
      try
        LFrmGroup.IsHelper := True;
        LFrmGroup.ShowModal;
        if LFrmGroup.DataTransfer then
          if LFrmGroup.CleanAndClose then
          begin
            Table.GroupId := 0;
            LEdit.Clear;
          end
          else
          begin
            Table.GroupId := LFrmGroup.Table.Id;
            LEdit.Text := LFrmGroup.Table.Name;
          end;
      finally
        LFrmGroup.Free;
      end;
    end;
  end;
end;

procedure TfrmSysPermission.BtnAcceptClick(Sender: TObject);
begin
  Table.Code := StrToIntDef(edtCode.Text, 0);
  Table.Name := edtName.Text;
  inherited;
end;

procedure TfrmSysPermission.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtGroupId.OnHelperProcess := HelperProcess;
end;

procedure TfrmSysPermission.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'Permission';
  edtCode.SetFocus;
end;

procedure TfrmSysPermission.RefreshData;
begin
  inherited;
  edtCode.Text := IntToStr(Table.Code);
  edtName.Text := Table.Name;
  edtGroupId.Text := Table.PermissionGroup.Name;
end;

end.
