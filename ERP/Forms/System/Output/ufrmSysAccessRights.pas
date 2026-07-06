unit ufrmSysAccessRights;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, SysAccessRight.Service, SysAccessRight, ufrmSysAccessRight;

type
  TfrmSysAccessRights = class(TfrmGrid<TSysAccessRight, TSysAccessRightService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
  end;

implementation

{$R *.dfm}

function TfrmSysAccessRights.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmSysAccessRight.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSysAccessRight.Create(Self, Service, TSysAccessRight.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSysAccessRight.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmSysAccessRights.DefineColumnWidths;
begin
  SetColumnProperty('id',           0, 'Id');
  SetColumnProperty('username',     120, 'Username');
  SetColumnProperty('permission_name', 160, 'Permission Name');
  SetColumnProperty('is_read',       50, 'Read');
  SetColumnProperty('is_add',        50, 'Add');
  SetColumnProperty('is_update',     60, 'Update');
  SetColumnProperty('is_delete',     60, 'Delete');
  SetColumnProperty('is_special',    70, 'Special');
end;

procedure TfrmSysAccessRights.DefineFooterColumns;
begin
  // No footer columns
end;

procedure TfrmSysAccessRights.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'Access Rights';
end;

end.
