unit ufrmEmpLanguages;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, EmpLanguage.Service, EmpLanguage, ufrmEmpLanguage,
  LocalizationManager;

type
  TfrmEmpLanguages = class(TfrmGrid<TEmpLanguage, TEmpLanguageService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

function TfrmEmpLanguages.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmEmpLanguage.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmEmpLanguage.Create(Self, Service, TEmpLanguage.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmEmpLanguage.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmEmpLanguages.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0, TLocalizationManager.Translate('emp_language.col_id', 'Id'));
  SetColumnProperty('language_name', 200, TLocalizationManager.Translate('emp_language.col_language_name', 'Dil Adı'));
end;

procedure TfrmEmpLanguages.DefineFooterColumns;
begin
  inherited;
  AddFooterColumn('id', atCount, '#,##0');
end;

procedure TfrmEmpLanguages.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
end;

procedure TfrmEmpLanguages.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate('emp_language.title_plural', 'Yabancı Diller');
end;

end.
