unit ufrmSysUygulamaAyari;

interface

{$I Ths.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.StrUtils, System.Math, Vcl.Graphics, Vcl.Controls,
  Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.AppEvnts,
  Vcl.Menus, Vcl.Samples.Spin, Vcl.Imaging.pngimage, Ths.Helper.BaseTypes,
  Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox, ufrmBase,
  ufrmBaseInputDB, Vcl.Imaging.jpeg;

type
  TfrmSysUygulamaAyari = class(TfrmBaseInputDB)
    lbltitle: TLabel;
    lblphone1: TLabel;
    lblphone2: TLabel;
    lblphone3: TLabel;
    lblfax1: TLabel;
    lblfax2: TLabel;
    imglogo: TImage;
    edttitle: TEdit;
    edtphone1: TEdit;
    edtphone2: TEdit;
    edtphone3: TEdit;
    edtfax1: TEdit;
    edtfax2: TEdit;
    tsother: TTabSheet;
    lblgrid_color_1: TLabel;
    edtgrid_color_1: TEdit;
    lblgrid_color_2: TLabel;
    edtgrid_color_2: TEdit;
    lblgrid_color_active: TLabel;
    edtgrid_color_active: TEdit;
    lblcrypt_key: TLabel;
    lblperiod: TLabel;
    edtperiod: TEdit;
    lblapp_language: TLabel;
    lblmail_host_name: TLabel;
    edtmail_host_name: TEdit;
    lblmail_host_user: TLabel;
    edtmail_host_user: TEdit;
    lblmail_host_pass: TLabel;
    edtmail_host_pass: TEdit;
    lblmail_host_smtp_port: TLabel;
    edtmail_host_smtp_port: TEdit;
    tsaddress: TTabSheet;
    lbltax_administration: TLabel;
    edttax_administration: TEdit;
    lbltax_number: TLabel;
    edttax_number: TEdit;
    lblweb_site: TLabel;
    edtweb_site: TEdit;
    lblemail: TLabel;
    edtemail: TEdit;
    lblcountry_id: TLabel;
    lblcity_id: TLabel;
    edtcity_id: TEdit;
    lbldistrict: TLabel;
    edtdistrict: TEdit;
    lblneighborhood: TLabel;
    edtneighborhood: TEdit;
    lblstreet: TLabel;
    edtstreet: TEdit;
    lblbuilding_name: TLabel;
    edtbuilding_name: TEdit;
    lbldoor_no: TLabel;
    edtdoor_no: TEdit;
    lblpost_code: TLabel;
    edtpost_code: TEdit;
    edtcountry_id: TEdit;
    edtapp_language: TEdit;
    lblsms_service_provider: TLabel;
    lblsms_user: TLabel;
    lblsms_password: TLabel;
    lblsms_title: TLabel;
    edtsms_service_provider: TEdit;
    edtsms_user: TEdit;
    edtsms_password: TEdit;
    edtsms_title: TEdit;
    lblapp_version: TLabel;
    edtapp_version: TEdit;
    edtcrypt_key: TEdit;
    ts1: TTabSheet;
    lblpath_stock_image: TLabel;
    lblpath_update: TLabel;
    edtpath_stock_image: TEdit;
    btnpath_stock_image: TButton;
    edtpath_update: TEdit;
    btnpath_update: TButton;
    procedure imglogoDblClick(Sender: TObject);
    procedure edtgrid_color_1DblClick(Sender: TObject);
    procedure edtgrid_color_2DblClick(Sender: TObject);
    procedure edtgrid_color_activeDblClick(Sender: TObject);
    procedure edtgrid_color_1Exit(Sender: TObject);
    procedure edtgrid_color_2Exit(Sender: TObject);
    procedure edtgrid_color_activeExit(Sender: TObject);
    procedure btnpath_stock_imageClick(Sender: TObject);
    procedure btnpath_updateClick(Sender: TObject);
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

procedure TfrmSysUygulamaAyari.btnpath_stock_imageClick(Sender: TObject);
begin
  edtpath_stock_image.Text := GetDialogDirectory;
end;

procedure TfrmSysUygulamaAyari.btnpath_updateClick(Sender: TObject);
begin
  edtpath_update.Text := GetDialogDirectory;
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

  edttitle.CharCase := ecNormal;
  edtweb_site.CharCase := ecNormal;
  edtemail.CharCase := ecNormal;
  edtmail_host_name.CharCase := ecNormal;
  edtmail_host_user.CharCase := ecNormal;
  edtmail_host_pass.CharCase := ecNormal;
  edtapp_language.CharCase := ecNormal;
  edtapp_version.CharCase := ecNormal;

  edtsms_service_provider.CharCase := ecNormal;
  edtsms_user.CharCase := ecNormal;
  edtsms_password.CharCase := ecNormal;
  edtsms_title.CharCase := ecNormal;

  edtpath_stock_image.CharCase := ecNormal;
  edtpath_update.CharCase := ecNormal;
end;

procedure TfrmSysUygulamaAyari.FormPaint(Sender: TObject);
begin
  inherited;
  edtpath_stock_image.ReadOnly := True;
  edtpath_update.ReadOnly := True;

  btnpath_stock_image.Enabled := False;
  btnpath_update.Enabled := False;

  if (FormMode = ifmNewRecord) or (FormMode = ifmUpdate) then
  begin
    btnpath_stock_image.Enabled := True;
    btnpath_update.Enabled := True;
  end;

end;

procedure TfrmSysUygulamaAyari.FormShow(Sender: TObject);
begin
  edtapp_language.OnHelperProcess := HelperProcess;
  edtcity_id.OnHelperProcess := HelperProcess;

  inherited;

  edtcountry_id.ReadOnly := True;
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
      if TEdit(Sender).Name = edtcity_id.Name then
      begin
        LFrmCity := TfrmSysSehirler.Create(TEdit(Sender), Self, TSysSehir.Create(Table.Database), fomNormal, True);
        try
          LFrmCity.ShowModal;

          TSysUygulamaAyari(Table).Adres.SehirID.Value := LFrmCity.Table.Id.Value;
          TEdit(Sender).Text := TSysSehir(LFrmCity.Table).Sehir.Value;
          TSysUygulamaAyari(Table).Adres.FSysSehir.UlkeID.Value := TSysSehir(LFrmCity.Table).UlkeID.Value;
          edtcountry_id.Text := TSysSehir(LFrmCity.Table).Ulke.Value;
        finally
          LFrmCity.Free;
        end;
      end
      else if TEdit(Sender).Name = edtapp_language.Name then
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
  edttitle.Text := TSysUygulamaAyari(Table).Unvan.AsString;
  edtphone1.Text := TSysUygulamaAyari(Table).Telefon.AsString;
  edtfax1.Text := TSysUygulamaAyari(Table).Faks.AsString;

  LoadImageFromDB(TSysUygulamaAyari(Table).Logo, imglogo);

  edtgrid_color_1.Text := TSysUygulamaAyari(Table).GridRenk1.AsString;
  edtgrid_color_2.Text := TSysUygulamaAyari(Table).GridRenk2.AsString;
  edtgrid_color_active.Text := TSysUygulamaAyari(Table).GridRenkAktif.AsString;
  edtcrypt_key.Text := TSysUygulamaAyari(Table).CryptKey.AsString;
  edtperiod.Text := TSysUygulamaAyari(Table).Donem.AsString;
  edtapp_language.Text := TSysUygulamaAyari(Table).Lisan.AsString;
  edtapp_version.Text := TSysUygulamaAyari(Table).Versiyon.AsString;

  edtmail_host_name.Text := TSysUygulamaAyari(Table).MailSunucu.AsString;
  edtmail_host_user.Text := TSysUygulamaAyari(Table).MailKullanici.AsString;
  edtmail_host_pass.Text := TSysUygulamaAyari(Table).MailSifre.AsString;
  edtmail_host_smtp_port.Text := TSysUygulamaAyari(Table).MailSmtpPort.AsString;
  edtsms_service_provider.Text := TSysUygulamaAyari(Table).SmsSunucu.AsString;
  edtsms_user.Text := TSysUygulamaAyari(Table).SmsKullanici.AsString;
  if FormMode = ifmUpdate then
    edtsms_password.Text := DecryptStr(TSysUygulamaAyari(Table).SmsSifre.Value, TSysUygulamaAyari(Table).CryptKey.Value)
  else
    edtsms_password.Text := TSysUygulamaAyari(Table).SmsSifre.AsString;
  edtsms_title.Text := TSysUygulamaAyari(Table).SmsBaslik.AsString;

  edttax_administration.Text := TSysUygulamaAyari(Table).VergiDairesi.AsString;
  edttax_number.Text := TSysUygulamaAyari(Table).VergiNo.AsString;
  edtweb_site.Text := TSysUygulamaAyari(Table).Adres.Web.AsString;
  edtemail.Text := TSysUygulamaAyari(Table).Adres.EMail.AsString;
  edtcountry_id.Text := TSysUygulamaAyari(Table).Adres.Ulke.AsString;
  edtcity_id.Text := TSysUygulamaAyari(Table).Adres.Sehir.AsString;
  edtdistrict.Text := TSysUygulamaAyari(Table).Adres.Mahalle.AsString;
  edtneighborhood.Text := TSysUygulamaAyari(Table).Adres.Cadde.AsString;
  edtstreet.Text := TSysUygulamaAyari(Table).Adres.Sokak.AsString;
  edtbuilding_name.Text := TSysUygulamaAyari(Table).Adres.BinaAdi.AsString;
  edtdoor_no.Text := TSysUygulamaAyari(Table).Adres.KapiNo.AsString;
  edtpost_code.Text := TSysUygulamaAyari(Table).Adres.PostaKodu.AsString;

  SetColor(StrToIntDef(edtgrid_color_1.Text, 0), edtgrid_color_1);
  SetColor(StrToIntDef(edtgrid_color_2.Text, 0), edtgrid_color_2);
  SetColor(StrToIntDef(edtgrid_color_active.Text, 0), edtgrid_color_active);

//  edtpath_stock_image.Text := TSysUygulamaAyariDiger(Table).PathUpdate.AsString;
//  edtpath_update.Text := TSysUygulamaAyariDiger(Table).PathStockImage.AsString;
end;

procedure TfrmSysUygulamaAyari.SetColor(color: TColor; editColor: TEdit);
begin
  editColor.Text := IntToStr(color);
  editColor.Color := color;
  editColor.thsColorActive := color;
  editColor.thsColorRequiredInput := color;
  editColor.Repaint;
end;

function TfrmSysUygulamaAyari.ValidateInput(panel_groupbox_pagecontrol_tabsheet: TWinControl): Boolean;
begin
  Result := inherited ValidateInput(panel_groupbox_pagecontrol_tabsheet);

//  if TSysApplicationSettings(Table).CryptKey.Value <> secrypt_key.Value then
//    Application.MessageBox()

  if not DirectoryExists(edtpath_stock_image.Text) then
  begin
    edtpath_stock_image.SetFocus;
    CreateExceptionByLang('Please select a valid directory!', '999999', '1');
  end;

  if not DirectoryExists(edtpath_update.Text) then
  begin
    edtpath_update.SetFocus;
    CreateExceptionByLang('Please select a valid directory!', '999999', '1');
  end;
end;

procedure TfrmSysUygulamaAyari.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if ValidateInput(pgcMain) then
    begin
      TSysUygulamaAyari(Table).Unvan.Value := edttitle.Text;
      TSysUygulamaAyari(Table).Telefon.Value := edtphone1.Text;
      TSysUygulamaAyari(Table).Faks.Value := edtfax1.Text;

      setValueFromImage(TSysUygulamaAyari(Table).Logo, imglogo);

      TSysUygulamaAyari(Table).GridRenk1.Value := edtgrid_color_1.Text;
      TSysUygulamaAyari(Table).GridRenk2.Value := edtgrid_color_2.Text;
      TSysUygulamaAyari(Table).GridRenkAktif.Value := edtgrid_color_active.Text;
      TSysUygulamaAyari(Table).CryptKey.Value := edtcrypt_key.Text;
      TSysUygulamaAyari(Table).Donem.Value := edtperiod.Text;
      TSysUygulamaAyari(Table).Lisan.Value := edtapp_language.Text;
      TSysUygulamaAyari(Table).Versiyon.Value := edtapp_version.Text;
      TSysUygulamaAyari(Table).MailSunucu.Value := edtmail_host_name.Text;
      TSysUygulamaAyari(Table).MailKullanici.Value := edtmail_host_user.Text;
      TSysUygulamaAyari(Table).MailSifre.Value := edtmail_host_pass.Text;
      TSysUygulamaAyari(Table).MailSmtpPort.Value := edtmail_host_smtp_port.Text;
      TSysUygulamaAyari(Table).SmsSunucu.Value := edtsms_service_provider.Text;
      TSysUygulamaAyari(Table).SmsKullanici.Value := edtsms_user.Text;
      TSysUygulamaAyari(Table).SmsBaslik.Value := edtsms_title.Text;
      TSysUygulamaAyari(Table).SmsSifre.Value := EncryptStr(edtsms_password.Text, TSysUygulamaAyari(Table).CryptKey.Value);

      TSysUygulamaAyari(Table).VergiDairesi.Value := edttax_administration.Text;
      TSysUygulamaAyari(Table).VergiNo.Value := edttax_number.Text;

      TSysUygulamaAyari(Table).Adres.Web.Value := edtweb_site.Text;
      TSysUygulamaAyari(Table).Adres.EMail.Value := edtemail.Text;
      TSysUygulamaAyari(Table).Adres.Mahalle.Value := edtdistrict.Text;
      TSysUygulamaAyari(Table).Adres.Cadde.Value := edtneighborhood.Text;
      TSysUygulamaAyari(Table).Adres.Sokak.Value := edtstreet.Text;
      TSysUygulamaAyari(Table).Adres.BinaAdi.Value := edtbuilding_name.Text;
      TSysUygulamaAyari(Table).Adres.KapiNo.Value := edtdoor_no.Text;
      TSysUygulamaAyari(Table).Adres.PostaKodu.Value := edtpost_code.Text;

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
