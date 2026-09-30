unit ufrmEmpPersonAddresses;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  EmpPersonAddress.Service, EmpPersonAddress, ufrmEmpPersonAddress;

type
  TfrmEmpPersonAddresses = class(TfrmGrid<TEmpPersonAddress, TEmpPersonAddressService>)
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

procedure TfrmEmpPersonAddresses.SetFixedEmployee(AEmployeeId: Int64; const AEmployeeName: string);
begin
  FFixedEmployeeId := AEmployeeId;
  FFixedEmployeeName := AEmployeeName;
  AddFixedFilter('emp_employee_id', AEmployeeId);
end;

function TfrmEmpPersonAddresses.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
var
  LNew: TEmpPersonAddress;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmEmpPersonAddress.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
  begin
    LNew := TEmpPersonAddress.Create;
    if FFixedEmployeeId > 0 then
    begin
      LNew.EmpEmployeeId := FFixedEmployeeId;
      LNew.EmployeeFullName := FFixedEmployeeName;
    end;
    Result := TfrmEmpPersonAddress.Create(Self, Service, LNew, AFormMode, Self.RefreshParentGrid);
  end
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmEmpPersonAddress.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmEmpPersonAddresses.SetSelectedItem;

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
  Table.AddressText := FieldText('address_text');
end;

procedure TfrmEmpPersonAddresses.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('emp_employee_id', 0);
  SetColumnProperty('sys_address_id', 0);
end;

procedure TfrmEmpPersonAddresses.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmEmpPersonAddresses.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TEmpPersonAddress.TitlePlural, 'Employee Addresses');
  if FFixedEmployeeName <> '' then
    Self.Caption := Self.Caption + ' - ' + FFixedEmployeeName;
  SetColumnTitle('full_name', TLocalizationManager.Translate(TLangKeys.TEmpPersonAddress.ColEmployee, 'Employee'));
  SetColumnTitle('address_text', TLocalizationManager.Translate(TLangKeys.TEmpPersonAddress.ColAddress, 'Address'));
  SetColumnTitle('address_type', TLocalizationManager.Translate(TLangKeys.TEmpPersonAddress.ColAddressType, 'Address Type'));
  SetColumnTitle('is_primary', TLocalizationManager.Translate(TLangKeys.TEmpPersonAddress.ColIsPrimary, 'Primary'));
  SetColumnTitle('valid_from', TLocalizationManager.Translate(TLangKeys.TEmpPersonAddress.ColValidFrom, 'Valid From'));
  SetColumnTitle('valid_to', TLocalizationManager.Translate(TLangKeys.TEmpPersonAddress.ColValidTo, 'Valid To'));
end;

end.
