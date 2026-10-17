unit ufrmEInvTaxTypes;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  EInvTaxType.Service, EInvTaxType, ufrmEInvTaxType;

type
  TfrmEInvTaxTypes = class(TfrmGrid<TEInvTaxType, TEInvTaxTypeService>)
  private

  public
    // Yardımcı seçimde yalnız aktif kayıtlar (Show öncesi)
    procedure SetActiveOnly;
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure SetSelectedItem; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  EInvLookup;

procedure TfrmEInvTaxTypes.SetActiveOnly;
begin
  AddFixedFilter('is_active', True);
end;

function TfrmEInvTaxTypes.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmEInvTaxType.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmEInvTaxType.Create(Self, Service, TEInvTaxType.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmEInvTaxType.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmEInvTaxTypes.SetSelectedItem;

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

procedure TfrmEInvTaxTypes.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);

end;

procedure TfrmEInvTaxTypes.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmEInvTaxTypes.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TEInvTaxType.TitlePlural, 'Tax Type Codes');
  SetColumnTitle('code', TLocalizationManager.Translate(TLangKeys.TEInvTaxType.ColCode, 'Tax Code'));
  SetColumnTitle('name', TLocalizationManager.Translate(TLangKeys.TEInvTaxType.ColName, 'Name'));
  SetColumnTitle('short_name', TLocalizationManager.Translate(TLangKeys.TEInvTaxType.ColShortName, 'Short Name'));
  SetColumnTitle('is_active', TLocalizationManager.Translate(TLangKeys.TEInvTaxType.ColIsActive, 'Active'));
end;

end.
