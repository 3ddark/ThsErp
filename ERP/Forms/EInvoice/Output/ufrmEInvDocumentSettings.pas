unit ufrmEInvDocumentSettings;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  EInvDocumentSetting.Service, EInvDocumentSetting, ufrmEInvDocumentSetting;

type
  TfrmEInvDocumentSettings = class(TfrmGrid<TEInvDocumentSetting, TEInvDocumentSettingService>)
  private
    procedure SeriesScopeGetText(Sender: TField; var Text: string; DisplayText: Boolean);
  public
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

procedure TfrmEInvDocumentSettings.SeriesScopeGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if Sender.IsNull then
    Text := ''
  else
    Text := TEInvLookup.Text(elkSeriesScope, Sender.AsInteger);
end;

function TfrmEInvDocumentSettings.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmEInvDocumentSetting.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmEInvDocumentSetting.Create(Self, Service, TEInvDocumentSetting.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmEInvDocumentSetting.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmEInvDocumentSettings.SetSelectedItem;

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
  Table.SeriesCode := FieldText('series_code');
  Table.SeriesName := FieldText('series_name');
  Table.ServiceKind := FieldText('service_kind');
  Table.ProviderCode := FieldText('provider_code');
end;

procedure TfrmEInvDocumentSettings.DefineColumnWidths;
var
  LField: TField;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('sys_application_setting_id', 0);
  SetColumnProperty('einv_series_id', 0);
  SetColumnProperty('sys_api_service_id', 0);
  LField := Grd.DataSource.DataSet.FindField('series_scope');
  if Assigned(LField) then
    LField.OnGetText := SeriesScopeGetText;
end;

procedure TfrmEInvDocumentSettings.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmEInvDocumentSettings.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TEInvDocumentSetting.TitlePlural, 'e-Document Settings');
  SetColumnTitle('series_scope', TLocalizationManager.Translate(TLangKeys.TEInvDocumentSetting.ColSeriesScope, 'Document Type'));
  SetColumnTitle('sender_alias', TLocalizationManager.Translate(TLangKeys.TEInvDocumentSetting.ColSenderAlias, 'Sender Alias (GB)'));
  SetColumnTitle('receiver_alias', TLocalizationManager.Translate(TLangKeys.TEInvDocumentSetting.ColReceiverAlias, 'Receiver Alias (PK)'));
  SetColumnTitle('series_code', TLocalizationManager.Translate(TLangKeys.TEInvDocumentSetting.ColSeriesCode, 'Series'));
  SetColumnTitle('series_name', TLocalizationManager.Translate(TLangKeys.TEInvDocumentSetting.ColSeriesName, 'Series Name'));
  SetColumnTitle('service_kind', TLocalizationManager.Translate(TLangKeys.TEInvDocumentSetting.ColServiceKind, 'API Service'));
  SetColumnTitle('provider_code', TLocalizationManager.Translate(TLangKeys.TEInvDocumentSetting.ColProviderCode, 'Provider'));
  SetColumnTitle('environment', TLocalizationManager.Translate(TLangKeys.TEInvDocumentSetting.ColEnvironment, 'Environment'));
end;

end.
