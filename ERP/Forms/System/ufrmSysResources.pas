unit ufrmSysResources;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, SysResource.Service, SysResource, ufrmSysResource;

type
  TfrmSysResources = class(TfrmGrid<TSysResource, TSysResourceService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineColumnWidths; override;
    procedure DefineFooterColumns; override;
    procedure FormShow(Sender: TObject); override;
  end;

implementation

{$R *.dfm}

uses Service;

function TfrmSysResources.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmSysResource.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSysResource.Create(Self, Service, TSysResource.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSysResource.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmSysResources.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id',                   0, 'Id');
  SetColumnProperty('resource_code',      200, 'Resource Code');
  SetColumnProperty('resource_name',      200, 'Resource Name');
  SetColumnProperty('resource_group_id',    0, 'Resource Group Id');
  SetColumnProperty('group_name',         100, 'Resource Group Name');
end;

procedure TfrmSysResources.DefineFooterColumns;
begin
  inherited;
  AddFooterColumn('resource_code', atCount, '#,##0');
end;

procedure TfrmSysResources.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'System Resources';
end;

end.
