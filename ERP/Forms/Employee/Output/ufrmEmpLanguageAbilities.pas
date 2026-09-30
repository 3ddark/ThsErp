unit ufrmEmpLanguageAbilities;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  EmpLanguageAbility.Service, EmpLanguageAbility, ufrmEmpLanguageAbility;

type
  TfrmEmpLanguageAbilities = class(TfrmGrid<TEmpLanguageAbility, TEmpLanguageAbilityService>)
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
    procedure LanguageLevelGetText(Sender: TField; var Text: string; DisplayText: Boolean);
  end;

implementation

{$R *.dfm}

uses
  EmpLookup;

procedure TfrmEmpLanguageAbilities.LanguageLevelGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if Sender.IsNull then
    Text := ''
  else
    Text := TEmpLookup.Text(elkLanguageLevel, Sender.AsInteger);
end;

procedure TfrmEmpLanguageAbilities.SetFixedEmployee(AEmployeeId: Int64; const AEmployeeName: string);
begin
  FFixedEmployeeId := AEmployeeId;
  FFixedEmployeeName := AEmployeeName;
  AddFixedFilter('emp_employee_id', AEmployeeId);
end;

function TfrmEmpLanguageAbilities.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
var
  LNew: TEmpLanguageAbility;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmEmpLanguageAbility.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
  begin
    LNew := TEmpLanguageAbility.Create;
    if FFixedEmployeeId > 0 then
    begin
      LNew.EmpEmployeeId := FFixedEmployeeId;
      LNew.EmployeeFullName := FFixedEmployeeName;
    end;
    Result := TfrmEmpLanguageAbility.Create(Self, Service, LNew, AFormMode, Self.RefreshParentGrid);
  end
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmEmpLanguageAbility.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmEmpLanguageAbilities.SetSelectedItem;

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
  Table.LanguageName := FieldText('language_name');
end;

procedure TfrmEmpLanguageAbilities.DefineColumnWidths;
var
  LField: TField;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('emp_employee_id', 0);
  SetColumnProperty('emp_language_id', 0);

  // Sayısal seçenek değerleri aktif dile göre metin olarak gösterilir
  LField := Grd.DataSource.DataSet.FindField('read_level');
  if Assigned(LField) then
    LField.OnGetText := LanguageLevelGetText;
  LField := Grd.DataSource.DataSet.FindField('write_level');
  if Assigned(LField) then
    LField.OnGetText := LanguageLevelGetText;
  LField := Grd.DataSource.DataSet.FindField('speak_level');
  if Assigned(LField) then
    LField.OnGetText := LanguageLevelGetText;
end;

procedure TfrmEmpLanguageAbilities.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmEmpLanguageAbilities.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TEmpLanguageAbility.TitlePlural, 'Employee Languages');
  if FFixedEmployeeName <> '' then
    Self.Caption := Self.Caption + ' - ' + FFixedEmployeeName;
  SetColumnTitle('full_name', TLocalizationManager.Translate(TLangKeys.TEmpLanguageAbility.ColEmployee, 'Employee'));
  SetColumnTitle('language_name', TLocalizationManager.Translate(TLangKeys.TEmpLanguageAbility.ColLanguageName, 'Language'));
  SetColumnTitle('read_level', TLocalizationManager.Translate(TLangKeys.TEmpLanguageAbility.ColReadLevel, 'Reading'));
  SetColumnTitle('write_level', TLocalizationManager.Translate(TLangKeys.TEmpLanguageAbility.ColWriteLevel, 'Writing'));
  SetColumnTitle('speak_level', TLocalizationManager.Translate(TLangKeys.TEmpLanguageAbility.ColSpeakLevel, 'Speaking'));
end;

end.
