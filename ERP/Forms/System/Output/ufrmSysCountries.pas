unit ufrmSysCountries;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, ufrmSysCountry,
  SysCountry.Service, SysCountry, LocalizationManager;


type
  TfrmSysCountries = class(TfrmGrid<TSysCountry, TSysCountryService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

function TfrmSysCountries.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmSysCountry.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSysCountry.Create(Self, Service, TSysCountry.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSysCountry.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmSysCountries.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id',               0, TLocalizationManager.Translate('sys_country.col_id', 'Id'));
  SetColumnProperty('country_code',    70, TLocalizationManager.Translate('sys_country.col_code', 'Country Code'));
  SetColumnProperty('country_name',   150, TLocalizationManager.Translate('sys_country.col_name', 'Country Name'));
  SetColumnProperty('iso_year',        60, TLocalizationManager.Translate('sys_country.col_iso_year', 'ISO Year'));
  SetColumnProperty('iso_cctld',       70, TLocalizationManager.Translate('sys_country.col_iso_cctld', 'ISO CCTLD'));
  SetColumnProperty('is_eu_member',    60, TLocalizationManager.Translate('sys_country.col_is_eu_member', 'EU?'));
end;

procedure TfrmSysCountries.DefineFooterColumns;
begin
  inherited;
  AddFooterColumn('id', atCount, '#,##0');
end;

procedure TfrmSysCountries.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmSysCountries.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate('sys_country.title_plural', 'Countries');
end;

end.

