unit ufrmSysCities;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, SysCity.Service, SysCity, ufrmSysCity,
  SysCountry.Service, SysCountry, LocalizationManager;

type
  TfrmSysCities = class(TfrmGrid<TSysCity, TSysCityService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

function TfrmSysCities.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmSysCity.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSysCity.Create(Self, Service, TSysCity.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSysCity.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmSysCities.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id',               0, TLocalizationManager.Translate('sys_city.col_id', 'Id'));
  SetColumnProperty('city_name',      150, TLocalizationManager.Translate('sys_city.col_name', 'City Name'));
  SetColumnProperty('car_plate_code',  90, TLocalizationManager.Translate('sys_city.col_car_plate_code', 'Plate Code'));
  SetColumnProperty('country_id',       0, TLocalizationManager.Translate('sys_city.col_country_id', 'Country Id'));
  SetColumnProperty('region_id',        0, TLocalizationManager.Translate('sys_city.col_region_id', 'Region Id'));
  SetColumnProperty('country_code',    70, TLocalizationManager.Translate('sys_country.col_code', 'Country Code'));
  SetColumnProperty('country_name',   150, TLocalizationManager.Translate('sys_city.col_country', 'Country'));
  SetColumnProperty('region_name',    150, TLocalizationManager.Translate('sys_region.col_name', 'Region Name'));
end;

procedure TfrmSysCities.DefineFooterColumns;
begin
  inherited;
  AddFooterColumn('id', atCount, '#,##0');
end;

procedure TfrmSysCities.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmSysCities.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate('sys_city.title_plural', 'Cities');
end;

end.

