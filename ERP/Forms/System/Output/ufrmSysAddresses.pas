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
  SetColumnProperty('id',           0, 'Id');
  SetColumnProperty('sys_city_id',  0, 'City ID');
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
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSysAddress.TitlePlural, 'Addresses');
  SetColumnTitle('district',     TLocalizationManager.Translate(TLangKeys.TSysAddress.ColDistrict, 'District'));
  SetColumnTitle('neighborhood', TLocalizationManager.Translate(TLangKeys.TSysAddress.ColNeighborhood, 'Neighborhood'));
  SetColumnTitle('quarter',      TLocalizationManager.Translate(TLangKeys.TSysAddress.ColQuarter, 'Quarter'));
  SetColumnTitle('road',         TLocalizationManager.Translate(TLangKeys.TSysAddress.ColRoad, 'Road'));
  SetColumnTitle('street',       TLocalizationManager.Translate(TLangKeys.TSysAddress.ColStreet, 'Street'));
  SetColumnTitle('building_name',TLocalizationManager.Translate(TLangKeys.TSysAddress.ColBuildingName, 'Building Name'));
  SetColumnTitle('door_number',  TLocalizationManager.Translate(TLangKeys.TSysAddress.ColDoorNumber, 'Door Number'));
  SetColumnTitle('zip_code',     TLocalizationManager.Translate(TLangKeys.TSysAddress.ColZipCode, 'Zip Code'));
  SetColumnTitle('web',          TLocalizationManager.Translate(TLangKeys.TSysAddress.ColWeb, 'Web'));
  SetColumnTitle('email',        TLocalizationManager.Translate(TLangKeys.TSysAddress.ColEmail, 'e-Mail'));
end;

end.
