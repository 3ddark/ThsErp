unit ufrmSysApplicationSetting;

interface

{$I Ths.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.StrUtils, System.Math, REST.Json,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Samples.Spin, Vcl.ComCtrls, Vcl.AppEvnts, Vcl.Menus,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  SysApplicationSetting, SysApplicationSetting.Service,
  SysCity.Service, SysCity;

type
  TfrmSysApplicationSetting = class(TfrmInputSimpleDB<TSysApplicationSetting, TSysApplicationSettingService>)
    pnlMain: TPanel;
    pgcMain: TPageControl;
    tsGeneral: TTabSheet;
    lblCompanyTitle: TLabel;
    edtCompanyTitle: TEdit;
    lblPhone: TLabel;
    edtPhone: TEdit;
    lblFax: TLabel;
    edtFax: TEdit;
    pnlLogo: TPanel;
    tsAddress: TTabSheet;
    lblTaxpayerType: TLabel;
    cbbTaxpayerType: TComboBox;
    lblTaxpayerName: TLabel;
    edtTaxpayerName: TEdit;
    lblTaxpayerSurname: TLabel;
    edtTaxpayerSurname: TEdit;
    lblTaxNo: TLabel;
    edtTaxNo: TEdit;
    lblTaxAuthority: TLabel;
    edtTaxAuthority: TEdit;
    lblCountryName: TLabel;
    edtCountryName: TEdit;
    lblSysCityId: TLabel;
    edtSysCityId: TEdit;
    lblDistrict: TLabel;
    edtDistrict: TEdit;
    lblNeighborhood: TLabel;
    edtNeighborhood: TEdit;
    lblQuarter: TLabel;
    edtQuarter: TEdit;
    lblRoad: TLabel;
    edtRoad: TEdit;
    lblStreet: TLabel;
    edtStreet: TEdit;
    lblBuildingName: TLabel;
    edtBuildingName: TEdit;
    lblDoorNumber: TLabel;
    edtDoorNumber: TEdit;
    lblZipCode: TLabel;
    edtZipCode: TEdit;
    lblWeb: TLabel;
    edtWeb: TEdit;
    lblEmail: TLabel;
    edtEmail: TEdit;
    tsService: TTabSheet;
    lblMailHost: TLabel;
    edtMailHost: TEdit;
    lblMailUser: TLabel;
    edtMailUser: TEdit;
    lblMailPassword: TLabel;
    edtMailPassword: TEdit;
    lblMailSmtpPort: TLabel;
    edtMailSmtpPort: TEdit;
    lblSmsHost: TLabel;
    edtSmsHost: TEdit;
    lblSmsUser: TLabel;
    edtSmsUser: TEdit;
    lblSmsPassword: TLabel;
    edtSmsPassword: TEdit;
    lblSmsTitle: TLabel;
    edtSmsTitle: TEdit;
    tsOther: TTabSheet;
    lblPathStockCardImage: TLabel;
    edtPathStockCardImage: TEdit;
    btnPathStockCardImage: TButton;
    lblPathPersonnelCardImage: TLabel;
    edtPathPersonnelCardImage: TEdit;
    btnPathPersonnelCardImage: TButton;
    lblPathUpdate: TLabel;
    edtPathUpdate: TEdit;
    btnPathUpdate: TButton;
    tsVisual: TTabSheet;
    lblGridColor1: TLabel;
    edtGridColor1: TEdit;
    lblGridColor2: TLabel;
    edtGridColor2: TEdit;
    lblGridColorActive: TLabel;
    edtGridColorActive: TEdit;
    lblCryptKey: TLabel;
    edtCryptKey: TEdit;
    lblPeriod: TLabel;
    edtPeriod: TEdit;
    lblAppVersion: TLabel;
    edtAppVersion: TEdit;
    procedure edtGridColor1DblClick(Sender: TObject);
    procedure edtGridColor2DblClick(Sender: TObject);
    procedure edtGridColorActiveDblClick(Sender: TObject);
    procedure edtGridColor1Exit(Sender: TObject);
    procedure edtGridColor2Exit(Sender: TObject);
    procedure edtGridColorActiveExit(Sender: TObject);
    procedure btnPathStockCardImageClick(Sender: TObject);
    procedure btnPathPersonnelCardImageClick(Sender: TObject);
    procedure btnPathUpdateClick(Sender: TObject);
    procedure cbbTaxpayerTypeChange(Sender: TObject);
  private
    procedure SetColor(color: TColor; editColor: TEdit);
    procedure UpdatePathButtons;
  protected
    procedure HelperProcess(Sender: TObject);
  public
    function ValidateInput(panel_groupbox_pagecontrol_tabsheet: TWinControl = nil): Boolean; override;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
    procedure RefreshData(); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  Ths.Globals, Ths.Constants, Ths.Utils.Images, SysAddress,
  ufrmSysCities; // TfrmSysCities helper output form

procedure TfrmSysApplicationSetting.btnPathStockCardImageClick(Sender: TObject);
begin
  edtPathStockCardImage.Text := GetDialogDirectory;
end;

procedure TfrmSysApplicationSetting.cbbTaxpayerTypeChange(Sender: TObject);
begin
  inherited;
  if cbbTaxpayerType.ItemIndex = Ord(TMukellefTipi.TCKN) then
  begin
    edtTaxNo.MaxLength := 11;
    edtTaxAuthority.Clear;
    lblTaxAuthority.Visible := False;
    edtTaxAuthority.Visible := False;

    lblTaxpayerName.Visible := True;
    edtTaxpayerName.Visible := True;
    lblTaxpayerSurname.Visible := True;
    edtTaxpayerSurname.Visible := True;
  end
  else if cbbTaxpayerType.ItemIndex = Ord(TMukellefTipi.VKN) then
  begin
    edtTaxNo.MaxLength := 10;
    lblTaxAuthority.Visible := True;
    edtTaxAuthority.Visible := True;

    edtTaxpayerName.Clear;
    lblTaxpayerName.Visible := False;
    edtTaxpayerName.Visible := False;
    edtTaxpayerSurname.Clear;
    lblTaxpayerSurname.Visible := False;
    edtTaxpayerSurname.Visible := False;
  end;
end;

procedure TfrmSysApplicationSetting.btnPathUpdateClick(Sender: TObject);
begin
  edtPathUpdate.Text := GetDialogDirectory;
end;

procedure TfrmSysApplicationSetting.btnPathPersonnelCardImageClick(Sender: TObject);
begin
  edtPathPersonnelCardImage.Text := GetDialogDirectory;
end;

procedure TfrmSysApplicationSetting.edtGridColor1DblClick(Sender: TObject);
begin
  if (FormMode = ifmUpdate) or (FormMode = ifmNewRecord) then
    SetColor(GetDialogColor(StrToIntDef(edtGridColor1.Text, 0)), edtGridColor1);
end;

procedure TfrmSysApplicationSetting.edtGridColor1Exit(Sender: TObject);
begin
  inherited;
  SetColor(StrToIntDef(edtGridColor1.Text, 0), edtGridColor1);
  edtGridColor1.Refresh;
end;

procedure TfrmSysApplicationSetting.edtGridColor2DblClick(Sender: TObject);
begin
  if (FormMode = ifmUpdate) or (FormMode = ifmNewRecord) then
    SetColor(GetDialogColor(StrToIntDef(edtGridColor2.Text, 0)), edtGridColor2);
end;

procedure TfrmSysApplicationSetting.edtGridColor2Exit(Sender: TObject);
begin
  inherited;
  SetColor(StrToIntDef(edtGridColor2.Text, 0), edtGridColor2);
  edtGridColor2.Refresh;
end;

procedure TfrmSysApplicationSetting.edtGridColorActiveDblClick(Sender: TObject);
begin
  if (FormMode = ifmUpdate) or (FormMode = ifmNewRecord) then
    SetColor(GetDialogColor(StrToIntDef(edtGridColorActive.Text, 0)), edtGridColorActive);
end;

procedure TfrmSysApplicationSetting.edtGridColorActiveExit(Sender: TObject);
begin
  inherited;
  SetColor(StrToIntDef(edtGridColorActive.Text, 0), edtGridColorActive);
  edtGridColorActive.Repaint;
end;

procedure TfrmSysApplicationSetting.FormCreate(Sender: TObject);
begin
  inherited;
  pnlMain.Parent := PanelMain;
  edtSysCityId.OnHelperProcess := HelperProcess;

  edtCompanyTitle.CharCase := TEditCharCase.ecNormal;
  edtWeb.CharCase := TEditCharCase.ecNormal;
  edtEmail.CharCase := TEditCharCase.ecNormal;
  edtMailHost.CharCase := TEditCharCase.ecNormal;
  edtMailUser.CharCase := TEditCharCase.ecNormal;
  edtMailPassword.CharCase := TEditCharCase.ecNormal;
  edtAppVersion.CharCase := TEditCharCase.ecNormal;

  edtSmsHost.CharCase := TEditCharCase.ecNormal;
  edtSmsUser.CharCase := TEditCharCase.ecNormal;
  edtSmsPassword.CharCase := TEditCharCase.ecNormal;
  edtSmsTitle.CharCase := TEditCharCase.ecNormal;

  edtPathStockCardImage.CharCase := TEditCharCase.ecNormal;
  edtPathPersonnelCardImage.CharCase := TEditCharCase.ecNormal;
  edtPathUpdate.CharCase := TEditCharCase.ecNormal;

  edtCryptKey.CharCase := TEditCharCase.ecNormal;

  cbbTaxpayerType.CharCase := TEditCharCase.ecNormal;
  cbbTaxpayerType.Clear;
  cbbTaxpayerType.Items.Add('TC Kimlik No (TCKN)');
  cbbTaxpayerType.Items.Add('Vergi Kimlik No (VKN)');
  cbbTaxpayerType.ItemIndex := 0;
  cbbTaxpayerTypeChange(cbbTaxpayerType);
end;

procedure TfrmSysApplicationSetting.UpdatePathButtons;
var
  LEditable: Boolean;
begin
  // Dizin alanları yalnızca seçim düğmesiyle doldurulur
  edtPathStockCardImage.ReadOnly := True;
  edtPathPersonnelCardImage.ReadOnly := True;
  edtPathUpdate.ReadOnly := True;

  LEditable := FormMode in [ifmNewRecord, ifmCopyNewRecord, ifmUpdate];
  btnPathStockCardImage.Enabled := LEditable;
  btnPathPersonnelCardImage.Enabled := LEditable;
  btnPathUpdate.Enabled := LEditable;
end;

procedure TfrmSysApplicationSetting.FormShow(Sender: TObject);
begin
  inherited;

  edtCountryName.ReadOnly := True;
  edtDistrict.CharCase := ecUpperCase;
  edtNeighborhood.CharCase := ecUpperCase;
  edtQuarter.CharCase := ecUpperCase;
  edtRoad.CharCase := ecUpperCase;
  edtStreet.CharCase := ecUpperCase;
  edtBuildingName.CharCase := ecUpperCase;
  edtDoorNumber.CharCase := ecUpperCase;
  edtZipCode.CharCase := ecUpperCase;
end;

procedure TfrmSysApplicationSetting.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSysApplicationSetting.TitleSingular, 'Application Settings');

  // Tabs
  tsGeneral.Caption := TLocalizationManager.Translate(TLangKeys.TSysApplicationSetting.TabGeneral, 'General Settings');
  tsAddress.Caption := TLocalizationManager.Translate(TLangKeys.TSysApplicationSetting.TabAddress, 'Address Information');
  tsService.Caption := TLocalizationManager.Translate(TLangKeys.TSysApplicationSetting.TabService, 'Service Settings');
  tsOther.Caption := TLocalizationManager.Translate(TLangKeys.TSysApplicationSetting.TabOther, 'Other Settings');
  tsVisual.Caption := TLocalizationManager.Translate(TLangKeys.TSysApplicationSetting.TabVisual, 'Visual Settings');

  // General tab
  lblCompanyTitle.Caption := TLocalizationManager.Translate(TLangKeys.TSysApplicationSetting.ColCompanyTitle, 'Company Title');
  lblPhone.Caption := TLocalizationManager.Translate(TLangKeys.TSysApplicationSetting.ColPhone, 'Phone');
  lblFax.Caption := TLocalizationManager.Translate(TLangKeys.TSysApplicationSetting.ColFax, 'Fax');
  pnlLogo.Caption := TLocalizationManager.Translate(TLangKeys.TSysApplicationSetting.ColLogo, 'Logo');

  // Address tab
  lblTaxpayerType.Caption := TLocalizationManager.Translate(TLangKeys.TSysApplicationSetting.ColTaxpayerType, 'Taxpayer Type');
  lblTaxpayerName.Caption := TLocalizationManager.Translate(TLangKeys.TSysApplicationSetting.ColTaxpayerName, 'Taxpayer Name');
  lblTaxpayerSurname.Caption := TLocalizationManager.Translate(TLangKeys.TSysApplicationSetting.ColTaxpayerSurname, 'Taxpayer Surname');
  lblTaxNo.Caption := TLocalizationManager.Translate(TLangKeys.TSysApplicationSetting.ColTaxNo, 'Tax Number');
  lblTaxAuthority.Caption := TLocalizationManager.Translate(TLangKeys.TSysApplicationSetting.ColTaxAuthority, 'Tax Authority');
  lblCountryName.Caption := TLocalizationManager.Translate(TLangKeys.TSysCountry.ColCountryName, 'Country Name');
  lblSysCityId.Caption := TLocalizationManager.Translate(TLangKeys.TSysCity.TitleSingular, 'City');
  lblDistrict.Caption := TLocalizationManager.Translate(TLangKeys.TSysAddress.ColDistrict, 'District');
  lblNeighborhood.Caption := TLocalizationManager.Translate(TLangKeys.TSysAddress.ColNeighborhood, 'Neighborhood');
  lblQuarter.Caption := TLocalizationManager.Translate(TLangKeys.TSysAddress.ColQuarter, 'Quarter');
  lblRoad.Caption := TLocalizationManager.Translate(TLangKeys.TSysAddress.ColRoad, 'Road');
  lblStreet.Caption := TLocalizationManager.Translate(TLangKeys.TSysAddress.ColStreet, 'Street');
  lblBuildingName.Caption := TLocalizationManager.Translate(TLangKeys.TSysAddress.ColBuildingName, 'Building Name');
  lblDoorNumber.Caption := TLocalizationManager.Translate(TLangKeys.TSysAddress.ColDoorNumber, 'Door Number');
  lblZipCode.Caption := TLocalizationManager.Translate(TLangKeys.TSysAddress.ColZipCode, 'Zip Code');
  lblEmail.Caption := TLocalizationManager.Translate(TLangKeys.TSysAddress.ColEmail, 'e-Mail');
  lblWeb.Caption := TLocalizationManager.Translate(TLangKeys.TSysAddress.ColWeb, 'Web');

  // Service tab
  lblMailHost.Caption := TLocalizationManager.Translate(TLangKeys.TSysApplicationSetting.ColMailHost, 'Mail Host');
  lblMailUser.Caption := TLocalizationManager.Translate(TLangKeys.TSysApplicationSetting.ColMailUser, 'Mail User');
  lblMailPassword.Caption := TLocalizationManager.Translate(TLangKeys.TSysApplicationSetting.ColMailPassword, 'Mail Password');
  lblMailSmtpPort.Caption := TLocalizationManager.Translate(TLangKeys.TSysApplicationSetting.ColMailSmtpPort, 'SMTP Port');
  lblSmsHost.Caption := TLocalizationManager.Translate(TLangKeys.TSysApplicationSetting.ColSmsHost, 'SMS Host');
  lblSmsUser.Caption := TLocalizationManager.Translate(TLangKeys.TSysApplicationSetting.ColSmsUser, 'SMS User');
  lblSmsPassword.Caption := TLocalizationManager.Translate(TLangKeys.TSysApplicationSetting.ColSmsPassword, 'SMS Password');
  lblSmsTitle.Caption := TLocalizationManager.Translate(TLangKeys.TSysApplicationSetting.ColSmsTitle, 'SMS Title');

  // Other settings tab
  lblPathStockCardImage.Caption := TLocalizationManager.Translate(TLangKeys.TSysApplicationSetting.ColPathStockCardImage, 'Stock Card Image Path');
  lblPathPersonnelCardImage.Caption := TLocalizationManager.Translate(TLangKeys.TSysApplicationSetting.ColPathPersonnelCardImage, 'Personnel Card Image Path');
  lblPathUpdate.Caption := TLocalizationManager.Translate(TLangKeys.TSysApplicationSetting.ColPathUpdate, 'Update File Path');

  // Visual tab
  lblGridColor1.Caption := TLocalizationManager.Translate(TLangKeys.TSysApplicationSetting.ColGridColor1, 'Grid Color 1');
  lblGridColor2.Caption := TLocalizationManager.Translate(TLangKeys.TSysApplicationSetting.ColGridColor2, 'Grid Color 2');
  lblGridColorActive.Caption := TLocalizationManager.Translate(TLangKeys.TSysApplicationSetting.ColGridColorActive, 'Grid Color Active');
  lblCryptKey.Caption := TLocalizationManager.Translate(TLangKeys.TSysApplicationSetting.ColCryptKey, 'Encryption Key');
  lblPeriod.Caption := TLocalizationManager.Translate(TLangKeys.TSysApplicationSetting.ColPeriod, 'Period');
  lblAppVersion.Caption := TLocalizationManager.Translate(TLangKeys.TSysApplicationSetting.ColAppVersion, 'App Version');
end;

procedure TfrmSysApplicationSetting.HelperProcess(Sender: TObject);
var
  LFrmCity: TfrmSysCities;
begin
  if (Sender.ClassType <> TEdit) then
    Exit;

  if (FormMode <> ifmNewRecord) and (FormMode <> ifmCopyNewRecord) and (FormMode <> ifmUpdate) then
    Exit;

  if not Assigned(Table.SysAddress) then
    Table.SysAddress := TSysAddress.Create;

  if TEdit(Sender).Name = edtSysCityId.Name then
  begin
    LFrmCity := TfrmSysCities.Create(TEdit(Sender), TSysCityService.Create, TSysCity.Create, True, True);
    try
      LFrmCity.ShowModal;
      if not LFrmCity.DataTransfer then
        Exit;

      if LFrmCity.CleanAndClose then
      begin
        TEdit(Sender).Clear;
        edtCountryName.Clear;
        Table.SysAddress.SysCityId := 0;
      end
      else
      begin
        TEdit(Sender).Text := LFrmCity.Table.CityName;
        if Assigned(LFrmCity.Table.SysCountry) then
          edtCountryName.Text := LFrmCity.Table.SysCountry.CountryName;
        Table.SysAddress.SysCityId := LFrmCity.Table.Id;
      end;
    finally
      LFrmCity.Free;
    end;
  end;
end;

procedure TfrmSysApplicationSetting.RefreshData;
begin
  edtCompanyTitle.Text := Table.CompanyTitle;
  edtPhone.Text := Table.Phone;
  edtFax.Text := Table.Fax;

  edtGridColor1.Text := Table.GridColor1.ToString;
  edtGridColor2.Text := Table.GridColor2.ToString;
  edtGridColorActive.Text := Table.GridColorActive.ToString;
  edtCryptKey.Text := Table.CryptKey;
  edtPeriod.Text := Table.ActivePeriod.ToString;
  edtAppVersion.Text := Table.AppVersion;

  edtMailHost.Text := Table.MailHost;
  edtMailUser.Text := Table.MailUser;
  if FormMode = ifmUpdate then
  begin
    if Table.MailPassword <> '' then
      edtMailPassword.Text := DecryptStr(Table.MailPassword, Table.CryptKey)
  end
  else
    edtMailPassword.Text := Table.MailPassword;
  edtMailSmtpPort.Text := Table.MailSmtpPort.ToString;
  edtSmsHost.Text := Table.SmsHost;
  edtSmsUser.Text := Table.SmsUser;
  if FormMode = ifmUpdate then
  begin
    if Table.SmsPassword <> '' then
      edtSmsPassword.Text := DecryptStr(Table.SmsPassword, Table.CryptKey)
  end
  else
    edtSmsPassword.Text := Table.SmsPassword;
  edtSmsTitle.Text := Table.SmsTitle;

  if Table.Taxpayertype = 'TCKN' then
    cbbTaxpayerType.ItemIndex := 0
  else if Table.Taxpayertype = 'VKN' then
    cbbTaxpayerType.ItemIndex := 1;
  cbbTaxpayerTypeChange(cbbTaxpayerType);

  edtTaxAuthority.Text := Table.TaxAuthority;
  edtTaxNo.Text := Table.TaxNo;
  edtTaxpayerName.Text := Table.TaxpayerName;
  edtTaxpayerSurname.Text := Table.TaxpayerSurname;

  if not Assigned(Table.SysAddress) then
    Table.SysAddress := TSysAddress.Create;

  edtWeb.Text := Table.SysAddress.Web;
  edtEmail.Text := Table.SysAddress.Email;
  if Assigned(Table.SysAddress.SysCity) then
  begin
    edtSysCityId.Text := Table.SysAddress.SysCity.CityName;
    edtCountryName.Text := Table.SysAddress.SysCity.SysCountry.CountryName;
  end
  else
  begin
    edtSysCityId.Text := '';
    edtCountryName.Text := '';
  end;
  edtDistrict.Text := Table.SysAddress.District;
  edtNeighborhood.Text := Table.SysAddress.Neighborhood;
  edtQuarter.Text := Table.SysAddress.Quarter;
  edtRoad.Text := Table.SysAddress.Road;
  edtStreet.Text := Table.SysAddress.Street;
  edtBuildingName.Text := Table.SysAddress.BuildingName;
  edtDoorNumber.Text := Table.SysAddress.DoorNumber;
  edtZipCode.Text := Table.SysAddress.ZipCode;

  SetColor(StrToIntDef(edtGridColor1.Text, 0), edtGridColor1);
  SetColor(StrToIntDef(edtGridColor2.Text, 0), edtGridColor2);
  SetColor(StrToIntDef(edtGridColorActive.Text, 0), edtGridColorActive);

  Table.DeserializeOtherSettings;
  edtPathStockCardImage.Text := Table.OtherSettingsObj.StockCardImagePath;
  edtPathPersonnelCardImage.Text := Table.OtherSettingsObj.PersonnelCardImagePath;
  edtPathUpdate.Text := Table.OtherSettingsObj.UpdatePath;

  UpdatePathButtons;
end;

procedure TfrmSysApplicationSetting.SetColor(color: TColor; editColor: TEdit);
begin
  editColor.Text := IntToStr(color);
  editColor.Color := color;
  editColor.thsColorActive := color;
  editColor.thsColorRequiredInput := color;
  editColor.Refresh;
end;

function TfrmSysApplicationSetting.ValidateInput(panel_groupbox_pagecontrol_tabsheet: TWinControl): Boolean;

  procedure CheckDirectory(AEdit: TEdit);
  begin
    if (AEdit.Text <> '') and not DirectoryExists(AEdit.Text) then
    begin
      pgcMain.ActivePage := tsOther;
      AEdit.SetFocus;
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TSysApplicationSetting.InvalidDirectory, 'Please select a valid directory!'));
    end;
  end;

begin
  Result := inherited ValidateInput(panel_groupbox_pagecontrol_tabsheet);
  if not Result then
    Exit;

  CheckDirectory(edtPathStockCardImage);
  CheckDirectory(edtPathPersonnelCardImage);
  CheckDirectory(edtPathUpdate);
end;

procedure TfrmSysApplicationSetting.BtnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if ValidateInput(PanelMain) then
    begin
      Table.CompanyTitle := edtCompanyTitle.Text;
      Table.Phone := edtPhone.Text;
      Table.Fax := edtFax.Text;

      Table.GridColor1 := StrToIntDef(edtGridColor1.Text, 0);
      Table.GridColor2 := StrToIntDef(edtGridColor2.Text, 0);
      Table.GridColorActive := StrToIntDef(edtGridColorActive.Text, 0);
      Table.CryptKey := edtCryptKey.Text;
      Table.ActivePeriod := StrToIntDef(edtPeriod.Text, 2000);
      Table.AppVersion := edtAppVersion.Text;

      Table.MailHost := edtMailHost.Text;
      Table.MailUser := edtMailUser.Text;
      if edtMailPassword.Text <> '' then
        Table.MailPassword := EncryptStr(edtMailPassword.Text, Table.CryptKey)
      else
        Table.MailPassword := '';
      Table.MailSmtpPort := StrToIntDef(edtMailSmtpPort.Text, 0);

      Table.SmsHost := edtSmsHost.Text;
      Table.SmsUser := edtSmsUser.Text;
      Table.SmsTitle := edtSmsTitle.Text;
      if edtSmsPassword.Text <> '' then
        Table.SmsPassword := EncryptStr(edtSmsPassword.Text, Table.CryptKey)
      else
        Table.SmsPassword := '';

      if cbbTaxpayerType.ItemIndex = Ord(TMukellefTipi.TCKN) then
        Table.Taxpayertype := 'TCKN'
      else if cbbTaxpayerType.ItemIndex = Ord(TMukellefTipi.VKN) then
        Table.Taxpayertype := 'VKN';
      Table.TaxAuthority := edtTaxAuthority.Text;
      Table.TaxNo := edtTaxNo.Text;
      Table.TaxpayerName := edtTaxpayerName.Text;
      Table.TaxpayerSurname := edtTaxpayerSurname.Text;

      if not Assigned(Table.SysAddress) then
        Table.SysAddress := TSysAddress.Create;
      Table.SysAddress.Web := edtWeb.Text;
      Table.SysAddress.EMail := edtEmail.Text;
      Table.SysAddress.District := edtDistrict.Text;
      Table.SysAddress.Neighborhood := edtNeighborhood.Text;
      Table.SysAddress.Quarter := edtQuarter.Text;
      Table.SysAddress.Road := edtRoad.Text;
      Table.SysAddress.Street := edtStreet.Text;
      Table.SysAddress.BuildingName := edtBuildingName.Text;
      Table.SysAddress.DoorNumber := edtDoorNumber.Text;
      Table.SysAddress.ZipCode := edtZipCode.Text;

      // Diğer ayarlar JSONB
      Table.OtherSettingsObj.StockCardImagePath := edtPathStockCardImage.Text;
      Table.OtherSettingsObj.PersonnelCardImagePath := edtPathPersonnelCardImage.Text;
      Table.OtherSettingsObj.UpdatePath := edtPathUpdate.Text;
      Table.SerializeOtherSettings;

      inherited;
    end;
  end
  else
  begin
    inherited;
    btnDelete.Visible := False;
  end;
end;

end.
