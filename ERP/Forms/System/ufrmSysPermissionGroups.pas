unit ufrmSysPermissionGroups;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, SysPermissionGroup.Service, SysPermissionGroup, ufrmSysPermissionGroup;

type
  TfrmSysPermissionGroups = class(TfrmGrid<TSysPermissionGroup, TSysPermissionGroupService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure FormShow(Sender: TObject); override;
  end;

implementation

{$R *.dfm}

function TfrmSysPermissionGroups.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmSysPermissionGroup.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSysPermissionGroup.Create(Self, Service, TSysPermissionGroup.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSysPermissionGroup.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmSysPermissionGroups.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id',            0, 'Id');
  SetColumnProperty('group_name',  250, 'Group Name');
end;

procedure TfrmSysPermissionGroups.DefineFooterColumns;
begin
  inherited;
  AddFooterColumn('id', atCount, '#,##0');
end;

procedure TfrmSysPermissionGroups.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'Permission Groups';
end;

end.
