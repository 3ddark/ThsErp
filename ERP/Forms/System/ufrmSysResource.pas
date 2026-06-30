unit ufrmSysResource;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.Samples.Spin,
  ufrmInputSimpleDB, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  SysResource.Service, SysResource,
  SysResourceGroup.Service, SysResourceGroup, ufrmSysResourceGroups;

type
  TfrmSysResource = class(TfrmInputSimpleDB<TSysResource, TSysResourceService>)
    pnlContent: TPanel;
    edtresource_group_id: TEdit;
    edtresource_name: TEdit;
    edtresource_code: TEdit;
    lblresource_group_id: TLabel;
    lblresource_name: TLabel;
    lblresource_code: TLabel;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure HelperProcess(Sender: TObject);
    procedure InitializeInputCase; override;
    procedure RefreshData; override;
  end;

implementation

{$R *.dfm}

procedure TfrmSysResource.BtnAcceptClick(Sender: TObject);
begin
  Table.ResourceCode := edtresource_code.Text;
  Table.ResourceName := edtresource_name.Text;
  Table.ResourceGroup.GroupName := edtresource_group_id.Text;
  inherited;
end;

procedure TfrmSysResource.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtresource_group_id.OnHelperProcess := HelperProcess;
end;

procedure TfrmSysResource.FormShow(Sender: TObject);
begin
  inherited;

  Self.Caption := 'System Resource';

  edtresource_code.SetFocus;
end;

procedure TfrmSysResource.HelperProcess(Sender: TObject);
var
  LFrm: TfrmSysResourceGroups;
begin
  if Sender is TEdit then
  begin
    if (Sender as TEdit).Name = edtresource_group_id.Name then
    begin
      LFrm := TfrmSysResourceGroups.Create((Sender as TEdit), TSysResourceGroupService.Create, TSysResourceGroup.Create);
      try
        LFrm.IsHelper := True;
        LFrm.ShowModal;
        if LFrm.DataAktar then
        begin
          if LFrm.CleanAndClose then
          begin
            Table.ResourceGroupId := 0;
            (Sender as TEdit).Clear;
          end
          else
          begin
            Table.ResourceGroupId := LFrm.Table.Id;
            (Sender as TEdit).Text := LFrm.Table.GroupName;
          end;
        end;
      finally
        LFrm.Free;
      end;
    end;
  end;
end;

procedure TfrmSysResource.InitializeInputCase;
begin
  inherited;
  edtresource_code.thsInputDataType := itString;
  edtresource_name.thsInputDataType := itString;
  edtresource_group_id.thsInputDataType := itInteger;
end;

procedure TfrmSysResource.RefreshData;
begin
  inherited;
  edtresource_code.Text := Table.ResourceCode;
  edtresource_name.Text := Table.ResourceName;
  edtresource_group_id.Text := Table.ResourceGroup.GroupName;
end;

end.
