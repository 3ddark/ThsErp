unit ufrmSysApplicationSetting;

interface

{$I Ths.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.StrUtils, System.Math, Vcl.Graphics, Vcl.Controls,
  Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.AppEvnts,
  Vcl.Menus, Vcl.Samples.Spin, Vcl.Imaging.pngimage, Vcl.Imaging.jpeg, REST.Json,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  ufrmBase, ufrmInputSimpleDB, SharedFormTypes,
  SysApplicationSetting, SysApplicationSetting.Service,
  SysCity.Service, SysCity, ufrmSysCities,
  SysCountry.Service, SysCountry, ufrmSysCountries,
  SysRegion.Service, SysRegion, ufrmSysRegions;

type
  TfrmSysApplicationSetting = class(TfrmInputSimpleDB<TSysApplicationSetting, TSysApplicationSettingService>)
    pnlMain: TPanel;
    pgcMain: TPageControl;
    tsMain: TTabSheet;
    lblcompany_title: TLabel;
    lblphone: TLabel;
    lblfax: TLabel;
    edtcompany_title: TEdit;
    edtphone: TEdit;
    edtfax: TEdit;
    tsservis_ayarlari: TTabSheet;
    lblmail_host: TLabel;
    edtmail_host: TEdit;
    lblmail_user: TLabel;
    edtmail_user: TEdit;
    lblmail_password: TLabel;
    edtmail_password: TEdit;
    lblmail_smtp_port: TLabel;
    edtmail_smtp_port: TEdit;
    tsadres: TTabSheet;
    lbltax_authority: TLabel;
    edttax_authority: TEdit;
    lbltax_no: TLabel;
    edttax_no: TEdit;
    lblweb: TLabel;
    edtweb: TEdit;
    lblemail: TLabel;
    edtemail: TEdit;
    lblulke_adi: TLabel;
    lblsehir_id: TLabel;
    edtsehir_id: TEdit;
    lblilce: TLabel;
    edtilce: TEdit;
    lblmahalle: TLabel;
    edtmahalle: TEdit;
    lblsokak: TLabel;
    edtsokak: TEdit;
    lblbina_adi: TLabel;
    edtbina_adi: TEdit;
    lblkapi_no: TLabel;
    edtkapi_no: TEdit;
    lblposta_kodu: TLabel;
    edtposta_kodu: TEdit;
    edtulke_adi: TEdit;
    lblsms_host: TLabel;
    lblsms_user: TLabel;
    lblsms_password: TLabel;
    lblsms_title: TLabel;
    edtsms_host: TEdit;
    edtsms_user: TEdit;
    edtsms_password: TEdit;
    edtsms_title: TEdit;
    tsdiger: TTabSheet;
    lblpath_stock_card_image: TLabel;
    lblpath_update: TLabel;
    edtpath_stock_card_image: TEdit;
    btnpath_stock_card_image: TButton;
    edtpath_update: TEdit;
    btnpath_update: TButton;
    tsgorsel: TTabSheet;
    edtcrypt_key: TEdit;
    edtapp_version: TEdit;
    edtdonem: TEdit;
    edtgrid_color_active: TEdit;
    edtgrid_color_2: TEdit;
    edtgrid_color_1: TEdit;
    lblapp_version: TLabel;
    lblperiod: TLabel;
    lblcrypt_key: TLabel;
    lblgrid_color_active: TLabel;
    lblgrid_color_2: TLabel;
    lblgrid_color_1: TLabel;
    lblsemt: TLabel;
    edtsemt: TEdit;
    lblcadde: TLabel;
    edtcadde: TEdit;
    lblpath_personel_karti_resim: TLabel;
    edtpath_personel_karti_resim: TEdit;
    btnpath_personel_karti_resim: TButton;
    pnllogo: TPanel;
    imglogo: TImage;
    lblmukellef_tipi: TLabel;
    cbbmukellef_tipi: TComboBox;
    lblmukellef_adi: TLabel;
    lblmukellef_soyadi: TLabel;
    edtmukellef_adi: TEdit;
    edtmukellef_soyadi: TEdit;
    procedure imglogoDblClick(Sender: TObject);
    procedure edtgrid_color_1DblClick(Sender: TObject);
    procedure edtgrid_color_2DblClick(Sender: TObject);
    procedure edtgrid_color_activeDblClick(Sender: TObject);
    procedure edtgrid_color_1Exit(Sender: TObject);
    procedure edtgrid_color_2Exit(Sender: TObject);
    procedure edtgrid_color_activeExit(Sender: TObject);
    procedure btnpath_stock_card_imageClick(Sender: TObject);
    procedure btnpath_updateClick(Sender: TObject);
    procedure btnpath_personel_karti_resimClick(Sender: TObject);
    procedure cbbmukellef_tipiChange(Sender: TObject);
  private
    procedure SetColor(color: TColor; editColor: TEdit);
  protected
    procedure HelperProcess(Sender: TObject);
    function ValidateInput(panel_groupbox_pagecontrol_tabsheet: TWinControl = nil): Boolean; override;
  published
    procedure btnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormPaint(Sender: TObject);
    procedure FormShow(Sender: TObject); override;
    procedure RefreshData(); override;
  end;

implementation

uses
  Ths.Globals, Ths.Constants, Ths.Utils.Images;

{$R *.dfm}

procedure TfrmSysApplicationSetting.btnpath_stock_card_imageClick(Sender: TObject);
begin
  edtpath_stock_card_image.Text := GetDialogDirectory;
end;

procedure TfrmSysApplicationSetting.cbbmukellef_tipiChange(Sender: TObject);
begin
  inherited;
  if cbbmukellef_tipi.ItemIndex = Ord(TMukellefTipi.TCKN) then
  begin
    edttax_no.MaxLength := 11;
    edttax_authority.Clear;
    lbltax_authority.Visible := False;
    edttax_authority.Visible := False;

    lblmukellef_adi.Visible := True;
    edtmukellef_adi.Visible := True;
    lblmukellef_soyadi.Visible := True;
    edtmukellef_soyadi.Visible := True;
  end
  else if cbbmukellef_tipi.ItemIndex = Ord(TMukellefTipi.VKN) then
  begin
    edttax_no.MaxLength := 10;
    lbltax_authority.Visible := True;
    edttax_authority.Visible := True;

    edtmukellef_adi.Clear;
    lblmukellef_adi.Visible := False;
    edtmukellef_adi.Visible := False;
    edtmukellef_soyadi.Clear;
    lblmukellef_soyadi.Visible := False;
    edtmukellef_soyadi.Visible := False;
  end;
end;

procedure TfrmSysApplicationSetting.btnpath_updateClick(Sender: TObject);
begin
  edtpath_update.Text := GetDialogDirectory;
end;

procedure TfrmSysApplicationSetting.btnpath_personel_karti_resimClick(Sender: TObject);
begin
  edtpath_personel_karti_resim.Text := GetDialogDirectory;
end;

procedure TfrmSysApplicationSetting.edtgrid_color_1DblClick(Sender: TObject);
begin
  if (FormMode = ifmUpdate) or (FormMode = ifmNewRecord) then
    SetColor(GetDialogColor(StrToIntDef(edtgrid_color_1.Text, 0)), edtgrid_color_1);
end;

procedure TfrmSysApplicationSetting.edtgrid_color_1Exit(Sender: TObject);
begin
  inherited;
  SetColor(StrToIntDef(edtgrid_color_1.Text, 0), edtgrid_color_1);
  edtgrid_color_1.Refresh;
end;

procedure TfrmSysApplicationSetting.edtgrid_color_2DblClick(Sender: TObject);
begin
  if (FormMode = ifmUpdate) or (FormMode = ifmNewRecord) then
    SetColor(GetDialogColor(StrToIntDef(edtgrid_color_2.Text, 0)), edtgrid_color_2);

end;

procedure TfrmSysApplicationSetting.edtgrid_color_2Exit(Sender: TObject);
begin
  inherited;
  SetColor(StrToIntDef(edtgrid_color_2.Text, 0), edtgrid_color_2);
  edtgrid_color_2.Refresh;
end;

procedure TfrmSysApplicationSetting.edtgrid_color_activeDblClick(Sender: TObject);
begin
  if (FormMode = ifmUpdate) or (FormMode = ifmNewRecord) then
    SetColor(GetDialogColor(StrToIntDef(edtgrid_color_active.Text, 0)), edtgrid_color_active);
end;

procedure TfrmSysApplicationSetting.edtgrid_color_activeExit(Sender: TObject);
begin
  inherited;
  SetColor(StrToIntDef(edtgrid_color_active.Text, 0), edtgrid_color_active);
  edtgrid_color_active.Repaint;
end;

procedure TfrmSysApplicationSetting.FormCreate(Sender: TObject);
begin
  inherited;

  edtcompany_title.CharCase := TEditCharCase.ecNormal;
  edtweb.CharCase := TEditCharCase.ecNormal;
  edtemail.CharCase := TEditCharCase.ecNormal;
  edtmail_host.CharCase := TEditCharCase.ecNormal;
  edtmail_user.CharCase := TEditCharCase.ecNormal;
  edtmail_password.CharCase := TEditCharCase.ecNormal;
  edtapp_version.CharCase := TEditCharCase.ecNormal;

  edtsms_host.CharCase := TEditCharCase.ecNormal;
  edtsms_user.CharCase := TEditCharCase.ecNormal;
  edtsms_password.CharCase := TEditCharCase.ecNormal;
  edtsms_title.CharCase := TEditCharCase.ecNormal;

  edtpath_stock_card_image.CharCase := TEditCharCase.ecNormal;
  edtpath_personel_karti_resim.CharCase := TEditCharCase.ecNormal;
  edtpath_update.CharCase := TEditCharCase.ecNormal;

  edtcrypt_key.CharCase := TEditCharCase.ecNormal;

  cbbmukellef_tipi.CharCase := TEditCharCase.ecNormal;
  cbbmukellef_tipi.Clear;
  cbbmukellef_tipi.Items.Add('TC Kimlik No(TCKN)');
  cbbmukellef_tipi.Items.Add('Vergi Kimlik No(VKN)');
  cbbmukellef_tipi.ItemIndex := 0;
  cbbmukellef_tipiChange(cbbmukellef_tipi)
end;

procedure TfrmSysApplicationSetting.FormPaint(Sender: TObject);
begin
  inherited;
  edtpath_stock_card_image.ReadOnly := True;
  edtpath_personel_karti_resim.ReadOnly := True;
  edtpath_update.ReadOnly := True;

  btnpath_stock_card_image.Enabled := False;
  btnpath_personel_karti_resim.Enabled := False;
  btnpath_update.Enabled := False;

  if (FormMode = ifmNewRecord) or (FormMode = ifmUpdate) then
  begin
    btnpath_stock_card_image.Enabled := True;
    btnpath_personel_karti_resim.Enabled := True;
    btnpath_update.Enabled := True;
  end;
end;

procedure TfrmSysApplicationSetting.FormShow(Sender: TObject);
begin
  edtsehir_id.OnHelperProcess := HelperProcess;

  inherited;

  edtulke_adi.ReadOnly := True;
  edtilce.CharCase := ecUpperCase;
  edtmahalle.CharCase := ecUpperCase;
  edtsemt.CharCase := ecUpperCase;
  edtcadde.CharCase := ecUpperCase;
  edtsokak.CharCase := ecUpperCase;
  edtbina_adi.CharCase := ecUpperCase;
  edtkapi_no.CharCase := ecUpperCase;
  edtposta_kodu.CharCase := ecUpperCase;
end;

procedure TfrmSysApplicationSetting.HelperProcess(Sender: TObject);
var
  LFrmCity: TfrmSysCities;
begin
  if (Sender.ClassType <> TEdit) then
    Exit;

  if (FormMode <> ifmNewRecord) and (FormMode <> ifmCopyNewRecord) and (FormMode <> ifmUpdate) then
    Exit;

  if TEdit(Sender).Name = edtsehir_id.Name then
  begin
    LFrmCity := TfrmSysCities.Create(TEdit(Sender), TSysCityService.Create, TSysCity.Create, True, True);
    try
      LFrmCity.ShowModal;
      if not LFrmCity.DataAktar then
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
  end
end;

procedure TfrmSysApplicationSetting.imglogoDblClick(Sender: TObject);
var
  LFileName: string;
begin
  if (FormMode = ifmUpdate) or (FormMode = ifmNewRecord) then
  begin
    if CustomMsgDlg('Mevcut logoyu kayıt etmek istiyor musun?', mtConfirmation, mbYesNo, ['Evet Kaydet', 'Hayır Yenisini Yükle'], mbNo, 'Kullanıcı Onayı') = mrYes then
    begin
      imglogo.Picture.SaveToFile(GetDialogSave('', FILE_FILTER_IMAGE, ''));
    end
    else
    begin
      GetDialogOpen(FILE_FILTER_IMAGE, LFileName);
      if (LFileName <> '') and FileExists(LFileName) then
        TImageProcess.LoadImageFromFile(LFileName, imglogo, 320, 240);
    end;
  end;
end;

procedure TfrmSysApplicationSetting.RefreshData;
begin
  edtcompany_title.Text := Table.CompanyTitle;
  edtphone.Text := Table.Phone;
  edtfax.Text := Table.Fax;

  TImageProcess.LoadImageFromDB(Table.Logo, imglogo);

  edtgrid_color_1.Text := Table.GridColor1.ToString;
  edtgrid_color_2.Text := Table.GridColor2.ToString;
  edtgrid_color_active.Text := Table.GridColorActive.ToString;
  edtcrypt_key.Text := Table.CryptKey;
  edtdonem.Text := Table.ActivePeriod.ToString;
  edtapp_version.Text := Table.AppVersion;

  edtmail_host.Text := Table.MailHost;
  edtmail_user.Text := Table.MailUser;
  if FormMode = ifmUpdate then
  begin
    if Table.MailPassword <> '' then
      edtmail_password.Text := DecryptStr(Table.MailPassword, Table.CryptKey)
  end
  else
    edtmail_password.Text := Table.MailPassword;
  edtmail_smtp_port.Text := Table.MailSmtpPort.ToString;
  edtsms_host.Text := Table.SmsHost;
  edtsms_user.Text := Table.SmsUser;
  if FormMode = ifmUpdate then
  begin
    if Table.SmsPassword <> '' then
      edtsms_password.Text := DecryptStr(Table.SmsPassword, Table.CryptKey)
  end
  else
    edtsms_password.Text := Table.SmsPassword;
  edtsms_title.Text := Table.SmsTitle;

  if Table.Taxpayertype = 'TCKN' then
    cbbmukellef_tipi.ItemIndex := 0
  else if Table.Taxpayertype = 'VKN' then
    cbbmukellef_tipi.ItemIndex := 1;
  cbbmukellef_tipiChange(cbbmukellef_tipi);

  edttax_authority.Text := Table.TaxAuthority;
  edttax_no.Text := Table.TaxNo;
  edtmukellef_adi.Text := Table.TaxpayerName;
  edtmukellef_soyadi.Text := Table.TaxpayerSurname;

  edtweb.Text := Table.Address.Web;
  edtemail.Text := Table.Address.Email;
//  edtulke_adi.Text := Table.Address.UlkeAdi.AsString;
//  edtsehir_id.Text := Table.Address.CityName;
  edtilce.Text := Table.Address.District;
  edtmahalle.Text := Table.Address.Neighborhood;
  edtsemt.Text := Table.Address.Quarter;
  edtcadde.Text := Table.Address.Road;
  edtsokak.Text := Table.Address.Street;
  edtbina_adi.Text := Table.Address.BuildingName;
  edtkapi_no.Text := Table.Address.DoorNumber;
  edtposta_kodu.Text := Table.Address.ZipCode;

  SetColor(StrToIntDef(edtgrid_color_1.Text, 0), edtgrid_color_1);
  SetColor(StrToIntDef(edtgrid_color_2.Text, 0), edtgrid_color_2);
  SetColor(StrToIntDef(edtgrid_color_active.Text, 0), edtgrid_color_active);

  Table.DeserializeOtherSettings;
  edtpath_stock_card_image.Text := Table.OtherSettingsObj.StockCardImagePath;
  edtpath_personel_karti_resim.Text := Table.OtherSettingsObj.PersonnelCardImagePath;
  edtpath_update.Text := Table.OtherSettingsObj.UpdatePath;

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

  if (edtpath_stock_card_image.Text <> '') and not DirectoryExists(edtpath_stock_card_image.Text) then
  begin
    pgcMain.ActivePage := tsdiger;
    edtpath_stock_card_image.SetFocus;
    raise Exception.Create(Trim('Lütfen geçerli bir dizin seçin!'));
  end;

  if (edtpath_personel_karti_resim.Text <> '') and not DirectoryExists(edtpath_personel_karti_resim.Text) then
  begin
    pgcMain.ActivePage := tsdiger;
    edtpath_personel_karti_resim.SetFocus;
    raise Exception.Create(Trim('Lütfen geçerli bir dizin seçin!'));
  end;

  if (edtpath_update.Text <> '') and not DirectoryExists(edtpath_update.Text) then
  begin
    pgcMain.ActivePage := tsdiger;
    edtpath_update.SetFocus;
    raise Exception.Create(Trim('Lütfen geçerli bir dizin seçin!'));
  end;
end;

procedure TfrmSysApplicationSetting.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if ValidateInput(pgcMain) then
    begin
      Table.CompanyTitle := edtcompany_title.Text;
      Table.Phone := edtphone.Text;
      Table.Fax := edtfax.Text;

      TImageProcess.setValueFromImage(Table.Logo, imglogo);

      Table.GridColor1 := StrToIntDef(edtgrid_color_1.Text, 0);
      Table.GridColor2 := StrToIntDef(edtgrid_color_2.Text, 0);
      Table.GridColorActive := StrToIntDef(edtgrid_color_active.Text, 0);
      Table.CryptKey := edtcrypt_key.Text;
      Table.ActivePeriod := StrToIntDef(edtdonem.Text, 2000);
      Table.AppVersion := edtapp_version.Text;

      Table.MailHost := edtmail_host.Text;
      Table.MailUser := edtmail_user.Text;
      if edtmail_password.Text <> '' then
        Table.MailPassword := EncryptStr(edtmail_password.Text, Table.CryptKey)
      else
        Table.MailPassword := '';
      Table.MailSmtpPort := StrToInt(edtmail_smtp_port.Text);

      Table.SmsHost := edtsms_host.Text;
      Table.SmsUser := edtsms_user.Text;
      Table.SmsTitle := edtsms_title.Text;
      if edtsms_password.Text <> '' then
        Table.SmsPassword := EncryptStr(edtsms_password.Text, Table.CryptKey)
      else
        Table.SmsPassword := '';

      if cbbmukellef_tipi.ItemIndex = Ord(TMukellefTipi.TCKN) then
        Table.Taxpayertype := 'TCKN'
      else if cbbmukellef_tipi.ItemIndex = Ord(TMukellefTipi.VKN) then
        Table.Taxpayertype := 'VKN';
      Table.TaxAuthority := edttax_authority.Text;
      Table.TaxNo := edttax_no.Text;
      Table.TaxpayerName := edtmukellef_adi.Text;
      Table.TaxpayerSurname := edtmukellef_soyadi.Text;

      Table.Address.Web := edtweb.Text;
      Table.Address.EMail := edtemail.Text;
      Table.Address.District := edtilce.Text;
      Table.Address.Neighborhood := edtmahalle.Text;
      Table.Address.Quarter := edtsemt.Text;
      Table.Address.Road := edtcadde.Text;
      Table.Address.Street := edtsokak.Text;
      Table.Address.BuildingName := edtbina_adi.Text;
      Table.Address.DoorNumber := edtkapi_no.Text;
      Table.Address.ZipCode := edtposta_kodu.Text;

      // Diğer ayarlar JSONB
      Table.OtherSettingsObj.StockCardImagePath := edtpath_stock_card_image.Text;
      Table.OtherSettingsObj.PersonnelCardImagePath := edtpath_personel_karti_resim.Text;
      Table.OtherSettingsObj.UpdatePath := edtpath_update.Text;
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
