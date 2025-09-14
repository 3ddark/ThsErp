unit ufrmSysRegions;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, BaseEntity, SysRegion.Service, SysRegion, ufrmSysRegion;

type
  TfrmSysRegions = class(TfrmGrid<TSysRegion, TSysRegionService>)
    procedure FormShow(Sender: TObject); override;
  published
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
  public
    procedure SetSelectedItem; override;
  end;

implementation

{$R *.dfm}

function TfrmSysRegions.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmSysRegion.Create(Application, Service, Table.CloneEntity<TSysRegion>(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSysRegion.Create(Application, Service, TSysRegion.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSysRegion.Create(Application, Service, Table.CloneEntity<TSysRegion>(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmSysRegions.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'System Regions';
end;

procedure TfrmSysRegions.SetSelectedItem;
begin
  Table.Id.ValueFirstSet(grd.DataSource.DataSet.FieldByName(Table.Id.FieldName).AsInteger);
  Table.RegionName.ValueFirstSet(grd.DataSource.DataSet.FieldByName(Table.RegionName.FieldName).AsString);
end;

end.

