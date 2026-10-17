unit ufrmEInvInvoiceTypes;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  EInvInvoiceType.Service, EInvInvoiceType, ufrmEInvInvoiceType;

type
  TfrmEInvInvoiceTypes = class(TfrmGrid<TEInvInvoiceType, TEInvInvoiceTypeService>)
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

procedure TfrmEInvInvoiceTypes.SetActiveOnly;
begin
  AddFixedFilter('is_active', True);
end;

function TfrmEInvInvoiceTypes.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmEInvInvoiceType.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmEInvInvoiceType.Create(Self, Service, TEInvInvoiceType.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmEInvInvoiceType.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmEInvInvoiceTypes.SetSelectedItem;

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

procedure TfrmEInvInvoiceTypes.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);

end;

procedure TfrmEInvInvoiceTypes.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmEInvInvoiceTypes.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TEInvInvoiceType.TitlePlural, 'e-Invoice Types');
  SetColumnTitle('code', TLocalizationManager.Translate(TLangKeys.TEInvInvoiceType.ColCode, 'Invoice Type Code'));
  SetColumnTitle('name', TLocalizationManager.Translate(TLangKeys.TEInvInvoiceType.ColName, 'Name'));
  SetColumnTitle('requires_exemption', TLocalizationManager.Translate(TLangKeys.TEInvInvoiceType.ColRequiresExemption, 'Exemption Code Required'));
  SetColumnTitle('requires_withholding', TLocalizationManager.Translate(TLangKeys.TEInvInvoiceType.ColRequiresWithholding, 'Withholding Required'));
  SetColumnTitle('is_return', TLocalizationManager.Translate(TLangKeys.TEInvInvoiceType.ColIsReturn, 'Return Invoice'));
  SetColumnTitle('is_active', TLocalizationManager.Translate(TLangKeys.TEInvInvoiceType.ColIsActive, 'Active'));
end;

end.
