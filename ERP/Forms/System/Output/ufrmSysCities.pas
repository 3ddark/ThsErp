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
  SetColumnProperty('id',               0, TLocalizationManager.Translate(TLangKeys.TGridColumn.ColId, 'Id'));
  SetColumnProperty('city_name',      150, TLocalizationManager.Translate(TLangKeys.TSysCity.ColCityName, 'City Name'));
  SetColumnProperty('plate_code',      90, TLocalizationManager.Translate(TLangKeys.TSysCity.ColPlateCode, 'Car Plate Code'));
  SetColumnProperty('country_id',       0, TLocalizationManager.Translate(TLangKeys.TSysCity.ColCountryId, 'Country Id'));
  SetColumnProperty('region_id',        0, TLocalizationManager.Translate(TLangKeys.TSysCity.ColRegionId, 'Region Id'));
  SetColumnProperty('country_code',    70, TLocalizationManager.Translate(TLangKeys.TSysCountry.ColCode, 'Country Code'));
  SetColumnProperty('country_name',   150, TLocalizationManager.Translate(TLangKeys.TSysCountry.ColCountry, 'Country Name'));
  SetColumnProperty('region_name',    150, TLocalizationManager.Translate(TLangKeys.TSysRegion.ColName, 'Region Name'));
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
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSysCity.TitlePlural, 'Cities');
end;

end.

