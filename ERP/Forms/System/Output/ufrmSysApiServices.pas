unit ufrmSysApiServices;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  SysApiService.Service, SysApiService, ufrmSysApiService;

type
  TfrmSysApiServices = class(TfrmGrid<TSysApiService, TSysApiServiceService>)
  private
    procedure EnvironmentGetText(Sender: TField; var Text: string; DisplayText: Boolean);
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
  SysLookup;

procedure TfrmSysApiServices.EnvironmentGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if Sender.IsNull then
    Text := ''
  else
    Text := TSysLookup.Text(sylApiEnvironment, Sender.AsInteger);
end;

function TfrmSysApiServices.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmSysApiService.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSysApiService.Create(Self, Service, TSysApiService.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSysApiService.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmSysApiServices.SetSelectedItem;

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

procedure TfrmSysApiServices.DefineColumnWidths;
var
  LField: TField;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('sys_application_setting_id', 0);
  LField := Grd.DataSource.DataSet.FindField('environment');
  if Assigned(LField) then
    LField.OnGetText := EnvironmentGetText;
end;

procedure TfrmSysApiServices.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmSysApiServices.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSysApiService.TitlePlural, 'Integration Services');
  SetColumnTitle('service_kind', TLocalizationManager.Translate(TLangKeys.TSysApiService.ColServiceKind, 'Service Type'));
  SetColumnTitle('provider_code', TLocalizationManager.Translate(TLangKeys.TSysApiService.ColProviderCode, 'Provider'));
  SetColumnTitle('environment', TLocalizationManager.Translate(TLangKeys.TSysApiService.ColEnvironment, 'Environment'));
  SetColumnTitle('base_url', TLocalizationManager.Translate(TLangKeys.TSysApiService.ColBaseUrl, 'Service URL'));
  SetColumnTitle('username', TLocalizationManager.Translate(TLangKeys.TSysApiService.ColUsername, 'Username'));
  SetColumnTitle('timeout_seconds', TLocalizationManager.Translate(TLangKeys.TSysApiService.ColTimeoutSeconds, 'Timeout (s)'));
  SetColumnTitle('options', TLocalizationManager.Translate(TLangKeys.TSysApiService.ColOptions, 'Provider Options (JSON)'));
  SetColumnTitle('description', TLocalizationManager.Translate(TLangKeys.TSysApiService.ColDescription, 'Description'));
  SetColumnTitle('is_active', TLocalizationManager.Translate(TLangKeys.TSysApiService.ColIsActive, 'Active'));
  SetColumnTitle('has_password', TLocalizationManager.Translate(TLangKeys.TSysApiService.ColHasPassword, 'Password Saved'));
  SetColumnTitle('has_api_key', TLocalizationManager.Translate(TLangKeys.TSysApiService.ColHasApiKey, 'API Key Saved'));
  SetColumnTitle('password', TLocalizationManager.Translate(TLangKeys.TSysApiService.ColPassword, 'Password'));
  SetColumnTitle('api_key', TLocalizationManager.Translate(TLangKeys.TSysApiService.ColApiKey, 'API Key'));
  SetColumnTitle('clear_secrets', TLocalizationManager.Translate(TLangKeys.TSysApiService.ColClearSecrets, 'Delete saved password / key'));
end;

end.
