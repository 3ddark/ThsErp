unit ufrmSysCountries;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, SysCountry.Service, SysCountry, ufrmSysCountry;

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
  SetColumnProperty('id',             0, 'Id');
  SetColumnProperty('country_code',  80, 'Ülke Kodu');
  SetColumnProperty('country_name', 220, 'Ülke Adı');
  SetColumnProperty('iso_year',      70, 'ISO Yıl');
  SetColumnProperty('iso_cctld',     90, 'ISO CCTLD');
  SetColumnProperty('is_eu_member', 100, 'EU Üyesi');
end;

procedure TfrmSysCountries.DefineFooterColumns;
begin
  AddFooterColumn('iso_year', atAverage, 'Ort: #,##0.00');
end;

procedure TfrmSysCountries.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'Sistem Ülkeler';
end;

end.

