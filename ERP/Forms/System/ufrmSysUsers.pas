unit ufrmSysUsers;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, SysUser.Service, SysUser, ufrmSysUser;

type
  TfrmSysUsers = class(TfrmGrid<TSysUser, TSysUserService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
  end;

implementation

{$R *.dfm}

function TfrmSysUsers.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmSysUser.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSysUser.Create(Self, Service, TSysUser.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSysUser.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmSysUsers.DefineColumnWidths;
begin
  SetColumnProperty('id',           0, 'Id');
  SetColumnProperty('username',    150, 'Username');
  SetColumnProperty('person_id',   80, 'Person ID');
  SetColumnProperty('active',       60, 'Active');
  SetColumnProperty('manager',      70, 'Manager');
  SetColumnProperty('super_user',   80, 'Super User');
  SetColumnProperty('ip_address',  100, 'IP Address');
end;

procedure TfrmSysUsers.DefineFooterColumns;
begin
  // No footer columns
end;

procedure TfrmSysUsers.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'Users';
end;

end.
