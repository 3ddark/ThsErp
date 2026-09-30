unit ufrmEmpDriverLicenceTypes;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  EmpDriverLicenceType.Service, EmpDriverLicenceType, ufrmEmpDriverLicenceType;

type
  TfrmEmpDriverLicenceTypes = class(TfrmGrid<TEmpDriverLicenseType, TEmpDriverLicenseTypeService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure SetSelectedItem; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

function TfrmEmpDriverLicenceTypes.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmEmpDriverLicenceType.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmEmpDriverLicenceType.Create(Self, Service, TEmpDriverLicenseType.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmEmpDriverLicenceType.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmEmpDriverLicenceTypes.SetSelectedItem;

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
end;

procedure TfrmEmpDriverLicenceTypes.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);
end;

procedure TfrmEmpDriverLicenceTypes.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmEmpDriverLicenceTypes.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TEmpDriverLicenseType.TitlePlural, 'Driver License Types');
  SetColumnTitle('license_name', TLocalizationManager.Translate(TLangKeys.TEmpDriverLicenseType.ColLicenseName, 'License Class'));
end;

end.
