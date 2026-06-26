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
    lblunvan: TLabel;
    lbltelefon: TLabel;
    lblfaks: TLabel;
    edtunvan: TEdit;
    edttelefon: TEdit;
    edtfaks: TEdit;
    tsservis_ayarlari: TTabSheet;
    lblmail_sunucu: TLabel;
    edtmail_sunucu: TEdit;
    lblmail_kullanici: TLabel;
    edtmail_kullanici: TEdit;
    lblmail_sifre: TLabel;
    edtmail_sifre: TEdit;
    lblmail_smtp_port: TLabel;
    edtmail_smtp_port: TEdit;
    tsadres: TTabSheet;
    lblvergi_dairesi: TLabel;
    edtvergi_dairesi: TEdit;
    lblvergi_numarasi: TLabel;
    edtvergi_numarasi: TEdit;
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
    lblsms_sunucu: TLabel;
    lblsms_kullanici: TLabel;
    lblsms_sifre: TLabel;
    lblsms_baslik: TLabel;
    edtsms_sunucu: TEdit;
    edtsms_kullanici: TEdit;
    edtsms_sifre: TEdit;
    edtsms_baslik: TEdit;
    tsdiger: TTabSheet;
    lblpath_stok_karti_resim: TLabel;
    lblpath_guncelleme: TLabel;
    edtpath_stok_karti_resim: TEdit;
    btnpath_stok_karti_resim: TButton;
    edtpath_guncelleme: TEdit;
    btnpath_guncelleme: TButton;
    tsgorsel: TTabSheet;
    edtcrypt_key: TEdit;
    edtversiyon: TEdit;
    edtdonem: TEdit;
    edtgrid_renk_aktif: TEdit;
    edtgrid_renk_2: TEdit;
    edtgrid_renk_1: TEdit;
    lblversiyon: TLabel;
    lbldonem: TLabel;
    lblcrypt_key: TLabel;
    lblgrid_renk_aktif: TLabel;
    lblgrid_renk_2: TLabel;
    lblgrid_renk_1: TLabel;
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
    procedure edtgrid_renk_1DblClick(Sender: TObject);
    procedure edtgrid_renk_2DblClick(Sender: TObject);
    procedure edtgrid_renk_aktifDblClick(Sender: TObject);
    procedure edtgrid_renk_1Exit(Sender: TObject);
    procedure edtgrid_renk_2Exit(Sender: TObject);
    procedure edtgrid_renk_aktifExit(Sender: TObject);
    procedure btnpath_stok_karti_resimClick(Sender: TObject);
    procedure btnpath_guncellemeClick(Sender: TObject);
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

procedure TfrmSysApplicationSetting.btnpath_stok_karti_resimClick(Sender: TObject);
begin
  edtpath_stok_karti_resim.Text := GetDialogDirectory;
end;

procedure TfrmSysApplicationSetting.cbbmukellef_tipiChange(Sender: TObject);
begin
  inherited;
  if cbbmukellef_tipi.ItemIndex = Ord(TMukellefTipi.TCKN) then
  begin
    edtvergi_numarasi.MaxLength := 11;
    edtvergi_dairesi.Clear;
    lblvergi_dairesi.Visible := False;
    edtvergi_dairesi.Visible := False;

    lblmukellef_adi.Visible := True;
    edtmukellef_adi.Visible := True;
    lblmukellef_soyadi.Visible := True;
    edtmukellef_soyadi.Visible := True;
  end
  else if cbbmukellef_tipi.ItemIndex = Ord(TMukellefTipi.VKN) then
  begin
    edtvergi_numarasi.MaxLength := 10;
    lblvergi_dairesi.Visible := True;
    edtvergi_dairesi.Visible := True;

    edtmukellef_adi.Clear;
    lblmukellef_adi.Visible := False;
    edtmukellef_adi.Visible := False;
    edtmukellef_soyadi.Clear;
    lblmukellef_soyadi.Visible := False;
    edtmukellef_soyadi.Visible := False;
  end;
end;

procedure TfrmSysApplicationSetting.btnpath_guncellemeClick(Sender: TObject);
begin
  edtpath_guncelleme.Text := GetDialogDirectory;
end;

procedure TfrmSysApplicationSetting.btnpath_personel_karti_resimClick(Sender: TObject);
begin
  edtpath_personel_karti_resim.Text := GetDialogDirectory;
end;

procedure TfrmSysApplicationSetting.edtgrid_renk_1DblClick(Sender: TObject);
begin
  if (FormMode = ifmUpdate) or (FormMode = ifmNewRecord) then
    SetColor(GetDialogColor(StrToIntDef(edtgrid_renk_1.Text, 0)), edtgrid_renk_1);
end;

procedure TfrmSysApplicationSetting.edtgrid_renk_1Exit(Sender: TObject);
begin
  inherited;
  SetColor(StrToIntDef(edtgrid_renk_1.Text, 0), edtgrid_renk_1);
  edtgrid_renk_1.Refresh;
end;

procedure TfrmSysApplicationSetting.edtgrid_renk_2DblClick(Sender: TObject);
begin
  if (FormMode = ifmUpdate) or (FormMode = ifmNewRecord) then
    SetColor(GetDialogColor(StrToIntDef(edtgrid_renk_2.Text, 0)), edtgrid_renk_2);

end;

procedure TfrmSysApplicationSetting.edtgrid_renk_2Exit(Sender: TObject);
begin
  inherited;
  SetColor(StrToIntDef(edtgrid_renk_2.Text, 0), edtgrid_renk_2);
  edtgrid_renk_2.Refresh;
end;

procedure TfrmSysApplicationSetting.edtgrid_renk_aktifDblClick(Sender: TObject);
begin
  if (FormMode = ifmUpdate) or (FormMode = ifmNewRecord) then
    SetColor(GetDialogColor(StrToIntDef(edtgrid_renk_aktif.Text, 0)), edtgrid_renk_aktif);
end;

procedure TfrmSysApplicationSetting.edtgrid_renk_aktifExit(Sender: TObject);
begin
  inherited;
  SetColor(StrToIntDef(edtgrid_renk_aktif.Text, 0), edtgrid_renk_aktif);
  edtgrid_renk_aktif.Repaint;
end;

procedure TfrmSysApplicationSetting.FormCreate(Sender: TObject);
begin
  inherited;

  edtunvan.CharCase := TEditCharCase.ecNormal;
  edtweb.CharCase := TEditCharCase.ecNormal;
  edtemail.CharCase := TEditCharCase.ecNormal;
  edtmail_sunucu.CharCase := TEditCharCase.ecNormal;
  edtmail_kullanici.CharCase := TEditCharCase.ecNormal;
  edtmail_sifre.CharCase := TEditCharCase.ecNormal;
  edtversiyon.CharCase := TEditCharCase.ecNormal;

  edtsms_sunucu.CharCase := TEditCharCase.ecNormal;
  edtsms_kullanici.CharCase := TEditCharCase.ecNormal;
  edtsms_sifre.CharCase := TEditCharCase.ecNormal;
  edtsms_baslik.CharCase := TEditCharCase.ecNormal;

  edtpath_stok_karti_resim.CharCase := TEditCharCase.ecNormal;
  edtpath_personel_karti_resim.CharCase := TEditCharCase.ecNormal;
  edtpath_guncelleme.CharCase := TEditCharCase.ecNormal;

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
  edtpath_stok_karti_resim.ReadOnly := True;
  edtpath_personel_karti_resim.ReadOnly := True;
  edtpath_guncelleme.ReadOnly := True;

  btnpath_stok_karti_resim.Enabled := False;
  btnpath_personel_karti_resim.Enabled := False;
  btnpath_guncelleme.Enabled := False;

  if (FormMode = ifmNewRecord) or (FormMode = ifmUpdate) then
  begin
    btnpath_stok_karti_resim.Enabled := True;
    btnpath_personel_karti_resim.Enabled := True;
    btnpath_guncelleme.Enabled := True;
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
  edtunvan.Text := Table.CompanyTitle;
  edttelefon.Text := Table.Phone;
  edtfaks.Text := Table.Fax;

  TImageProcess.LoadImageFromDB(Table.Logo, imglogo);

  edtgrid_renk_1.Text := Table.GridColor1.ToString;
  edtgrid_renk_2.Text := Table.GridColor2.ToString;
  edtgrid_renk_aktif.Text := Table.GridColorActive.ToString;
  edtcrypt_key.Text := Table.CryptKey;
  edtdonem.Text := Table.ActivePeriod.ToString;
  edtversiyon.Text := Table.AppVersion;

  edtmail_sunucu.Text := Table.MailHost;
  edtmail_kullanici.Text := Table.MailUser;
  if FormMode = ifmUpdate then
  begin
    if Table.MailPassword <> '' then
      edtmail_sifre.Text := DecryptStr(Table.MailPassword, Table.CryptKey)
  end
  else
    edtmail_sifre.Text := Table.MailPassword;
  edtmail_smtp_port.Text := Table.MailSmtpPort.ToString;
  edtsms_sunucu.Text := Table.SmsHost;
  edtsms_kullanici.Text := Table.SmsUser;
  if FormMode = ifmUpdate then
  begin
    if Table.SmsPassword <> '' then
      edtsms_sifre.Text := DecryptStr(Table.SmsPassword, Table.CryptKey)
  end
  else
    edtsms_sifre.Text := Table.SmsPassword;
  edtsms_baslik.Text := Table.SmsTitle;

  if Table.Taxpayertype = 'TCKN' then
    cbbmukellef_tipi.ItemIndex := 0
  else if Table.Taxpayertype = 'VKN' then
    cbbmukellef_tipi.ItemIndex := 1;
  cbbmukellef_tipiChange(cbbmukellef_tipi);

  edtvergi_dairesi.Text := Table.TaxAuthority;
  edtvergi_numarasi.Text := Table.TaxNo;
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

  SetColor(StrToIntDef(edtgrid_renk_1.Text, 0), edtgrid_renk_1);
  SetColor(StrToIntDef(edtgrid_renk_2.Text, 0), edtgrid_renk_2);
  SetColor(StrToIntDef(edtgrid_renk_aktif.Text, 0), edtgrid_renk_aktif);

//  edtpath_stok_karti_resim.Text := Table.OtherSettings.PathStokKartiResim;
//  edtpath_personel_karti_resim.Text := TSysUygulamaAyari(Table).DigerAyarlarJSon.PathPersonelKartiResim;
//  edtpath_guncelleme.Text := TSysUygulamaAyari(Table).DigerAyarlarJSon.PathUpdate;
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

  if (edtpath_stok_karti_resim.Text <> '') and not DirectoryExists(edtpath_stok_karti_resim.Text) then
  begin
    pgcMain.ActivePage := tsdiger;
    edtpath_stok_karti_resim.SetFocus;
    raise Exception.Create(Trim('Lütfen geçerli bir dizin seçin!'));
  end;

  if (edtpath_personel_karti_resim.Text <> '') and not DirectoryExists(edtpath_personel_karti_resim.Text) then
  begin
    pgcMain.ActivePage := tsdiger;
    edtpath_personel_karti_resim.SetFocus;
    raise Exception.Create(Trim('Lütfen geçerli bir dizin seçin!'));
  end;

  if (edtpath_guncelleme.Text <> '') and not DirectoryExists(edtpath_guncelleme.Text) then
  begin
    pgcMain.ActivePage := tsdiger;
    edtpath_guncelleme.SetFocus;
    raise Exception.Create(Trim('Lütfen geçerli bir dizin seçin!'));
  end;
end;

procedure TfrmSysApplicationSetting.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if ValidateInput(pgcMain) then
    begin
      Table.CompanyTitle := edtunvan.Text;
      Table.Phone := edttelefon.Text;
      Table.Fax := edtfaks.Text;

      TImageProcess.setValueFromImage(Table.Logo, imglogo);

      Table.GridColor1 := StrToIntDef(edtgrid_renk_1.Text, 0);
      Table.GridColor2 := StrToIntDef(edtgrid_renk_2.Text, 0);
      Table.GridColorActive := StrToIntDef(edtgrid_renk_aktif.Text, 0);
      Table.CryptKey := edtcrypt_key.Text;
      Table.ActivePeriod := StrToIntDef(edtdonem.Text, 2000);
      Table.AppVersion := edtversiyon.Text;

      Table.MailHost := edtmail_sunucu.Text;
      Table.MailUser := edtmail_kullanici.Text;
      if edtmail_sifre.Text <> '' then
        Table.MailPassword := EncryptStr(edtmail_sifre.Text, Table.CryptKey)
      else
        Table.MailPassword := '';
      Table.MailSmtpPort := StrToInt(edtmail_smtp_port.Text);

      Table.SmsHost := edtsms_sunucu.Text;
      Table.SmsUser := edtsms_kullanici.Text;
      Table.SmsTitle := edtsms_baslik.Text;
      if edtsms_sifre.Text <> '' then
        Table.SmsPassword := EncryptStr(edtsms_sifre.Text, Table.CryptKey)
      else
        Table.SmsPassword := '';

      if cbbmukellef_tipi.ItemIndex = Ord(TMukellefTipi.TCKN) then
        Table.Taxpayertype := 'TCKN'
      else if cbbmukellef_tipi.ItemIndex = Ord(TMukellefTipi.VKN) then
        Table.Taxpayertype := 'VKN';
      Table.TaxAuthority := edtvergi_dairesi.Text;
      Table.TaxNo := edtvergi_numarasi.Text;
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

//      Table.OtherSettings.PathStokKartiResim := edtpath_stok_karti_resim.Text;
//      Table.OtherSettings.PathPersonelKartiResim := edtpath_personel_karti_resim.Text;
//      Table.OtherSettings.PathUpdate := edtpath_guncelleme.Text;

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
