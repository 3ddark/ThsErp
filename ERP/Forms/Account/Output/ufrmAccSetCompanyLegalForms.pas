unit ufrmAccSetCompanyLegalForms;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  AccSetCompanyLegalForm.Service, AccSetCompanyLegalForm, ufrmAccSetCompanyLegalForm;

type
  TfrmAccSetCompanyLegalForms = class(TfrmGrid<TAccSetCompanyLegalForm, TAccSetCompanyLegalFormService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure SetSelectedItem; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

function TfrmAccSetCompanyLegalForms.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmAccSetCompanyLegalForm.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmAccSetCompanyLegalForm.Create(Self, Service, TAccSetCompanyLegalForm.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmAccSetCompanyLegalForm.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmAccSetCompanyLegalForms.SetSelectedItem;

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
  Table.LegalFormName := FieldText('legal_form_name');
  Table.OwnershipTypeName := FieldText('ownership_type_name');
end;

procedure TfrmAccSetCompanyLegalForms.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('acc_set_ownership_type_id', 0);
  SetColumnProperty('locale', 0);
end;

procedure TfrmAccSetCompanyLegalForms.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmAccSetCompanyLegalForms.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TAccSetCompanyLegalForm.TitlePlural, 'Company Legal Forms');
  SetColumnTitle('legal_form_key', TLocalizationManager.Translate(TLangKeys.TAccSetCompanyLegalForm.ColLegalFormKey, 'Key'));
  SetColumnTitle('legal_form_name', TLocalizationManager.Translate(TLangKeys.TAccSetCompanyLegalForm.ColLegalFormName, 'Legal Form'));
  SetColumnTitle('ownership_type_name', TLocalizationManager.Translate(TLangKeys.TAccSetCompanyLegalForm.ColOwnershipType, 'Ownership Type'));
end;

end.
