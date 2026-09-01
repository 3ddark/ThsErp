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
  SetColumnProperty('id',         0, TLocalizationManager.Translate(TLangKeys.TGridColumn.ColId, 'Id'));
  SetColumnProperty('country_id', 0, TLocalizationManager.Translate(TLangKeys.TSysCity.ColCountryId, 'Country Id'));
  SetColumnProperty('region_id',  0, TLocalizationManager.Translate(TLangKeys.TSysCity.ColRegionId, 'Region Id'));
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
  SetColumnTitle('id',           TLocalizationManager.Translate(TLangKeys.TGridColumn.ColId, 'Id'));
  SetColumnTitle('country_id',   TLocalizationManager.Translate(TLangKeys.TSysCity.ColCountryId, 'Country Id'));
  SetColumnTitle('region_id',    TLocalizationManager.Translate(TLangKeys.TSysCity.ColRegionId, 'Region Id'));
  SetColumnTitle('city_name',    TLocalizationManager.Translate(TLangKeys.TSysCity.ColCityName, 'City Name'));
  SetColumnTitle('plate_code',   TLocalizationManager.Translate(TLangKeys.TSysCity.ColPlateCode, 'Car Plate Code'));
  SetColumnTitle('country_code', TLocalizationManager.Translate(TLangKeys.TSysCountry.ColCountryCode, 'Country Code'));
  SetColumnTitle('country_name', TLocalizationManager.Translate(TLangKeys.TSysCountry.ColCountryName, 'Country Name'));
  SetColumnTitle('region_name',  TLocalizationManager.Translate(TLangKeys.TSysRegion.ColRegionName, 'Region Name'));
end;

end.

