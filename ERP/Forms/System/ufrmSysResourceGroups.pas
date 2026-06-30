unit ufrmSysResourceGroups;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, SysResourceGroup.Service, SysResourceGroup, ufrmSysResourceGroup;

type
  TfrmSysResourceGroups = class(TfrmGrid<TSysResourceGroup, TSysResourceGroupService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
  end;

implementation

{$R *.dfm}

function TfrmSysResourceGroups.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmSysResourceGroup.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSysResourceGroup.Create(Self, Service, TSysResourceGroup.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSysResourceGroup.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmSysResourceGroups.DefineColumnWidths;
begin
  SetColumnProperty('id',             0, 'Id');
  SetColumnProperty('group_name',   250, 'Group Name');
end;

procedure TfrmSysResourceGroups.DefineFooterColumns;
begin
  AddFooterColumn('group_name', atCount, 'Count: #,##0');
end;

procedure TfrmSysResourceGroups.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'System Resource Groups';
end;

end.

