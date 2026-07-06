unit ufrmSysPermissions;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, SysPermission.Service, SysPermission, ufrmSysPermission;

type
  TfrmSysPermissions = class(TfrmGrid<TSysPermission, TSysPermissionService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
  end;

implementation

{$R *.dfm}

function TfrmSysPermissions.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmSysPermission.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSysPermission.Create(Self, Service, TSysPermission.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSysPermission.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmSysPermissions.DefineColumnWidths;
begin
  SetColumnProperty('id',           0, 'Id');
  SetColumnProperty('permission_code', 120, 'Permission Code');
  SetColumnProperty('permission_name', 300, 'Permission Name');
  SetColumnProperty('permission_group_id', 120, 'Group ID');
end;

procedure TfrmSysPermissions.DefineFooterColumns;
begin
  // No footer columns
end;

procedure TfrmSysPermissions.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'Permissions';
end;

end.
