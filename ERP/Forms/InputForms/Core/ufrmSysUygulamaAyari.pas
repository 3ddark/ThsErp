unit ufrmSysUygulamaAyari;

interface

{$I Ths.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.StrUtils, System.Math, Vcl.Graphics, Vcl.Controls,
  Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.AppEvnts,
  Vcl.Menus, Vcl.Samples.Spin, Vcl.Imaging.pngimage, Ths.Helper.BaseTypes,
  Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox, ufrmBase,
  ufrmBaseInputDB, Vcl.Imaging.jpeg, REST.Json;

type
  TfrmSysUygulamaAyari = class(TfrmBaseInputDB)
    lblunvan: TLabel;
    lbltelefon: TLabel;
    lblfaks: TLabel;
    imglogo: TImage;
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
    edtlisan: TEdit;
    edtcrypt_key: TEdit;
    edtversiyon: TEdit;
    edtdonem: TEdit;
    edtgrid_renk_aktif: TEdit;
    edtgrid_renk_2: TEdit;
    edtgrid_renk_1: TEdit;
    lblversiyon: TLabel;
    lbllisan: TLabel;
    lbldonem: TLabel;
    lblcrypt_key: TLabel;
    lblgrid_renk_aktif: TLabel;
    lblgrid_renk_2: TLabel;
    lblgrid_renk_1: TLabel;
    lblsemt: TLabel;
    edtsemt: TEdit;
    lblcadde: TLabel;
    edtcadde: TEdit;
    procedure imglogoDblClick(Sender: TObject);
    procedure edtgrid_renk_1DblClick(Sender: TObject);
    procedure edtgrid_renk_2DblClick(Sender: TObject);
    procedure edtgrid_renk_aktifDblClick(Sender: TObject);
    procedure edtgrid_renk_1Exit(Sender: TObject);
    procedure edtgrid_renk_2Exit(Sender: TObject);
    procedure edtgrid_renk_aktifExit(Sender: TObject);
    procedure btnpath_stok_karti_resimClick(Sender: TObject);
    procedure btnpath_guncellemeClick(Sender: TObject);
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
  Ths.Globals,
  Ths.Constants,
  Ths.Database.Table,
  Ths.Database.Table.SysLisanlar,
  Ths.Database.Table.SysUygulamaAyarlari,
  Ths.Database.Table.SysUlkeler,
  Ths.Database.Table.SysSehirler,
  Ths.Database.Table.SysVergiMukellefTipleri,
  ufrmSysVergiMukellefTipleri,
  ufrmSysSehirler,
  ufrmSysLisanlar;

{$R *.dfm}

procedure TfrmSysUygulamaAyari.btnpath_stok_karti_resimClick(Sender: TObject);
begin
  edtpath_stok_karti_resim.Text := GetDialogDirectory;
end;

procedure TfrmSysUygulamaAyari.btnpath_guncellemeClick(Sender: TObject);
begin
  edtpath_guncelleme.Text := GetDialogDirectory;
end;

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

procedure TfrmSysUygulamaAyari.edtgrid_renk_1DblClick(Sender: TObject);
begin
  if (FormMode = ifmUpdate) or (FormMode = ifmNewRecord) then
    SetColor(GetDialogColor(StrToIntDef(edtgrid_renk_1.Text, 0)), edtgrid_renk_1);
end;

procedure TfrmSysUygulamaAyari.edtgrid_renk_1Exit(Sender: TObject);
begin
  inherited;
  SetColor(StrToIntDef(edtgrid_renk_1.Text, 0), edtgrid_renk_1);
  edtgrid_renk_1.Refresh;
end;

procedure TfrmSysUygulamaAyari.edtgrid_renk_2DblClick(Sender: TObject);
begin
  if (FormMode = ifmUpdate) or (FormMode = ifmNewRecord) then
    SetColor(GetDialogColor(StrToIntDef(edtgrid_renk_2.Text, 0)), edtgrid_renk_2);

end;

procedure TfrmSysUygulamaAyari.edtgrid_renk_2Exit(Sender: TObject);
begin
  inherited;
  SetColor(StrToIntDef(edtgrid_renk_2.Text, 0), edtgrid_renk_2);
  edtgrid_renk_2.Refresh;
end;

procedure TfrmSysUygulamaAyari.edtgrid_renk_aktifDblClick(Sender: TObject);
begin
  if (FormMode = ifmUpdate) or (FormMode = ifmNewRecord) then
    SetColor(GetDialogColor(StrToIntDef(edtgrid_renk_aktif.Text, 0)), edtgrid_renk_aktif);
end;

procedure TfrmSysUygulamaAyari.edtgrid_renk_aktifExit(Sender: TObject);
begin
  inherited;
  SetColor(StrToIntDef(edtgrid_renk_aktif.Text, 0), edtgrid_renk_aktif);
  edtgrid_renk_aktif.Repaint;
end;

procedure TfrmSysUygulamaAyari.FormCreate(Sender: TObject);
begin
  inherited;

  edtunvan.CharCase := ecNormal;
  edtweb.CharCase := ecNormal;
  edtemail.CharCase := ecNormal;
  edtmail_sunucu.CharCase := ecNormal;
  edtmail_kullanici.CharCase := ecNormal;
  edtmail_sifre.CharCase := ecNormal;
  edtlisan.CharCase := ecNormal;
  edtversiyon.CharCase := ecNormal;

  edtsms_sunucu.CharCase := ecNormal;
  edtsms_kullanici.CharCase := ecNormal;
  edtsms_sifre.CharCase := ecNormal;
  edtsms_baslik.CharCase := ecNormal;

  edtpath_stok_karti_resim.CharCase := ecNormal;
  edtpath_guncelleme.CharCase := ecNormal;
end;

procedure TfrmSysUygulamaAyari.FormPaint(Sender: TObject);
begin
  inherited;
  edtpath_stok_karti_resim.ReadOnly := True;
  edtpath_guncelleme.ReadOnly := True;

  btnpath_stok_karti_resim.Enabled := False;
  btnpath_guncelleme.Enabled := False;

  if (FormMode = ifmNewRecord) or (FormMode = ifmUpdate) then
  begin
    btnpath_stok_karti_resim.Enabled := True;
    btnpath_guncelleme.Enabled := True;
  end;

end;

procedure TfrmSysUygulamaAyari.FormShow(Sender: TObject);
begin
  edtlisan.OnHelperProcess := HelperProcess;
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

procedure TfrmSysUygulamaAyari.HelperProcess(Sender: TObject);
var
  LFrmCity: TfrmSysSehirler;
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

          TSysUygulamaAyari(Table).Adres.SehirID.Value := LFrmCity.Table.Id.Value;
          TEdit(Sender).Text := TSysSehir(LFrmCity.Table).Sehir.Value;
          TSysUygulamaAyari(Table).Adres.FSysSehir.UlkeID.Value := TSysSehir(LFrmCity.Table).UlkeID.Value;
          edtulke_adi.Text := TSysSehir(LFrmCity.Table).UlkeAdi.Value;
        finally
          LFrmCity.Free;
        end;
      end
      else if TEdit(Sender).Name = edtlisan.Name then
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
        'Do you want to save the current picture?',
        mtConfirmation,
        mbYesNo,
        ['Yes Save', 'No Upload new'],
        mbNo,
        'Confirmation') = mrYes
    then
    begin
      imglogo.Picture.SaveToFile(GetDialogSave('', FILE_FILTER_IMAGE, ''));
    end
    else
    begin
      GetDialogOpen(FILE_FILTER_IMAGE, LFileName);
      if (LFileName <> '') and FileExists(LFileName) then
        LoadImage(LFileName);
    end;
  end;
end;

procedure TfrmSysUygulamaAyari.LoadImage(pFileName: string);
var
  LRightOrigin: Integer;
  LImgJ: TJPEGImage;
  LImgP: TPngImage;
  LStream: TMemoryStream;
begin
  LRightOrigin := imgLogo.Left + imgLogo.Width;

  LStream := TMemoryStream.Create;
  try
    if ExtractFileExt(pFileName).Replace('.', '') = FILE_EXT_BMP then
    begin
      imglogo.Picture.Bitmap.LoadFromFile(pFileName);
    end
    else if ExtractFileExt(pFileName).Replace('.', '') = FILE_EXT_JPG then
    begin
      LImgJ := TJPEGImage.Create;
      try
        LStream.LoadFromFile(pFileName);
        LStream.Position := 0;
        LImgJ.LoadFromStream(LStream);
        imglogo.Picture.Graphic.Assign(LImgJ);
      finally
        LImgJ.Free;
      end;
    end
    else if ExtractFileExt(pFileName).Replace('.', '') = FILE_EXT_PNG then
    begin
      LImgP := TPngImage.Create;
      try
        LStream.LoadFromFile(pFileName);
        LStream.Position := 0;
        LImgP.LoadFromStream(LStream);
        imglogo.Picture.Graphic.Assign(LImgP);
      finally
        LImgP.Free;
      end;
    end;
  finally
    LStream.Free;
  end;

  if imgLogo.Picture.Bitmap.Width > 640 then
  begin
    imgLogo.Picture.Assign(nil);
    DrawEmptyImage;
    raise Exception.Create('Logo width can be up to 640px');
  end;
  if imgLogo.Picture.Bitmap.Height > 480 then
  begin
    imgLogo.Picture.Assign(nil);
    DrawEmptyImage;
    raise Exception.Create('Logo height can be up to 480px');
  end;

  imgLogo.Width := imgLogo.Picture.Bitmap.Width;
  imgLogo.Height := imgLogo.Picture.Bitmap.Height;
  imgLogo.Left := LRightOrigin-imgLogo.Width;
end;

procedure TfrmSysUygulamaAyari.RefreshData;
begin
  edtunvan.Text := TSysUygulamaAyari(Table).Unvan.AsString;
  edttelefon.Text := TSysUygulamaAyari(Table).Telefon.AsString;
  edtfaks.Text := TSysUygulamaAyari(Table).Faks.AsString;

  LoadImageFromDB(TSysUygulamaAyari(Table).Logo, imglogo);

  edtgrid_renk_1.Text := TSysUygulamaAyari(Table).GridRenk1.AsString;
  edtgrid_renk_2.Text := TSysUygulamaAyari(Table).GridRenk2.AsString;
  edtgrid_renk_aktif.Text := TSysUygulamaAyari(Table).GridRenkAktif.AsString;
  edtcrypt_key.Text := TSysUygulamaAyari(Table).CryptKey.AsString;
  edtdonem.Text := TSysUygulamaAyari(Table).Donem.AsString;
  edtlisan.Text := TSysUygulamaAyari(Table).Lisan.AsString;
  edtversiyon.Text := TSysUygulamaAyari(Table).Versiyon.AsString;

  edtmail_sunucu.Text := TSysUygulamaAyari(Table).MailSunucu.AsString;
  edtmail_kullanici.Text := TSysUygulamaAyari(Table).MailKullanici.AsString;
  if FormMode = ifmUpdate then
  begin
    if TSysUygulamaAyari(Table).MailSifre.AsString <> '' then
      edtmail_sifre.Text := DecryptStr(TSysUygulamaAyari(Table).MailSifre.AsString, TSysUygulamaAyari(Table).CryptKey.Value)
  end
  else
    edtmail_sifre.Text := TSysUygulamaAyari(Table).MailSifre.AsString;
  edtmail_smtp_port.Text := TSysUygulamaAyari(Table).MailSmtpPort.AsString;
  edtsms_sunucu.Text := TSysUygulamaAyari(Table).SmsSunucu.AsString;
  edtsms_kullanici.Text := TSysUygulamaAyari(Table).SmsKullanici.AsString;
  if FormMode = ifmUpdate then
  begin
    if TSysUygulamaAyari(Table).SmsSifre.AsString <> '' then
      edtsms_sifre.Text := DecryptStr(TSysUygulamaAyari(Table).SmsSifre.AsString, TSysUygulamaAyari(Table).CryptKey.Value)
  end
  else
    edtsms_sifre.Text := TSysUygulamaAyari(Table).SmsSifre.AsString;
  edtsms_baslik.Text := TSysUygulamaAyari(Table).SmsBaslik.AsString;

  edtvergi_dairesi.Text := TSysUygulamaAyari(Table).VergiDairesi.AsString;
  edtvergi_numarasi.Text := TSysUygulamaAyari(Table).VergiNo.AsString;
  edtweb.Text := TSysUygulamaAyari(Table).Adres.Web.AsString;
  edtemail.Text := TSysUygulamaAyari(Table).Adres.EMail.AsString;
  edtulke_adi.Text := TSysUygulamaAyari(Table).Adres.UlkeAdi.AsString;
  edtsehir_id.Text := TSysUygulamaAyari(Table).Adres.Sehir.AsString;
  edtilce.Text := TSysUygulamaAyari(Table).Adres.Ilce.AsString;
  edtmahalle.Text := TSysUygulamaAyari(Table).Adres.Mahalle.AsString;
  edtsemt.Text := TSysUygulamaAyari(Table).Adres.Semt.AsString;
  edtcadde.Text := TSysUygulamaAyari(Table).Adres.Cadde.AsString;
  edtsokak.Text := TSysUygulamaAyari(Table).Adres.Sokak.AsString;
  edtbina_adi.Text := TSysUygulamaAyari(Table).Adres.BinaAdi.AsString;
  edtkapi_no.Text := TSysUygulamaAyari(Table).Adres.KapiNo.AsString;
  edtposta_kodu.Text := TSysUygulamaAyari(Table).Adres.PostaKodu.AsString;

  SetColor(StrToIntDef(edtgrid_renk_1.Text, 0), edtgrid_renk_1);
  SetColor(StrToIntDef(edtgrid_renk_2.Text, 0), edtgrid_renk_2);
  SetColor(StrToIntDef(edtgrid_renk_aktif.Text, 0), edtgrid_renk_aktif);

  edtpath_stok_karti_resim.Text := TSysUygulamaAyari(Table).DigerAyarlarJSon.PathStokKartiResim;
  edtpath_guncelleme.Text := TSysUygulamaAyari(Table).DigerAyarlarJSon.PathUpdate;
end;

procedure TfrmSysUygulamaAyari.SetColor(color: TColor; editColor: TEdit);
begin
  editColor.Text := IntToStr(color);
  editColor.Color := color;
  editColor.thsColorActive := color;
  editColor.thsColorRequiredInput := color;
  editColor.Refresh;
end;

function TfrmSysUygulamaAyari.ValidateInput(panel_groupbox_pagecontrol_tabsheet: TWinControl): Boolean;
begin
  Result := inherited ValidateInput(panel_groupbox_pagecontrol_tabsheet);

//  if TSysApplicationSettings(Table).CryptKey.Value <> secrypt_key.Value then
//    Application.MessageBox()

  if not DirectoryExists(edtpath_stok_karti_resim.Text) then
  begin
    pgcMain.ActivePage := tsdiger;
    edtpath_stok_karti_resim.SetFocus;
    CreateExceptionByLang('Lütfen geçerli bir dizin seçin!');
  end;

  if not DirectoryExists(edtpath_guncelleme.Text) then
  begin
    pgcMain.ActivePage := tsdiger;
    edtpath_guncelleme.SetFocus;
    CreateExceptionByLang('Lütfen geçerli bir dizin seçin!');
  end;
end;

procedure TfrmSysUygulamaAyari.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if ValidateInput(pgcMain) then
    begin
      TSysUygulamaAyari(Table).Unvan.Value := edtunvan.Text;
      TSysUygulamaAyari(Table).Telefon.Value := edttelefon.Text;
      TSysUygulamaAyari(Table).Faks.Value := edtfaks.Text;

      setValueFromImage(TSysUygulamaAyari(Table).Logo, imglogo);

      TSysUygulamaAyari(Table).GridRenk1.Value := edtgrid_renk_1.Text;
      TSysUygulamaAyari(Table).GridRenk2.Value := edtgrid_renk_2.Text;
      TSysUygulamaAyari(Table).GridRenkAktif.Value := edtgrid_renk_aktif.Text;
      TSysUygulamaAyari(Table).CryptKey.Value := edtcrypt_key.Text;
      TSysUygulamaAyari(Table).Donem.Value := edtdonem.Text;
      TSysUygulamaAyari(Table).Lisan.Value := edtlisan.Text;
      TSysUygulamaAyari(Table).Versiyon.Value := edtversiyon.Text;

      TSysUygulamaAyari(Table).MailSunucu.Value := edtmail_sunucu.Text;
      TSysUygulamaAyari(Table).MailKullanici.Value := edtmail_kullanici.Text;
      if edtmail_sifre.Text <> '' then
        TSysUygulamaAyari(Table).MailSifre.Value := EncryptStr(edtmail_sifre.Text, TSysUygulamaAyari(Table).CryptKey.Value)
      else
        TSysUygulamaAyari(Table).MailSifre.Value := '';
      TSysUygulamaAyari(Table).MailSmtpPort.Value := edtmail_smtp_port.Text;

      TSysUygulamaAyari(Table).SmsSunucu.Value := edtsms_sunucu.Text;
      TSysUygulamaAyari(Table).SmsKullanici.Value := edtsms_kullanici.Text;
      TSysUygulamaAyari(Table).SmsBaslik.Value := edtsms_baslik.Text;
      if edtsms_sifre.Text <> '' then
        TSysUygulamaAyari(Table).SmsSifre.Value := EncryptStr(edtsms_sifre.Text, TSysUygulamaAyari(Table).CryptKey.Value)
      else
        TSysUygulamaAyari(Table).SmsSifre.Value := '';

      TSysUygulamaAyari(Table).VergiDairesi.Value := edtvergi_dairesi.Text;
      TSysUygulamaAyari(Table).VergiNo.Value := edtvergi_numarasi.Text;

      TSysUygulamaAyari(Table).Adres.Web.Value := edtweb.Text;
      TSysUygulamaAyari(Table).Adres.EMail.Value := edtemail.Text;
      TSysUygulamaAyari(Table).Adres.Ilce.Value := edtilce.Text;
      TSysUygulamaAyari(Table).Adres.Mahalle.Value := edtmahalle.Text;
      TSysUygulamaAyari(Table).Adres.Semt.Value := edtsemt.Text;
      TSysUygulamaAyari(Table).Adres.Cadde.Value := edtcadde.Text;
      TSysUygulamaAyari(Table).Adres.Sokak.Value := edtsokak.Text;
      TSysUygulamaAyari(Table).Adres.BinaAdi.Value := edtbina_adi.Text;
      TSysUygulamaAyari(Table).Adres.KapiNo.Value := edtkapi_no.Text;
      TSysUygulamaAyari(Table).Adres.PostaKodu.Value := edtposta_kodu.Text;

      TSysUygulamaAyari(Table).DigerAyarlarJSon.PathStokKartiResim := edtpath_stok_karti_resim.Text;
      TSysUygulamaAyari(Table).DigerAyarlarJSon.PathUpdate := edtpath_guncelleme.Text;

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
