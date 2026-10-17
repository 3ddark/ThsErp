unit ufrmEInvTaxExemptions;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  EInvTaxExemption.Service, EInvTaxExemption, ufrmEInvTaxExemption;

type
  TfrmEInvTaxExemptions = class(TfrmGrid<TEInvTaxExemption, TEInvTaxExemptionService>)
  private
    procedure ExemptionGroupGetText(Sender: TField; var Text: string; DisplayText: Boolean);
  public
    // Yardımcı seçimde yalnız aktif kayıtlar (Show öncesi)
    // APlainOnly: faturada %0 KDV'li kalem yok -> yalnız KDV'li kalemle kullanılan kodlar (555, ÖTV, özel matrah ...)
    procedure SetActiveOnly(AInvoiceTypeId: Int64 = 0; APlainOnly: Boolean = False);
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure SetSelectedItem; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  EInvLookup,
  Grid.Sql, FireDAC.Stan.Param;

procedure TfrmEInvTaxExemptions.ExemptionGroupGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if Sender.IsNull then
    Text := ''
  else
    Text := TEInvLookup.Text(elkExemptionGroup, Sender.AsInteger);
end;
procedure TfrmEInvTaxExemptions.SetActiveOnly(AInvoiceTypeId: Int64 = 0; APlainOnly: Boolean = False);
begin
  AddFixedFilter('is_active', True);
  if APlainOnly then
    AddFixedFilter('requires_zero_vat', False);
  // fatura tipine ait kodlar + tipi boş (tüm tiplerde geçerli) kodlar
  if AInvoiceTypeId > 0 then
  begin
    Qry.SQL.Text := AddWhereCondition(Qry.SQL.Text, '(einv_invoice_type_id = :fixed_type OR einv_invoice_type_id IS NULL)');
    Qry.ParamByName('fixed_type').AsLargeInt := AInvoiceTypeId;
  end;
end;

function TfrmEInvTaxExemptions.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmEInvTaxExemption.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmEInvTaxExemption.Create(Self, Service, TEInvTaxExemption.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmEInvTaxExemption.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmEInvTaxExemptions.SetSelectedItem;

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
  Table.InvoiceTypeCode := FieldText('invoice_type_code');
end;

procedure TfrmEInvTaxExemptions.DefineColumnWidths;
var
  LField: TField;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('einv_invoice_type_id', 0);
  LField := Grd.DataSource.DataSet.FindField('exemption_group');
  if Assigned(LField) then
    LField.OnGetText := ExemptionGroupGetText;
end;

procedure TfrmEInvTaxExemptions.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmEInvTaxExemptions.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TEInvTaxExemption.TitlePlural, 'Tax Exemption Codes');
  SetColumnTitle('code', TLocalizationManager.Translate(TLangKeys.TEInvTaxExemption.ColCode, 'Exemption Code'));
  SetColumnTitle('name', TLocalizationManager.Translate(TLangKeys.TEInvTaxExemption.ColName, 'Reason'));
  SetColumnTitle('exemption_group', TLocalizationManager.Translate(TLangKeys.TEInvTaxExemption.ColExemptionGroup, 'Exemption Group'));
  SetColumnTitle('requires_gtip', TLocalizationManager.Translate(TLangKeys.TEInvTaxExemption.ColRequiresGtip, 'GTIP Required on Lines'));
  SetColumnTitle('requires_diib', TLocalizationManager.Translate(TLangKeys.TEInvTaxExemption.ColRequiresDiib, 'DIIB Line Code Required'));
  SetColumnTitle('requires_zero_vat', TLocalizationManager.Translate(TLangKeys.TEInvTaxExemption.ColRequiresZeroVat, 'Needs a 0% VAT Line'));
  SetColumnTitle('is_active', TLocalizationManager.Translate(TLangKeys.TEInvTaxExemption.ColIsActive, 'Active'));
  SetColumnTitle('invoice_type_code', TLocalizationManager.Translate(TLangKeys.TEInvTaxExemption.ColInvoiceTypeCode, 'Invoice Type'));
end;

end.
