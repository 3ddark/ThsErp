unit ufrmSysCountries;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, ufrmSysCountry,
  SysCountry.Service, SysCountry;


type
  TfrmSysCountries = class(TfrmGrid<TSysCountry, TSysCountryService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
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
  SetColumnProperty('id',               0, 'Id');
  SetColumnProperty('country_code',    70, 'Country Code');
  SetColumnProperty('country_name',   100, 'Country Name');
  SetColumnProperty('iso_year',        40, 'ISO Year');
  SetColumnProperty('iso_cctld',       70, 'ISO CCTLD');
  SetColumnProperty('is_eu_member',    60, 'EU?');
end;

procedure TfrmSysCountries.DefineFooterColumns;
begin
  AddFooterColumn('id', atCount, '#,##0');
end;

procedure TfrmSysCountries.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'System Countries';
end;

end.

