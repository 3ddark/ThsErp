unit ufrmEmpLanguageAbilities;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, EmpLanguageAbility.Service, EmpLanguageAbility, ufrmEmpLanguageAbility,
  LocalizationManager;

type
  TfrmEmpLanguageAbilities = class(TfrmGrid<TEmpLanguageAbility, TEmpLanguageAbilityService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

function TfrmEmpLanguageAbilities.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmEmpLanguageAbility.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmEmpLanguageAbility.Create(Self, Service, TEmpLanguageAbility.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmEmpLanguageAbility.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmEmpLanguageAbilities.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0, TLocalizationManager.Translate('emp_language_ability.col_id', 'Id'));
  SetColumnProperty('person_id', 0, TLocalizationManager.Translate('emp_language_ability.col_person_id', 'Personel Id'));
  SetColumnProperty('language_id', 0, TLocalizationManager.Translate('emp_language_ability.col_language_id', 'Dil Id'));
  SetColumnProperty('read_id', 0, TLocalizationManager.Translate('emp_language_ability.col_read_id', 'Okuma Id'));
  SetColumnProperty('write_id', 0, TLocalizationManager.Translate('emp_language_ability.col_write_id', 'Yazma Id'));
  SetColumnProperty('speak_id', 0, TLocalizationManager.Translate('emp_language_ability.col_speak_id', 'Konuşma Id'));
end;

procedure TfrmEmpLanguageAbilities.DefineFooterColumns;
begin
  inherited;
  AddFooterColumn('id', atCount, '#,##0');
end;

procedure TfrmEmpLanguageAbilities.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
end;

procedure TfrmEmpLanguageAbilities.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate('emp_language_ability.title_plural', 'Personel Dil Yetkinlikleri');
end;

end.
