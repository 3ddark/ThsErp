unit ufrmEmpUnits;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, EmpUnit.Service, EmpUnit, ufrmEmpUnit,
  LocalizationManager;

type
  TfrmEmpUnits = class(TfrmGrid<TEmpUnit, TEmpUnitService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

function TfrmEmpUnits.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmEmpUnit.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmEmpUnit.Create(Self, Service, TEmpUnit.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmEmpUnit.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmEmpUnits.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0, TLocalizationManager.Translate('emp_unit.col_id', 'Id'));
  SetColumnProperty('unit_name', 200, TLocalizationManager.Translate('emp_unit.col_unit_name', 'Birim Adı'));
  SetColumnProperty('section_id', 0, TLocalizationManager.Translate('emp_unit.col_section_id', 'Bölüm Id'));
end;

procedure TfrmEmpUnits.DefineFooterColumns;
begin
  inherited;
  AddFooterColumn('id', atCount, '#,##0');
end;

procedure TfrmEmpUnits.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
end;

procedure TfrmEmpUnits.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate('emp_unit.title_plural', 'Birimler');
end;

end.
