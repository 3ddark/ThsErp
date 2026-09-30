unit ufrmEmpUnits;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  EmpUnit.Service, EmpUnit, ufrmEmpUnit;

type
  TfrmEmpUnits = class(TfrmGrid<TEmpUnit, TEmpUnitService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure SetSelectedItem; override;
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
    Result := TfrmEmpUnit.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmEmpUnit.Create(Self, Service, TEmpUnit.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmEmpUnit.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmEmpUnits.SetSelectedItem;

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
  Table.EmpUnitName := FieldText('unit_name');
  Table.SectionName := FieldText('section_name');
end;

procedure TfrmEmpUnits.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('emp_section_id', 0);
  SetColumnProperty('locale', 0);
end;

procedure TfrmEmpUnits.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmEmpUnits.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TEmpUnit.TitlePlural, 'Units');
  SetColumnTitle('unit_key', TLocalizationManager.Translate(TLangKeys.TEmpUnit.ColUnitKey, 'Key'));
  SetColumnTitle('unit_name', TLocalizationManager.Translate(TLangKeys.TEmpUnit.ColUnitName, 'Unit Name'));
  SetColumnTitle('section_name', TLocalizationManager.Translate(TLangKeys.TEmpUnit.ColSection, 'Section'));
end;

end.
