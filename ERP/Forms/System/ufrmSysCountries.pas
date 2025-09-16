unit ufrmSysCountries;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, BaseEntity, SysCountry.Service, SysCountry, ufrmSysCountry;

type
  TfrmSysCountries = class(TfrmGrid<TSysCountry, TSysCountryService>)
    procedure FormShow(Sender: TObject); override;
  published
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
  public
    procedure SetSelectedItem; override;
  end;

implementation

{$R *.dfm}

function TfrmSysCountries.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmSysCountry.Create(Application, Service, Table.CloneEntity<TSysCountry>(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSysCountry.Create(Application, Service, TSysCountry.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSysCountry.Create(Application, Service, Table.CloneEntity<TSysCountry>(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmSysCountries.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'System Countries';
end;

procedure TfrmSysCountries.SetSelectedItem;
begin
  Table.Id.ValueFirstSet(grd.DataSource.DataSet.FieldByName(Table.Id.FieldName).AsInteger);
  Table.CountryCode.ValueFirstSet(grd.DataSource.DataSet.FieldByName(Table.CountryCode.FieldName).AsString);
  Table.CountryName.ValueFirstSet(grd.DataSource.DataSet.FieldByName(Table.CountryName.FieldName).AsString);
  Table.ISOYear.ValueFirstSet(grd.DataSource.DataSet.FieldByName(Table.ISOYear.FieldName).AsInteger);
  Table.ISOCCTLD.ValueFirstSet(grd.DataSource.DataSet.FieldByName(Table.ISOCCTLD.FieldName).AsString);
  Table.IsEuMember.ValueFirstSet(grd.DataSource.DataSet.FieldByName(Table.IsEuMember.FieldName).AsBoolean);
end;

end.

