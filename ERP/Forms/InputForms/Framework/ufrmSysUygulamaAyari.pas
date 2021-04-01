unit ufrmSysUygulamaAyari;

interface

{$I ThsERP.inc}

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.StrUtils,
  System.Math,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.AppEvnts,
  Vcl.Menus,
  Vcl.Samples.Spin,
  Ths.Erp.Helper.BaseTypes,
  Ths.Erp.Helper.Edit,
  Ths.Erp.Helper.Memo,
  Ths.Erp.Helper.ComboBox,
  ufrmBase,
  ufrmBaseInputDB;

type
  TfrmSysUygulamaAyari = class(TfrmBaseInputDB)
    lblunvan: TLabel;
    lbltel1: TLabel;
    lbltel2: TLabel;
    lbltel3: TLabel;
    lbltel4: TLabel;
    lbltel5: TLabel;
    lblfaks1: TLabel;
    lblfaks2: TLabel;
    imglogo: TImage;
    edtunvan: TEdit;
    edttel1: TEdit;
    edttel2: TEdit;
    edttel3: TEdit;
    edttel4: TEdit;
    edttel5: TEdit;
    edtfaks1: TEdit;
    edtfaks2: TEdit;
    tsDiger: TTabSheet;
    lblgrid_color_1: TLabel;
    edtgrid_color_1: TEdit;
    lblgrid_color_2: TLabel;
    edtgrid_color_2: TEdit;
    lblgrid_color_active: TLabel;
    edtgrid_color_active: TEdit;
    lblcrypt_key: TLabel;
    secrypt_key: TSpinEdit;
    lblform_rengi: TLabel;
    edtform_rengi: TEdit;
    lbldonem: TLabel;
    edtdonem: TEdit;
    lbluygulama_lisan: TLabel;
    lblmail_host_name: TLabel;
    edtmail_host_name: TEdit;
    lblmail_host_user: TLabel;
    edtmail_host_user: TEdit;
    lblmail_host_pass: TLabel;
    edtmail_host_pass: TEdit;
    lblmail_host_smtp_port: TLabel;
    edtmail_host_smtp_port: TEdit;
    tsAdres: TTabSheet;
    lblmukellef_tipi_id: TLabel;
    chkis_kalite_form_no_kullan: TCheckBox;
    lblis_kalite_form_no_kullan: TLabel;
    edtmukellef_tipi_id: TEdit;
    lblvergi_dairesi: TLabel;
    edtvergi_dairesi: TEdit;
    lblvergi_no: TLabel;
    edtvergi_no: TEdit;
    lblmersis_no: TLabel;
    edtmersis_no: TEdit;
    lblweb_site: TLabel;
    edtweb_site: TEdit;
    lblemail: TLabel;
    edtemail: TEdit;
    lblulke_id: TLabel;
    lblsehir_id: TLabel;
    edtsehir_id: TEdit;
    lblilce: TLabel;
    edtilce: TEdit;
    lblmahalle: TLabel;
    edtmahalle: TEdit;
    lblcadde: TLabel;
    edtcadde: TEdit;
    lblsokak: TLabel;
    edtsokak: TEdit;
    lblbina_adi: TLabel;
    edtbina_adi: TEdit;
    lblkapi_no: TLabel;
    edtkapi_no: TEdit;
    lblposta_kodu: TLabel;
    edtposta_kodu: TEdit;
    edtulke_id: TEdit;
    edtuygulama_lisan: TEdit;
    lblticaret_sicil_no: TLabel;
    edtticaret_sicil_no: TEdit;
    lblsms_service_provider: TLabel;
    lblsms_user: TLabel;
    lblsms_password: TLabel;
    lblsms_title: TLabel;
    edtsms_service_provider: TEdit;
    edtsms_user: TEdit;
    edtsms_password: TEdit;
    edtsms_title: TEdit;
    lbluygulama_surum: TLabel;
    edtuygulama_surum: TEdit;
    procedure imglogoDblClick(Sender: TObject);
    procedure edtform_rengiDblClick(Sender: TObject);
    procedure edtgrid_color_1DblClick(Sender: TObject);
    procedure edtgrid_color_2DblClick(Sender: TObject);
    procedure edtgrid_color_activeDblClick(Sender: TObject);
    procedure edtform_rengiExit(Sender: TObject);
    procedure edtgrid_color_1Exit(Sender: TObject);
    procedure edtgrid_color_2Exit(Sender: TObject);
    procedure edtgrid_color_activeExit(Sender: TObject);
  private
    procedure SetColor(color: TColor; editColor: TEdit);
    procedure DrawEmptyImage();
    procedure LoadImage(pFileName: string);
  protected
    procedure HelperProcess(Sender: TObject); override;
    function ValidateInput(panel_groupbox_pagecontrol_tabsheet: TWinControl = nil): Boolean; override;
  published
    procedure btnAcceptClick(Sender: TObject);override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormPaint(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
    procedure RefreshData();override;
  end;

implementation

uses
  Ths.Erp.Database.Singleton,
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Table.SysLisan,
  Ths.Erp.Database.Table.SysUygulamaAyari,
  Ths.Erp.Database.Table.SysUlke,
  Ths.Erp.Database.Table.SysSehir,
  Ths.Erp.Database.Table.SysMukellefTipi,
  ufrmSysMukellefTipleri,
  ufrmSysSehirler,
  ufrmSysLisanlar;

{$R *.dfm}

procedure TfrmSysUygulamaAyari.DrawEmptyImage;
var
  vRightOrigin, x1, x2, y1, y2: Integer;
begin
  with imgLogo do
  begin
    vRightOrigin := Left + Width;
    Width := 320;
    Height := 240;
    Left := vRightOrigin-Width;

    Canvas.Pen.Style := psSolid;
    Canvas.Pen.Width := 1;

    Canvas.Pen.Color := clOlive;
    Canvas.Brush.Color := clOlive;
    x1 := 0;  x2 := Width;  y1 := 0;  y2 := Height;
    Canvas.Rectangle(x1, y1, x2, y2);
  end;
end;

procedure TfrmSysUygulamaAyari.edtform_rengiDblClick(Sender: TObject);
begin
  if (FormMode = ifmUpdate) or (FormMode = ifmNewRecord) then
    SetColor(GetDialogColor(StrToIntDef(edtform_rengi.Text, 0)), edtform_rengi);
end;

procedure TfrmSysUygulamaAyari.edtform_rengiExit(Sender: TObject);
begin
  inherited;
  SetColor(StrToIntDef(edtform_rengi.Text, 0), edtform_rengi);
  edtform_rengi.Refresh;
end;

procedure TfrmSysUygulamaAyari.edtgrid_color_1DblClick(Sender: TObject);
begin
  if (FormMode = ifmUpdate) or (FormMode = ifmNewRecord) then
    SetColor(GetDialogColor(StrToIntDef(edtgrid_color_1.Text, 0)), edtgrid_color_1);
end;

procedure TfrmSysUygulamaAyari.edtgrid_color_1Exit(Sender: TObject);
begin
  inherited;
  SetColor(StrToIntDef(edtgrid_color_1.Text, 0), edtgrid_color_1);
  edtgrid_color_1.Refresh;
end;

procedure TfrmSysUygulamaAyari.edtgrid_color_2DblClick(Sender: TObject);
begin
  if (FormMode = ifmUpdate) or (FormMode = ifmNewRecord) then
    SetColor(GetDialogColor(StrToIntDef(edtgrid_color_2.Text, 0)), edtgrid_color_2);
end;

procedure TfrmSysUygulamaAyari.edtgrid_color_2Exit(Sender: TObject);
begin
  inherited;
  SetColor(StrToIntDef(edtgrid_color_2.Text, 0), edtgrid_color_2);
  edtgrid_color_2.Refresh;
end;

procedure TfrmSysUygulamaAyari.edtgrid_color_activeDblClick(Sender: TObject);
begin
  if (FormMode = ifmUpdate) or (FormMode = ifmNewRecord) then
    SetColor(GetDialogColor(StrToIntDef(edtgrid_color_active.Text, 0)), edtgrid_color_active);
end;

procedure TfrmSysUygulamaAyari.edtgrid_color_activeExit(Sender: TObject);
begin
  inherited;
  SetColor(StrToIntDef(edtgrid_color_active.Text, 0), edtgrid_color_active);
  edtgrid_color_active.Repaint;
end;

procedure TfrmSysUygulamaAyari.FormCreate(Sender: TObject);
begin
  inherited;

  edtunvan.CharCase := ecNormal;
  edtweb_site.CharCase := ecNormal;
  edtemail.CharCase := ecNormal;
  edtmail_host_name.CharCase := ecNormal;
  edtmail_host_user.CharCase := ecNormal;
  edtmail_host_pass.CharCase := ecNormal;
  edtuygulama_lisan.CharCase := ecNormal;
  edtuygulama_surum.CharCase := ecNormal;

  edtsms_service_provider.CharCase := ecNormal;
  edtsms_user.CharCase := ecNormal;
  edtsms_password.CharCase := ecNormal;
  edtsms_title.CharCase := ecNormal;
end;

procedure TfrmSysUygulamaAyari.FormPaint(Sender: TObject);
begin
  inherited;
  SetColor(clRed, edtform_rengi);
end;

procedure TfrmSysUygulamaAyari.FormShow(Sender: TObject);
begin
  edtuygulama_lisan.OnHelperProcess := HelperProcess;
  edtmukellef_tipi_id.OnHelperProcess := HelperProcess;
  edtsehir_id.OnHelperProcess := HelperProcess;

  inherited;

  edtulke_id.ReadOnly := True;
end;

procedure TfrmSysUygulamaAyari.HelperProcess(Sender: TObject);
var
  LFrmCity: TfrmSysSehirler;
  LFrmTaxpayerType: TfrmSysMukellefTipleri;
  LFrmLang: TfrmSysLisanlar;
begin
  if Sender.ClassType = TEdit then
  begin
    if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
    begin
      if TEdit(Sender).Name = edtsehir_id.Name then
      begin
        LFrmCity := TfrmSysSehirler.Create(TEdit(Sender), Self, TSysSehir.Create(Table.Database), fomNormal, True);
        try
          LFrmCity.ShowModal;

          TSysUygulamaAyari(Table).SehirID.Value := LFrmCity.Table.Id.Value;
          TEdit(Sender).Text := TSysSehir(LFrmCity.Table).SehirAdi.Value;
          TSysUygulamaAyari(Table).UlkeID.Value := TSysSehir(LFrmCity.Table).UlkeID.Value;
          edtulke_id.Text := TSysSehir(LFrmCity.Table).UlkeAdi.Value;
        finally
          LFrmCity.Free;
        end;
      end
      else if TEdit(Sender).Name = edtmukellef_tipi_id.Name then
      begin
        LFrmTaxpayerType := TfrmSysMukellefTipleri.Create(TEdit(Sender), Self, TSysMukellefTipi.Create(Table.Database), fomNormal, True);
        try
          LFrmTaxpayerType.ShowModal;

          TSysUygulamaAyari(Table).MukellefTipiID.Value := LFrmTaxpayerType.Table.Id.Value;
        finally
          LFrmTaxpayerType.Free;
        end;
      end
      else if TEdit(Sender).Name = edtuygulama_lisan.Name then
      begin
        LFrmLang := TfrmSysLisanlar.Create(TEdit(Sender), Self, TSysLisan.Create(Table.Database), fomNormal, True);
        try
          LFrmLang.ShowModal;
        finally
          LFrmLang.Free;
        end;
      end
    end;
  end;
end;

procedure TfrmSysUygulamaAyari.imglogoDblClick(Sender: TObject);
var
  LFileName: string;
begin
  if (FormMode = ifmUpdate) or (FormMode = ifmNewRecord) then
  begin
    if CustomMsgDlg(
        'Mevcut resimi kaydetmek ister misin?',
        mtConfirmation,
        mbYesNo,
        ['Evet Kaydet', 'Hayýr Yenisi Yükle'],
        mbNo,
        'Kayýt Onayý') = mrYes
    then
    begin
      imglogo.Picture.SaveToFile(GetDialogSave('', FILE_FILTER_JPG, ''));
    end
    else
    begin
      LFileName := GetDialogOpen(FILE_FILTER_JPG);
      if (LFileName <> '') and FileExists(LFileName) then
        LoadImage(LFileName);
    end;
  end;
end;

procedure TfrmSysUygulamaAyari.LoadImage(pFileName: string);
var
  vRightOrigin: Integer;
begin
  vRightOrigin := imgLogo.Left + imgLogo.Width;
  imgLogo.Picture.LoadFromFile(pFileName);

  if imgLogo.Picture.Bitmap.Width > 640 then
  begin
    imgLogo.Picture.Assign(nil);
    DrawEmptyImage;
    raise Exception.Create('Logo geniþliði en fazla 640px olabilir');
  end;
  if imgLogo.Picture.Bitmap.Height > 480 then
  begin
    imgLogo.Picture.Assign(nil);
    DrawEmptyImage;
    raise Exception.Create('Logo yüksekliði en fazla 480px olabilir');
  end;

  imgLogo.Width := imgLogo.Picture.Bitmap.Width;
  imgLogo.Height := imgLogo.Picture.Bitmap.Height;
  imgLogo.Left := vRightOrigin-imgLogo.Width;
end;

procedure TfrmSysUygulamaAyari.RefreshData();
begin
  edtunvan.Text := FormatedVariantVal(TSysUygulamaAyari(Table).Unvan);
  edttel1.Text := FormatedVariantVal(TSysUygulamaAyari(Table).Tel1);
  edttel2.Text := FormatedVariantVal(TSysUygulamaAyari(Table).Tel2);
  edttel3.Text := FormatedVariantVal(TSysUygulamaAyari(Table).Tel3);
  edttel4.Text := FormatedVariantVal(TSysUygulamaAyari(Table).Tel4);
  edttel5.Text := FormatedVariantVal(TSysUygulamaAyari(Table).Tel5);
  edtfaks1.Text := FormatedVariantVal(TSysUygulamaAyari(Table).Faks1);
  edtfaks2.Text := FormatedVariantVal(TSysUygulamaAyari(Table).Faks2);

  if TSysUygulamaAyari(Table).Logo.Value <> null then
  begin
    ByteArrayToFile(TSysUygulamaAyari(Table).Logo.Value, GUygulamaAnaDizin + 'logo_dmp.bmp');
    try
      LoadImage(GUygulamaAnaDizin + 'logo_dmp.bmp');
    finally
      DeleteFile(GUygulamaAnaDizin + 'logo_dmp.bmp');
    end;
  end
  else
    DrawEmptyImage();

  edtgrid_color_1.Text := FormatedVariantVal(TSysUygulamaAyari(Table).GridColor1);
  edtgrid_color_2.Text := FormatedVariantVal(TSysUygulamaAyari(Table).GridColor2);
  edtgrid_color_active.Text := FormatedVariantVal(TSysUygulamaAyari(Table).GridColorActive);
  secrypt_key.Value := FormatedVariantVal(TSysUygulamaAyari(Table).CryptKey);
  edtform_rengi.Text := FormatedVariantVal(TSysUygulamaAyari(Table).FormRengi);
  edtdonem.Text := FormatedVariantVal(TSysUygulamaAyari(Table).Donem);
  edtuygulama_lisan.Text := FormatedVariantVal(TSysUygulamaAyari(Table).UygulamaLisan);
  edtuygulama_surum.Text := FormatedVariantVal(TSysUygulamaAyari(Table).UygulamaSurum);

  edtmail_host_name.Text := FormatedVariantVal(TSysUygulamaAyari(Table).MailHostName);
  edtmail_host_user.Text := FormatedVariantVal(TSysUygulamaAyari(Table).MailHostUser);
  edtmail_host_pass.Text := FormatedVariantVal(TSysUygulamaAyari(Table).MailHostPass);
  edtmail_host_smtp_port.Text := FormatedVariantVal(TSysUygulamaAyari(Table).MailHostSmtpPort);
  chkis_kalite_form_no_kullan.Checked := FormatedVariantVal(TSysUygulamaAyari(Table).IsKaliteFormNoKullan);
  edtsms_service_provider.Text := FormatedVariantVal(TSysUygulamaAyari(Table).SmsServiceProvider);
  edtsms_user.Text := FormatedVariantVal(TSysUygulamaAyari(Table).SmsUser);
  if FormMode = ifmUpdate then
    edtsms_password.Text := DecryptStr(FormatedVariantVal(TSysUygulamaAyari(Table).SmsPassword), FormatedVariantVal(TSysUygulamaAyari(Table).CryptKey))
  else
    edtsms_password.Text := FormatedVariantVal(TSysUygulamaAyari(Table).SmsPassword);
  edtsms_title.Text := FormatedVariantVal(TSysUygulamaAyari(Table).SmsTitle);

  edtmukellef_tipi_id.Text := FormatedVariantVal(TSysUygulamaAyari(Table).MukellefTipi);
  edtvergi_dairesi.Text := FormatedVariantVal(TSysUygulamaAyari(Table).VergiDairesi);
  edtvergi_no.Text := FormatedVariantVal(TSysUygulamaAyari(Table).VergiNo);
  edtmersis_no.Text := FormatedVariantVal(TSysUygulamaAyari(Table).MersisNo);
  edtticaret_sicil_no.Text := FormatedVariantVal(TSysUygulamaAyari(Table).TicaretSicilNo);
  edtweb_site.Text := FormatedVariantVal(TSysUygulamaAyari(Table).WebSite);
  edtemail.Text := FormatedVariantVal(TSysUygulamaAyari(Table).EMail);
  edtulke_id.Text := FormatedVariantVal(TSysUygulamaAyari(Table).Ulke);
  edtsehir_id.Text := FormatedVariantVal(TSysUygulamaAyari(Table).Sehir);
  edtilce.Text := FormatedVariantVal(TSysUygulamaAyari(Table).Ilce);
  edtmahalle.Text := FormatedVariantVal(TSysUygulamaAyari(Table).Mahalle);
  edtcadde.Text := FormatedVariantVal(TSysUygulamaAyari(Table).Cadde);
  edtsokak.Text := FormatedVariantVal(TSysUygulamaAyari(Table).Sokak);
  edtbina_adi.Text := FormatedVariantVal(TSysUygulamaAyari(Table).BinaAdi);
  edtkapi_no.Text := FormatedVariantVal(TSysUygulamaAyari(Table).KapiNo);
  edtposta_kodu.Text := FormatedVariantVal(TSysUygulamaAyari(Table).PostaKodu);

  SetColor(StrToIntDef(edtform_rengi.Text, 0), edtform_rengi);
  SetColor(StrToIntDef(edtgrid_color_1.Text, 0), edtgrid_color_1);
  SetColor(StrToIntDef(edtgrid_color_2.Text, 0), edtgrid_color_2);
  SetColor(StrToIntDef(edtgrid_color_active.Text, 0), edtgrid_color_active);
end;

procedure TfrmSysUygulamaAyari.SetColor(color: TColor; editColor: TEdit);
begin
  editColor.Text := IntToStr(color);
  editColor.Color := color;
  editColor.thsColorActive := color;
  editColor.thsColorRequiredInput := color;
  editColor.Repaint;
end;

function TfrmSysUygulamaAyari.ValidateInput(
  panel_groupbox_pagecontrol_tabsheet: TWinControl): Boolean;
begin
  Result := inherited ValidateInput(panel_groupbox_pagecontrol_tabsheet);

//  if TSysApplicationSettings(Table).CryptKey.Value <> secrypt_key.Value then
//    Application.MessageBox()
end;

procedure TfrmSysUygulamaAyari.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if ValidateInput(pgcMain) then
    begin
      TSysUygulamaAyari(Table).Unvan.Value := edtunvan.Text;
      TSysUygulamaAyari(Table).Tel1.Value := edttel1.Text;
      TSysUygulamaAyari(Table).Tel2.Value := edttel2.Text;
      TSysUygulamaAyari(Table).Tel3.Value := edttel3.Text;
      TSysUygulamaAyari(Table).Tel4.Value := edttel4.Text;
      TSysUygulamaAyari(Table).Tel5.Value := edttel5.Text;
      TSysUygulamaAyari(Table).Faks1.Value := edtfaks1.Text;
      TSysUygulamaAyari(Table).Faks2.Value := edtfaks2.Text;
      TSysUygulamaAyari(Table).FLogoVal := imgLogo.Picture.Bitmap;

      TSysUygulamaAyari(Table).GridColor1.Value := edtgrid_color_1.Text;
      TSysUygulamaAyari(Table).GridColor2.Value := edtgrid_color_2.Text;
      TSysUygulamaAyari(Table).GridColorActive.Value := edtgrid_color_active.Text;
      TSysUygulamaAyari(Table).CryptKey.Value := secrypt_key.Value;
      TSysUygulamaAyari(Table).FormRengi.Value := edtform_rengi.Text;
      TSysUygulamaAyari(Table).Donem.Value := edtdonem.Text;
      TSysUygulamaAyari(Table).UygulamaLisan.Value := edtuygulama_lisan.Text;
      TSysUygulamaAyari(Table).UygulamaSurum.Value := edtuygulama_surum.Text;
      TSysUygulamaAyari(Table).MailHostName.Value := edtmail_host_name.Text;
      TSysUygulamaAyari(Table).MailHostUser.Value := edtmail_host_user.Text;
      TSysUygulamaAyari(Table).MailHostPass.Value := edtmail_host_pass.Text;
      TSysUygulamaAyari(Table).MailHostSmtpPort.Value := edtmail_host_smtp_port.Text;
      TSysUygulamaAyari(Table).IsKaliteFormNoKullan.Value := chkis_kalite_form_no_kullan.Checked;
      TSysUygulamaAyari(Table).SmsServiceProvider.Value := edtsms_service_provider.Text;
      TSysUygulamaAyari(Table).SmsUser.Value := edtsms_user.Text;
      TSysUygulamaAyari(Table).SmsTitle.Value := edtsms_title.Text;
      TSysUygulamaAyari(Table).SmsPassword.Value := EncryptStr(edtsms_password.Text, TSysUygulamaAyari(Table).CryptKey.Value);

      TSysUygulamaAyari(Table).MukellefTipiID.Value := TSysUygulamaAyari(Table).MukellefTipiID.Value;
      TSysUygulamaAyari(Table).VergiDairesi.Value := edtvergi_dairesi.Text;
      TSysUygulamaAyari(Table).VergiNo.Value := edtvergi_no.Text;
      TSysUygulamaAyari(Table).MersisNo.Value := edtmersis_no.Text;
      TSysUygulamaAyari(Table).TicaretSicilNo.Value := edtticaret_sicil_no.Text;

      TSysUygulamaAyari(Table).WebSite.Value := edtweb_site.Text;
      TSysUygulamaAyari(Table).EMail.Value := edtemail.Text;
      TSysUygulamaAyari(Table).UlkeID.Value := TSysUygulamaAyari(Table).UlkeID.Value;
      TSysUygulamaAyari(Table).SehirID.Value := TSysUygulamaAyari(Table).SehirID.Value;
      TSysUygulamaAyari(Table).Ilce.Value := edtilce.Text;
      TSysUygulamaAyari(Table).Mahalle.Value := edtmahalle.Text;
      TSysUygulamaAyari(Table).Cadde.Value := edtcadde.Text;
      TSysUygulamaAyari(Table).Sokak.Value := edtsokak.Text;
      TSysUygulamaAyari(Table).BinaAdi.Value := edtbina_adi.Text;
      TSysUygulamaAyari(Table).KapiNo.Value := edtkapi_no.Text;
      TSysUygulamaAyari(Table).PostaKodu.Value := edtposta_kodu.Text;

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
