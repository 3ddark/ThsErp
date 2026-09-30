unit ufrmEmpDriverLicences;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  EmpDriverLicence.Service, EmpDriverLicence, ufrmEmpDriverLicence;

type
  TfrmEmpDriverLicences = class(TfrmGrid<TEmpDriverLicence, TEmpDriverLicenceService>)
  private
    FFixedEmployeeId: Int64;
    FFixedEmployeeName: string;
  public
    procedure SetFixedEmployee(AEmployeeId: Int64; const AEmployeeName: string);

    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure SetSelectedItem; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

procedure TfrmEmpDriverLicences.SetFixedEmployee(AEmployeeId: Int64; const AEmployeeName: string);
begin
  FFixedEmployeeId := AEmployeeId;
  FFixedEmployeeName := AEmployeeName;
  AddFixedFilter('emp_employee_id', AEmployeeId);
end;

function TfrmEmpDriverLicences.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
var
  LNew: TEmpDriverLicence;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmEmpDriverLicence.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
  begin
    LNew := TEmpDriverLicence.Create;
    if FFixedEmployeeId > 0 then
    begin
      LNew.EmpEmployeeId := FFixedEmployeeId;
      LNew.EmployeeFullName := FFixedEmployeeName;
    end;
    Result := TfrmEmpDriverLicence.Create(Self, Service, LNew, AFormMode, Self.RefreshParentGrid);
  end
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmEmpDriverLicence.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmEmpDriverLicences.SetSelectedItem;

  function FieldText(const AFieldName: string): string;
  var
    LField: TField;
  begin
    LField := Grd.DataSource.DataSet.FindField(AFieldName);
    if Assigned(LField) then
      Result := LField.AsString
    else
      Result := '';
  end;

begin
  inherited;
  Table.EmployeeFullName := FieldText('full_name');
  Table.LicenseName := FieldText('license_name');
end;

procedure TfrmEmpDriverLicences.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('emp_employee_id', 0);
  SetColumnProperty('emp_driver_license_type_id', 0);
end;

procedure TfrmEmpDriverLicences.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmEmpDriverLicences.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TEmpDriverAbility.TitlePlural, 'Employee Driver Licenses');
  if FFixedEmployeeName <> '' then
    Self.Caption := Self.Caption + ' - ' + FFixedEmployeeName;
  SetColumnTitle('full_name', TLocalizationManager.Translate(TLangKeys.TEmpDriverAbility.ColEmployee, 'Employee'));
  SetColumnTitle('license_name', TLocalizationManager.Translate(TLangKeys.TEmpDriverAbility.ColLicenseName, 'License Class'));
end;

end.
