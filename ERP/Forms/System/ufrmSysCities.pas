unit ufrmSysCities;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, BaseEntity, SysCity.Service, SysCity, ufrmSysCity;

type
  TfrmSysCities = class(TfrmGrid<TSysCity, TSysCityService>)
    procedure FormShow(Sender: TObject); override;
  published
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
  public
    procedure SetSelectedItem; override;
  end;

implementation

{$R *.dfm}

function TfrmSysCities.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmSysCity.Create(Application, Service, Table.CloneEntity<TSysCity>(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSysCity.Create(Application, Service, TSysCity.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSysCity.Create(Application, Service, Table.CloneEntity<TSysCity>(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmSysCities.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'System Cities';
end;

procedure TfrmSysCities.SetSelectedItem;
begin
  Table.Id.ValueFirstSet(grd.DataSource.DataSet.FieldByName(Table.Id.FieldName).AsInteger);
  Table.CityName.ValueFirstSet(grd.DataSource.DataSet.FieldByName(Table.CityName.FieldName).AsString);
  Table.CarPlateCode.ValueFirstSet(grd.DataSource.DataSet.FieldByName(Table.CarPlateCode.FieldName).AsString);
  Table.CountryId.ValueFirstSet(grd.DataSource.DataSet.FieldByName(Table.CountryId.FieldName).AsString);
  Table.RegionId.ValueFirstSet(grd.DataSource.DataSet.FieldByName(Table.RegionId.FieldName).AsString);
end;

end.

