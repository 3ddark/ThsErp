unit ufrmEmpEmployees;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  EmpEmployee.Service, EmpEmployee, ufrmEmpEmployee;

type
  TfrmEmpEmployees = class(TfrmGrid<TEmpEmployee, TEmpEmployeeService>)
  private
    FmniDriverLicences: TMenuItem;
    FmniLanguageAbilities: TMenuItem;
    FmniAddresses: TMenuItem;
    procedure mniDriverLicencesClick(Sender: TObject);
    procedure mniLanguageAbilitiesClick(Sender: TObject);
    procedure mniAddressesClick(Sender: TObject);
    procedure GenderGetText(Sender: TField; var Text: string; DisplayText: Boolean);
    procedure MilitaryStatusGetText(Sender: TField; var Text: string; DisplayText: Boolean);
    procedure MaritalStatusGetText(Sender: TField; var Text: string; DisplayText: Boolean);
  public
    procedure PreparePopupMenu; override;
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  ufrmEmpDriverLicences, EmpDriverLicence, EmpDriverLicence.Service,          // personel ehliyetleri
  ufrmEmpLanguageAbilities, EmpLanguageAbility, EmpLanguageAbility.Service,   // personel dil bilgileri
  ufrmEmpPersonAddresses, EmpPersonAddress, EmpPersonAddress.Service,         // personel adresleri
  EmpLookup;

function TfrmEmpEmployees.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmEmpEmployee.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmEmpEmployee.Create(Self, Service, TEmpEmployee.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmEmpEmployee.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmEmpEmployees.PreparePopupMenu;
begin
  inherited;
  if IsHelper then
    Exit;

  AddPopupMenuSpliter();
  FmniDriverLicences := AddMenu(TLocalizationManager.Translate(TLangKeys.TEmpEmployee.MenuDriverLicences, 'Driver Licenses'), 'mniDriverLicences', mniDriverLicencesClick);
  FmniLanguageAbilities := AddMenu(TLocalizationManager.Translate(TLangKeys.TEmpEmployee.MenuLanguageAbilities, 'Languages'), 'mniLanguageAbilities', mniLanguageAbilitiesClick);
  FmniAddresses := AddMenu(TLocalizationManager.Translate(TLangKeys.TEmpEmployee.MenuAddresses, 'Addresses'), 'mniAddresses', mniAddressesClick);
end;

procedure TfrmEmpEmployees.mniDriverLicencesClick(Sender: TObject);
var
  LFrm: TfrmEmpDriverLicences;
begin
  if Grd.DataSource.DataSet.IsEmpty then
    Exit;

  SetSelectedItem;
  LFrm := TfrmEmpDriverLicences.Create(Self, TEmpDriverLicenceService.Create, TEmpDriverLicence.Create);
  LFrm.SetFixedEmployee(Table.Id, Table.FullName);
  LFrm.Show;
end;

procedure TfrmEmpEmployees.mniLanguageAbilitiesClick(Sender: TObject);
var
  LFrm: TfrmEmpLanguageAbilities;
begin
  if Grd.DataSource.DataSet.IsEmpty then
    Exit;

  SetSelectedItem;
  LFrm := TfrmEmpLanguageAbilities.Create(Self, TEmpLanguageAbilityService.Create, TEmpLanguageAbility.Create);
  LFrm.SetFixedEmployee(Table.Id, Table.FullName);
  LFrm.Show;
end;

procedure TfrmEmpEmployees.mniAddressesClick(Sender: TObject);
var
  LFrm: TfrmEmpPersonAddresses;
begin
  if Grd.DataSource.DataSet.IsEmpty then
    Exit;

  SetSelectedItem;
  LFrm := TfrmEmpPersonAddresses.Create(Self, TEmpPersonAddressService.Create, TEmpPersonAddress.Create);
  LFrm.SetFixedEmployee(Table.Id, Table.FullName);
  LFrm.Show;
end;

procedure TfrmEmpEmployees.GenderGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  Text := TEmpLookup.Text(elkGender, Sender.AsInteger);
end;

procedure TfrmEmpEmployees.MilitaryStatusGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  Text := TEmpLookup.Text(elkMilitaryStatus, Sender.AsInteger);
end;

procedure TfrmEmpEmployees.MaritalStatusGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  Text := TEmpLookup.Text(elkMaritalStatus, Sender.AsInteger);
end;

procedure TfrmEmpEmployees.DefineColumnWidths;
var
  LField: TField;
begin
  inherited;
  // Sayısal seçenek değerleri aktif dile göre metin olarak gösterilir
  LField := Grd.DataSource.DataSet.FindField('gender');
  if Assigned(LField) then
    LField.OnGetText := GenderGetText;
  LField := Grd.DataSource.DataSet.FindField('military_status');
  if Assigned(LField) then
    LField.OnGetText := MilitaryStatusGetText;
  LField := Grd.DataSource.DataSet.FindField('marital_status');
  if Assigned(LField) then
    LField.OnGetText := MaritalStatusGetText;

  SetColumnProperty('id', 0);
  SetColumnProperty('emp_person_type_id', 0);
  SetColumnProperty('emp_unit_id', 0);
  SetColumnProperty('emp_section_id', 0);
  SetColumnProperty('emp_task_id', 0);
  SetColumnProperty('emp_transportation_id', 0);
  SetColumnProperty('locale', 0);
end;

procedure TfrmEmpEmployees.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmEmpEmployees.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TEmpEmployee.TitlePlural, 'Employees');
  if Assigned(FmniDriverLicences) then
    FmniDriverLicences.Caption := TLocalizationManager.Translate(TLangKeys.TEmpEmployee.MenuDriverLicences, 'Driver Licenses');
  if Assigned(FmniLanguageAbilities) then
    FmniLanguageAbilities.Caption := TLocalizationManager.Translate(TLangKeys.TEmpEmployee.MenuLanguageAbilities, 'Languages');
  if Assigned(FmniAddresses) then
    FmniAddresses.Caption := TLocalizationManager.Translate(TLangKeys.TEmpEmployee.MenuAddresses, 'Addresses');
  SetColumnTitle('name', TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColName, 'First Name'));
  SetColumnTitle('surname', TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColSurname, 'Surname'));
  SetColumnTitle('full_name', TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColFullName, 'Full Name'));
  SetColumnTitle('phone1', TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColPhone1, 'Phone 1'));
  SetColumnTitle('phone2', TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColPhone2, 'Phone 2'));
  SetColumnTitle('person_type', TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColPersonType, 'Employee Type'));
  SetColumnTitle('unit_name', TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColUnitName, 'Unit'));
  SetColumnTitle('section_name', TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColSectionName, 'Section'));
  SetColumnTitle('task_name', TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColTaskName, 'Task'));
  SetColumnTitle('birth_date', TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColBirthDate, 'Birth Date'));
  SetColumnTitle('blood_type', TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColBloodType, 'Blood Type'));
  SetColumnTitle('gender', TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColGender, 'Gender'));
  SetColumnTitle('military_status', TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColMilitaryStatus, 'Military Status'));
  SetColumnTitle('marital_status', TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColMaritalStatus, 'Marital Status'));
  SetColumnTitle('child', TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColChild, 'Children'));
  SetColumnTitle('relative_name', TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColRelativeName, 'Relative Name'));
  SetColumnTitle('relative_phone', TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColRelativePhone, 'Relative Phone'));
  SetColumnTitle('shoe_size', TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColShoeSize, 'Shoe Size'));
  SetColumnTitle('clothing_size', TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColClothingSize, 'Clothing Size'));
  SetColumnTitle('notes', TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColNotes, 'Notes'));
  SetColumnTitle('transportation_name', TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColTransportation, 'Transportation'));
  SetColumnTitle('special_notes', TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColSpecialNotes, 'Special Notes'));
  SetColumnTitle('salary_amount', TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColSalaryAmount, 'Salary'));
  SetColumnTitle('bonus_count', TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColBonusCount, 'Bonus Count'));
  SetColumnTitle('bonus_amount', TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColBonusAmount, 'Bonus Amount'));
  SetColumnTitle('id_document_no', TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColIdDocumentNo, 'ID Document No'));
  SetColumnTitle('active', TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColActive, 'Active'));
end;

end.
