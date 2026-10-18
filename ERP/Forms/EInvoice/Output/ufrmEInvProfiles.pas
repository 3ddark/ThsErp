unit ufrmEInvProfiles;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  EInvProfile.Service, EInvProfile, ufrmEInvProfile;

type
  TfrmEInvProfiles = class(TfrmGrid<TEInvProfile, TEInvProfileService>)
  private
    procedure DocumentKindGetText(Sender: TField; var Text: string; DisplayText: Boolean);
  public
    // Yardımcı seçimde yalnız aktif kayıtlar (Show öncesi)
    procedure SetActiveOnly(AInvoiceOnly: Boolean = False; ADespatchOnly: Boolean = False);
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

procedure TfrmEInvProfiles.DocumentKindGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if Sender.IsNull then
    Text := ''
  else
    Text := TEInvLookup.Text(elkDocumentKind, Sender.AsInteger);
end;
procedure TfrmEInvProfiles.SetActiveOnly(AInvoiceOnly: Boolean = False; ADespatchOnly: Boolean = False);
begin
  AddFixedFilter('is_active', True);
  if AInvoiceOnly then
    AddFixedFilter('document_kind', EINV_DOC_INVOICE)
  else if ADespatchOnly then
    AddFixedFilter('document_kind', EINV_DOC_DESPATCH);
end;

function TfrmEInvProfiles.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmEInvProfile.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmEInvProfile.Create(Self, Service, TEInvProfile.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmEInvProfile.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmEInvProfiles.SetSelectedItem;

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

procedure TfrmEInvProfiles.DefineColumnWidths;
var
  LField: TField;
begin
  inherited;
  SetColumnProperty('id', 0);
  LField := Grd.DataSource.DataSet.FindField('document_kind');
  if Assigned(LField) then
    LField.OnGetText := DocumentKindGetText;
end;

procedure TfrmEInvProfiles.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmEInvProfiles.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TEInvProfile.TitlePlural, 'e-Document Profiles');
  SetColumnTitle('code', TLocalizationManager.Translate(TLangKeys.TEInvProfile.ColCode, 'Profile ID'));
  SetColumnTitle('name', TLocalizationManager.Translate(TLangKeys.TEInvProfile.ColName, 'Name'));
  SetColumnTitle('document_kind', TLocalizationManager.Translate(TLangKeys.TEInvProfile.ColDocumentKind, 'Document Kind'));
  SetColumnTitle('requires_export_info', TLocalizationManager.Translate(TLangKeys.TEInvProfile.ColRequiresExportInfo, 'Export Info Required (GTIP, Package, Delivery Term)'));
  SetColumnTitle('is_active', TLocalizationManager.Translate(TLangKeys.TEInvProfile.ColIsActive, 'Active'));
end;

end.
