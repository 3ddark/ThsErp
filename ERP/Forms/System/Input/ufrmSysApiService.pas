unit ufrmSysApiService;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  SysApiService.Service, SysApiService;

type
  TfrmSysApiService = class(TfrmInputSimpleDB<TSysApiService, TSysApiServiceService>)
    pnlContent: TPanel;
    lblServiceKind: TLabel;
    edtServiceKind: TEdit;
    lblProviderCode: TLabel;
    edtProviderCode: TEdit;
    lblEnvironment: TLabel;
    cbbEnvironment: TComboBox;
    lblBaseUrl: TLabel;
    edtBaseUrl: TEdit;
    lblUsername: TLabel;
    edtUsername: TEdit;
    lblPassword: TLabel;
    edtPassword: TEdit;
    lblApiKey: TLabel;
    edtApiKey: TEdit;
    chkClearSecrets: TCheckBox;
    lblTimeoutSeconds: TLabel;
    edtTimeoutSeconds: TEdit;
    lblOptions: TLabel;
    mmoOptions: TMemo;
    lblDescription: TLabel;
    edtDescription: TEdit;
    lblIsActive: TLabel;
    chkIsActive: TCheckBox;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  SysLookup;

procedure TfrmSysApiService.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.ServiceKind := edtServiceKind.Text;
  Table.ProviderCode := edtProviderCode.Text;
  Table.Environment := cbbEnvironment.ItemIndex + 1;
  Table.BaseUrl := edtBaseUrl.Text;
  Table.Username := edtUsername.Text;
  Table.Password := edtPassword.Text;
  Table.ApiKey := edtApiKey.Text;
  Table.ClearSecrets := chkClearSecrets.Checked;
  Table.TimeoutSeconds := StrToIntDef(edtTimeoutSeconds.Text, 0);
  Table.Options := mmoOptions.Text;
  Table.Description := edtDescription.Text;
  Table.IsActive := chkIsActive.Checked;
  inherited;
end;

procedure TfrmSysApiService.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtServiceKind.thsInputDataType := itString;
  edtProviderCode.thsInputDataType := itString;
  edtProviderCode.CharCase := TEditCharCase.ecUpperCase;
  TSysLookup.FillItems(cbbEnvironment.Items, sylApiEnvironment);
  edtBaseUrl.thsInputDataType := itString;
  edtUsername.thsInputDataType := itString;
  edtPassword.thsInputDataType := itString;
  edtApiKey.thsInputDataType := itString;
  // sekme sırası: kullanıcı adının ardından
  edtPassword.TabOrder := edtUsername.TabOrder + 1;
  edtApiKey.TabOrder := edtPassword.TabOrder + 1;
  chkClearSecrets.TabOrder := edtApiKey.TabOrder + 1;
  edtTimeoutSeconds.thsInputDataType := itInteger;
  edtDescription.thsInputDataType := itString;
end;

procedure TfrmSysApiService.FormShow(Sender: TObject);
begin
  inherited;
  if edtServiceKind.CanFocus then
    edtServiceKind.SetFocus;
end;

procedure TfrmSysApiService.ApplyLocalization;
var
  LIndex: Integer;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSysApiService.TitleSingular, 'Integration Service');
  lblServiceKind.Caption := TLocalizationManager.Translate(TLangKeys.TSysApiService.ColServiceKind, 'Service Type');
  lblProviderCode.Caption := TLocalizationManager.Translate(TLangKeys.TSysApiService.ColProviderCode, 'Provider');
  lblEnvironment.Caption := TLocalizationManager.Translate(TLangKeys.TSysApiService.ColEnvironment, 'Environment');
  LIndex := cbbEnvironment.ItemIndex;
  TSysLookup.FillItems(cbbEnvironment.Items, sylApiEnvironment);
  cbbEnvironment.ItemIndex := LIndex;
  lblBaseUrl.Caption := TLocalizationManager.Translate(TLangKeys.TSysApiService.ColBaseUrl, 'Service URL');
  lblUsername.Caption := TLocalizationManager.Translate(TLangKeys.TSysApiService.ColUsername, 'Username');
  lblPassword.Caption := TLocalizationManager.Translate(TLangKeys.TSysApiService.ColPassword, 'Password');
  lblApiKey.Caption := TLocalizationManager.Translate(TLangKeys.TSysApiService.ColApiKey, 'API Key');
  chkClearSecrets.Caption := TLocalizationManager.Translate(TLangKeys.TSysApiService.ColClearSecrets, 'Delete saved password / key');
  lblTimeoutSeconds.Caption := TLocalizationManager.Translate(TLangKeys.TSysApiService.ColTimeoutSeconds, 'Timeout (s)');
  lblOptions.Caption := TLocalizationManager.Translate(TLangKeys.TSysApiService.ColOptions, 'Provider Options (JSON)');
  lblDescription.Caption := TLocalizationManager.Translate(TLangKeys.TSysApiService.ColDescription, 'Description');
  lblIsActive.Caption := TLocalizationManager.Translate(TLangKeys.TSysApiService.ColIsActive, 'Active');
end;

procedure TfrmSysApiService.RefreshData;
begin
  inherited;
  edtServiceKind.Text := Table.ServiceKind;
  edtProviderCode.Text := Table.ProviderCode;
  cbbEnvironment.ItemIndex := Table.Environment - 1;
  edtBaseUrl.Text := Table.BaseUrl;
  edtUsername.Text := Table.Username;
  // kayıtlı gizli bilgi gösterilmez; boş bırakılırsa değişmez (yer tutucu: kayıtlı olduğu)
  edtPassword.Clear;
  edtApiKey.Clear;
  if Table.HasPassword then
    edtPassword.TextHint := '********'
  else
    edtPassword.TextHint := '';
  if Table.HasApiKey then
    edtApiKey.TextHint := '********'
  else
    edtApiKey.TextHint := '';
  chkClearSecrets.Checked := False;
  chkClearSecrets.Enabled := Table.HasPassword or Table.HasApiKey;
  edtTimeoutSeconds.Text := IntToStr(Table.TimeoutSeconds);
  mmoOptions.Text := Table.Options;
  edtDescription.Text := Table.Description;
  chkIsActive.Checked := Table.IsActive;
end;

end.
