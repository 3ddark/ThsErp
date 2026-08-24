unit ufrmEmpLanguageLevels;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, EmpLanguageLevel.Service, EmpLanguageLevel, ufrmEmpLanguageLevel,
  LocalizationManager;

type
  TfrmEmpLanguageLevels = class(TfrmGrid<TEmpLanguageLevel, TEmpLanguageLevelService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

function TfrmEmpLanguageLevels.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmEmpLanguageLevel.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmEmpLanguageLevel.Create(Self, Service, TEmpLanguageLevel.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmEmpLanguageLevel.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmEmpLanguageLevels.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0, TLocalizationManager.Translate('emp_language_level.col_id', 'Id'));
  SetColumnProperty('language_level', 200, TLocalizationManager.Translate('emp_language_level.col_language_level', 'Dil Seviyesi'));
end;

procedure TfrmEmpLanguageLevels.DefineFooterColumns;
begin
  inherited;
  AddFooterColumn('id', atCount, '#,##0');
end;

procedure TfrmEmpLanguageLevels.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
end;

procedure TfrmEmpLanguageLevels.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate('emp_language_level.title_plural', 'Dil Seviyeleri');
end;

end.
