unit ufrmSysAddresses;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, SysAddress.Service, SysAddress, ufrmSysAddress, LocalizationManager;

type
  TfrmSysAddresses = class(TfrmGrid<TSysAddress, TSysAddressService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

function TfrmSysAddresses.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmSysAddress.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSysAddress.Create(Self, Service, TSysAddress.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSysAddress.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmSysAddresses.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id',           0, TLocalizationManager.Translate('sys_address.col_id', 'Id'));
  SetColumnProperty('city_id',      0, TLocalizationManager.Translate('sys_address.col_city_id', 'City ID'));
  SetColumnProperty('district',    120, TLocalizationManager.Translate('sys_address.col_district', 'District'));
  SetColumnProperty('neighborhood', 120, TLocalizationManager.Translate('sys_address.col_neighborhood', 'Neighborhood'));
  SetColumnProperty('quarter',     100, TLocalizationManager.Translate('sys_address.col_quarter', 'Quarter'));
  SetColumnProperty('road',        120, TLocalizationManager.Translate('sys_address.col_road', 'Road'));
  SetColumnProperty('street',      120, TLocalizationManager.Translate('sys_address.col_street', 'Street'));
  SetColumnProperty('zip_code',     80, TLocalizationManager.Translate('sys_address.col_zip_code', 'Zip Code'));
end;

procedure TfrmSysAddresses.DefineFooterColumns;
begin
  inherited;
  AddFooterColumn('id', atCount, '#,##0');
end;

procedure TfrmSysAddresses.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
end;

procedure TfrmSysAddresses.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate('sys_address.title_plural', 'Addresses');
end;

end.
