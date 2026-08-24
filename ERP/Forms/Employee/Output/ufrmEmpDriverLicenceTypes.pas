unit ufrmEmpDriverLicenceTypes;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, EmpDriverLicenceType.Service, EmpDriverLicenceType, ufrmEmpDriverLicenceType,
  LocalizationManager;

type
  TfrmEmpDriverLicenceTypes = class(TfrmGrid<TEmpDriverLicenseType, TEmpDriverLicenceTypeService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

function TfrmEmpDriverLicenceTypes.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmEmpDriverLicenceType.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmEmpDriverLicenceType.Create(Self, Service, TEmpDriverLicenseType.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmEmpDriverLicenceType.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmEmpDriverLicenceTypes.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0, TLocalizationManager.Translate('emp_driver_license_type.col_id', 'Id'));
  SetColumnProperty('license_name', 200, TLocalizationManager.Translate('emp_driver_license_type.col_license_name', 'Ehliyet Sınıfı'));
end;

procedure TfrmEmpDriverLicenceTypes.DefineFooterColumns;
begin
  inherited;
  AddFooterColumn('id', atCount, '#,##0');
end;

procedure TfrmEmpDriverLicenceTypes.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
end;

procedure TfrmEmpDriverLicenceTypes.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate('emp_driver_license_type.title_plural', 'Sürücü Belgesi Tipleri');
end;

end.
