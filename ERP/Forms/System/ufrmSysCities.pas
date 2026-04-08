unit ufrmSysCities;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, SysCity.Service, SysCity, ufrmSysCity,
  SysCountry.Service, SysCountry;

type
  TfrmSysCities = class(TfrmGrid<TSysCity, TSysCityService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
  end;

implementation

{$R *.dfm}

function TfrmSysCities.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmSysCity.Create(Application, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSysCity.Create(Application, Service, TSysCity.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSysCity.Create(Application, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmSysCities.DefineColumnWidths;
begin
  SetColumnProperty('id',               0, 'Id');
  SetColumnProperty('city_name',      100, 'Şehir Adı');
  SetColumnProperty('car_plate_code',  90, 'Plaka Kodu');
  SetColumnProperty('country_id',       0, 'Country Id');
  SetColumnProperty('region_id',        0, 'Region Id');
end;

procedure TfrmSysCities.DefineFooterColumns;
begin
  AddFooterColumn('id', atCount, '#,##0 " Şehir"');
end;

procedure TfrmSysCities.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'Sistem Şehirler';
end;

end.

