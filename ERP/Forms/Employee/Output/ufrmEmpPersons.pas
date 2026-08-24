unit ufrmEmpPersons;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, EmpPerson.Service, EmpPerson, ufrmEmpPerson,
  LocalizationManager;

type
  TfrmEmpPersons = class(TfrmGrid<TEmpPerson, TEmpPersonService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

function TfrmEmpPersons.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmEmpPerson.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmEmpPerson.Create(Self, Service, TEmpPerson.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmEmpPerson.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmEmpPersons.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0, TLocalizationManager.Translate('emp_person.col_id', 'Id'));
  SetColumnProperty('name', 120, TLocalizationManager.Translate('emp_person.col_name', 'Adı'));
  SetColumnProperty('surname', 120, TLocalizationManager.Translate('emp_person.col_surname', 'Soyadı'));
  SetColumnProperty('full_name', 160, TLocalizationManager.Translate('emp_person.col_full_name', 'Adı Soyadı'));
  SetColumnProperty('phone1', 100, TLocalizationManager.Translate('emp_person.col_phone1', 'Telefon 1'));
  SetColumnProperty('phone2', 100, TLocalizationManager.Translate('emp_person.col_phone2', 'Telefon 2'));
  SetColumnProperty('person_type_id', 0, TLocalizationManager.Translate('emp_person.col_person_type_id', 'Personel Tipi Id'));
  SetColumnProperty('unit_id', 0, TLocalizationManager.Translate('emp_person.col_unit_id', 'Birim Id'));
  SetColumnProperty('task_id', 0, TLocalizationManager.Translate('emp_person.col_task_id', 'Görev Id'));
  SetColumnProperty('birth_date', 90, TLocalizationManager.Translate('emp_person.col_birth', 'Doğum Tarihi'));
  SetColumnProperty('blood_type', 70, TLocalizationManager.Translate('emp_person.col_blood', 'Kan Grubu'));
  SetColumnProperty('gender', 60, TLocalizationManager.Translate('emp_person.col_gender', 'Cinsiyet'));
  SetColumnProperty('military_status', 80, TLocalizationManager.Translate('emp_person.col_military_status', 'Askerlik'));
  SetColumnProperty('marital_status', 80, TLocalizationManager.Translate('emp_person.col_marital_status', 'Medeni Durum'));
  SetColumnProperty('child', 60, TLocalizationManager.Translate('emp_person.col_child', 'Çocuk'));
  SetColumnProperty('relative_name', 120, TLocalizationManager.Translate('emp_person.col_relative_name', 'Yakın Adı'));
  SetColumnProperty('relative_phone', 100, TLocalizationManager.Translate('emp_person.col_relative_phone', 'Yakın Tel'));
  SetColumnProperty('shoe_size', 60, TLocalizationManager.Translate('emp_person.col_shoe', 'Ayakkabı'));
  SetColumnProperty('clothing_size', 60, TLocalizationManager.Translate('emp_person.col_dress', 'Beden'));
  SetColumnProperty('notes', 150, TLocalizationManager.Translate('emp_person.col_notes', 'Notlar'));
  SetColumnProperty('active', 60, TLocalizationManager.Translate('emp_person.col_active', 'Aktif'));
end;

procedure TfrmEmpPersons.DefineFooterColumns;
begin
  inherited;
  AddFooterColumn('id', atCount, '#,##0');
end;

procedure TfrmEmpPersons.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
end;

procedure TfrmEmpPersons.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate('emp_person.title_plural', 'Personeller');
end;

end.
