unit ufrmEmpPersonTypes;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, EmpPersonType.Service, EmpPersonType, ufrmEmpPersonType,
  LocalizationManager;

type
  TfrmEmpPersonTypes = class(TfrmGrid<TEmpPersonType, TEmpPersonTypeService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

function TfrmEmpPersonTypes.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmEmpPersonType.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmEmpPersonType.Create(Self, Service, TEmpPersonType.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmEmpPersonType.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmEmpPersonTypes.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0, TLocalizationManager.Translate('emp_person_type.col_id', 'Id'));
  SetColumnProperty('person_type', 200, TLocalizationManager.Translate('emp_person_type.col_person_type', 'Personel Tipi'));
end;

procedure TfrmEmpPersonTypes.DefineFooterColumns;
begin
  inherited;
  AddFooterColumn('id', atCount, '#,##0');
end;

procedure TfrmEmpPersonTypes.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
end;

procedure TfrmEmpPersonTypes.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate('emp_person_type.title_plural', 'Personel Tipleri');
end;

end.
