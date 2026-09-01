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
  SetColumnProperty('id', 0, TLocalizationManager.Translate(TLangKeys.TGridColumn.ColId, 'Id'));
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
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSysCountry.TitlePlural, 'Countries');
  SetColumnTitle('country_code', TLocalizationManager.Translate(TLangKeys.TSysCountry.ColCountryCode, 'Country Code'));
  SetColumnTitle('country_name', TLocalizationManager.Translate(TLangKeys.TSysCountry.ColCountryName, 'Country Name'));
  SetColumnTitle('iso_year',     TLocalizationManager.Translate(TLangKeys.TSysCountry.ColIsoYear, 'ISO Year'));
  SetColumnTitle('iso_cctld',    TLocalizationManager.Translate(TLangKeys.TSysCountry.ColIsoCctld, 'ISO CCTLD'));
  SetColumnTitle('is_eu_member', TLocalizationManager.Translate(TLangKeys.TSysCountry.ColIsEuMember, 'EU?'));
end;

end.

