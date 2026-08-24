unit ufrmSysApplicationSetting;

interface

{$I Ths.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.StrUtils, System.Math, Vcl.Graphics, Vcl.Controls,
  Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.AppEvnts,
  Vcl.Menus, Vcl.Samples.Spin, REST.Json,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  ufrmBase, ufrmInputSimpleDB, SharedFormTypes,
  SysApplicationSetting, SysApplicationSetting.Service,
  SysCity.Service, SysCity, ufrmSysCities, LocalizationManager;

type
  TfrmSysApplicationSetting = class(TfrmInputSimpleDB<TSysApplicationSetting, TSysApplicationSettingService>)
    pnlMain: TPanel;
    pgcMain: TPageControl;
    tsGenel: TTabSheet;
    lblCompanyTitle: TLabel;
    edtCompanyTitle: TEdit;
    lblPhone: TLabel;
    edtPhone: TEdit;
    lblFax: TLabel;
    edtFax: TEdit;
    pnlLogo: TPanel;
    tsAdres: TTabSheet;
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
    lblCityId: TLabel;
    edtCityId: TEdit;
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
    tsServisAyarlari: TTabSheet;
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
    tsDigerAyarlar: TTabSheet;
    lblPathStockCardImage: TLabel;
    edtPathStockCardImage: TEdit;
    btnPathStockCardImage: TButton;
    lblPathPersonnelCardImage: TLabel;
    edtPathPersonnelCardImage: TEdit;
    btnPathPersonnelCardImage: TButton;
    lblPathUpdate: TLabel;
    edtPathUpdate: TEdit;
    btnPathUpdate: TButton;
    tsGorsel: TTabSheet;
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
  protected
    procedure HelperProcess(Sender: TObject);
  public
    function ValidateInput(panel_groupbox_pagecontrol_tabsheet: TWinControl = nil): Boolean; override;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormPaint(Sender: TObject);
    procedure FormShow(Sender: TObject); override;
    procedure InitializeInputCase; override;
    procedure RefreshData(); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  Ths.Globals, Ths.Constants, Ths.Utils.Images;

procedure TfrmSysApplicationSetting.InitializeInputCase;
begin
  inherited;
  edtCityId.thsInputDataType := itInteger;
end;

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

procedure TfrmSysApplicationSetting.FormPaint(Sender: TObject);
begin
  inherited;
  edtPathStockCardImage.ReadOnly := True;
  edtPathPersonnelCardImage.ReadOnly := True;
  edtPathUpdate.ReadOnly := True;

  btnPathStockCardImage.Enabled := False;
  btnPathPersonnelCardImage.Enabled := False;
  btnPathUpdate.Enabled := False;

  if (FormMode = ifmNewRecord) or (FormMode = ifmUpdate) then
  begin
    btnPathStockCardImage.Enabled := True;
    btnPathPersonnelCardImage.Enabled := True;
    btnPathUpdate.Enabled := True;
  end;
end;

procedure TfrmSysApplicationSetting.FormShow(Sender: TObject);
begin
  edtCityId.OnHelperProcess := HelperProcess;

  inherited;
  ApplyLocalization;

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
  Self.Caption := TLocalizationManager.Translate('sys_application_setting.title_singular', 'Uygulama Ayarları');
end;

procedure TfrmSysApplicationSetting.HelperProcess(Sender: TObject);
var
  LFrmCity: TfrmSysCities;
begin
  if (Sender.ClassType <> TEdit) then
    Exit;

  if (FormMode <> ifmNewRecord) and (FormMode <> ifmCopyNewRecord) and (FormMode <> ifmUpdate) then
    Exit;

  if TEdit(Sender).Name = edtCityId.Name then
  begin
    LFrmCity := TfrmSysCities.Create(TEdit(Sender), TSysCityService.Create, TSysCity.Create, True, True);
    try
      LFrmCity.ShowModal;
      if not LFrmCity.DataTransfer then
        Exit;

      if LFrmCity.CleanAndClose then
      begin
        TEdit(Sender).Clear;
        Table.Address.CityId := 0;
      end
      else
      begin
        TEdit(Sender).Text := LFrmCity.Table.CityName;
        Table.Address.CityId := LFrmCity.Table.Id;
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

//  edtWeb.Text := Table.Address.Web;
//  edtEmail.Text := Table.Address.EMail;
//  edtCountryName.Text := Table.Address.City.Country.CountryName;
//  edtDistrict.Text := Table.Address.District;
//  edtNeighborhood.Text := Table.Address.Neighborhood;
//  edtQuarter.Text := Table.Address.Quarter;
//  edtRoad.Text := Table.Address.Road;
//  edtStreet.Text := Table.Address.Street;
//  edtBuildingName.Text := Table.Address.BuildingName;
//  edtDoorNumber.Text := Table.Address.DoorNumber;
//  edtZipCode.Text := Table.Address.ZipCode;

  SetColor(StrToIntDef(edtGridColor1.Text, 0), edtGridColor1);
  SetColor(StrToIntDef(edtGridColor2.Text, 0), edtGridColor2);
  SetColor(StrToIntDef(edtGridColorActive.Text, 0), edtGridColorActive);

  Table.DeserializeOtherSettings;
  edtPathStockCardImage.Text := Table.OtherSettingsObj.StockCardImagePath;
  edtPathPersonnelCardImage.Text := Table.OtherSettingsObj.PersonnelCardImagePath;
  edtPathUpdate.Text := Table.OtherSettingsObj.UpdatePath;

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
begin
  Result := inherited ValidateInput(panel_groupbox_pagecontrol_tabsheet);

  if (edtPathStockCardImage.Text <> '') and not DirectoryExists(edtPathStockCardImage.Text) then
  begin
    pgcMain.ActivePage := tsDigerAyarlar;
    edtPathStockCardImage.SetFocus;
    raise Exception.Create(Trim('Lütfen geçerli bir dizin seçin!'));
  end;

  if (edtPathPersonnelCardImage.Text <> '') and not DirectoryExists(edtPathPersonnelCardImage.Text) then
  begin
    pgcMain.ActivePage := tsDigerAyarlar;
    edtPathPersonnelCardImage.SetFocus;
    raise Exception.Create(Trim('Lütfen geçerli bir dizin seçin!'));
  end;

  if (edtPathUpdate.Text <> '') and not DirectoryExists(edtPathUpdate.Text) then
  begin
    pgcMain.ActivePage := tsDigerAyarlar;
    edtPathUpdate.SetFocus;
    raise Exception.Create(Trim('Lütfen geçerli bir dizin seçin!'));
  end;
end;

procedure TfrmSysApplicationSetting.BtnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if ValidateInput(pgcMain) then
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
      Table.MailSmtpPort := StrToInt(edtMailSmtpPort.Text);

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

      Table.Address.Web := edtWeb.Text;
      Table.Address.EMail := edtEmail.Text;
      Table.Address.District := edtDistrict.Text;
      Table.Address.Neighborhood := edtNeighborhood.Text;
      Table.Address.Quarter := edtQuarter.Text;
      Table.Address.Road := edtRoad.Text;
      Table.Address.Street := edtStreet.Text;
      Table.Address.BuildingName := edtBuildingName.Text;
      Table.Address.DoorNumber := edtDoorNumber.Text;
      Table.Address.ZipCode := edtZipCode.Text;

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
