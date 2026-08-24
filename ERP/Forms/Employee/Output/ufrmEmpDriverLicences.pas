unit ufrmEmpDriverLicences;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, EmpDriverLicence.Service, EmpDriverLicence, ufrmEmpDriverLicence,
  LocalizationManager;

type
  TfrmEmpDriverLicences = class(TfrmGrid<TEmpDriverLicence, TEmpDriverLicenceService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

function TfrmEmpDriverLicences.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmEmpDriverLicence.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmEmpDriverLicence.Create(Self, Service, TEmpDriverLicence.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmEmpDriverLicence.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmEmpDriverLicences.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0, TLocalizationManager.Translate('emp_driver_ability.col_id', 'Id'));
  SetColumnProperty('person_id', 0, TLocalizationManager.Translate('emp_driver_ability.col_person_id', 'Personel Id'));
  SetColumnProperty('driver_license_id', 0, TLocalizationManager.Translate('emp_driver_ability.col_license_id', 'Ehliyet Id'));
end;

procedure TfrmEmpDriverLicences.DefineFooterColumns;
begin
  inherited;
  AddFooterColumn('id', atCount, '#,##0');
end;

procedure TfrmEmpDriverLicences.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
end;

procedure TfrmEmpDriverLicences.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate('emp_driver_ability.title_plural', 'Personel Sürücü Belgeleri');
end;

end.
