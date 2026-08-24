unit ufrmEmpSections;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, EmpSection.Service, EmpSection, ufrmEmpSection,
  LocalizationManager;

type
  TfrmEmpSections = class(TfrmGrid<TEmpSection, TEmpSectionService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

function TfrmEmpSections.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmEmpSection.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmEmpSection.Create(Self, Service, TEmpSection.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmEmpSection.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmEmpSections.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0, TLocalizationManager.Translate('emp_section.col_id', 'Id'));
  SetColumnProperty('section_name', 200, TLocalizationManager.Translate('emp_section.col_section_name', 'Bölüm Adı'));
end;

procedure TfrmEmpSections.DefineFooterColumns;
begin
  inherited;
  AddFooterColumn('id', atCount, '#,##0');
end;

procedure TfrmEmpSections.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
end;

procedure TfrmEmpSections.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate('emp_section.title_plural', 'Bölümler');
end;

end.
