unit ufrmGiris;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Samples.Spin,
  Vcl.StdCtrls,
  Vcl.Dialogs,
  Vcl.Graphics,
  Vcl.AppEvnts,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.Menus,
  Vcl.Imaging.pngimage,
  Winapi.Windows,
  ZAbstractConnection,
  Ths.Helper.Edit,
  Ths.Helper.ComboBox,
  udm,
  ufrmBase,
  Ths.Database.Connection.Settings;

type
  TfrmGiris = class(TfrmBase)
    lblkullanici_adi: TLabel;
    lblkullanici_sifresi: TLabel;
    lbldb_host: TLabel;
    lblsuncu_ornek: TLabel;
    lbldb_adi: TLabel;
    lbldb_port: TLabel;
    lblayarlari_kaydet: TLabel;
    lbldb_kullanici: TLabel;
    lbldb_kullanici_sifre: TLabel;
    lblprocess_id: TLabel;
    lblprocess_id_val: TLabel;
    lblip_address: TLabel;
    lblip_address_val: TLabel;
    lbllisan: TLabel;
    lblversiyon: TLabel;
    lblversiyon_val: TLabel;
    lbltema: TLabel;
    cbblisan: TComboBox;
    cbbtema: TComboBox;
    edtkullanici_adi: TEdit;
    edtkullanici_sifresi: TEdit;
    edtdb_kullanici: TEdit;
    edtdb_kullanici_sifre: TEdit;
    edtdb_host: TEdit;
    edtdb_adi: TEdit;
    edtdb_port: TEdit;
    chkayarlari_kaydet: TCheckBox;
    imglogo: TImage;
    pb1: TProgressBar;
    procedure RefreshLangValue();
    procedure cbblisanChange(Sender: TObject);
    procedure cbbtemaChange(Sender: TObject);
    procedure edtkullanici_adiDblClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject); override;
  private
    ConnSetting: TConnSettings;
    Langs: TLangs;
    LoginText: TLoginText;
  public
    class function Execute(): Boolean;
  published
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
    procedure btnAcceptClick(Sender: TObject); override;
    procedure Repaint; override;
  end;

const
  FormSmall = 265;
  FormBig = 430;

implementation

uses
  Vcl.Themes,
  Vcl.Styles,
  Ths.Globals,
  Ths.Constants,
  Ths.Database,
  Ths.Database.Table,
  Ths.Database.Table.SysKullanicilar,
  Ths.Database.Table.SysLisanlar,
  Ths.Database.Table.SysLisanGuiIcerikler,
  Ths.Database.Table.SysOndalikHaneler,
  Ths.Database.Table.SysUygulamaAyarlari,
  Ths.Database.Table.SysGunler,
  Ths.Database.Table.SysAylar,
  Ths.Database.Table.SysParaBirimleri,
  Ths.Database.Table.View.SysViewColumns,
  Ths.Database.Table.SysGridKolonlar,
  ufrmDashboard;

{$R *.dfm}

class function TfrmGiris.Execute(): boolean;
begin
  with TfrmGiris.Create(nil) do
  try
    if (ShowModal = mrYes) then
      Result := True
    else
      Result := False;
  finally
    Free;
  end;
end;

procedure TfrmGiris.btnAcceptClick(Sender: TObject);
var
  LUserID: Integer;
  LGuiIcerik: TSysLisanGuiIcerik;
  LGuiContent: TGuiIcerik;
  n1: Integer;

  procedure IncProgress;
  begin
    pb1.Position := pb1.Position + 1;
  end;

begin
  if (edtkullanici_adi.Text <> '') and (edtkullanici_sifresi.Text <> '') then
  begin
    try
      if GDataBase.Connection.Connected then
        GDataBase.Connection.Disconnect;

      ConnSetting.Language := cbblisan.Text;
      ConnSetting.Theme := cbbtema.Text;
      ConnSetting.SQLServer := edtdb_host.Text;
      ConnSetting.DatabaseName := edtdb_adi.Text;
      ConnSetting.DBUserName := edtdb_kullanici.Text;
      ConnSetting.DBUserPassword := edtdb_kullanici_sifre.Text;
      ConnSetting.DBPortNo := StrToIntDef(edtdb_port.Text, 0);
      ConnSetting.UserName := edtkullanici_adi.Text;
      ConnSetting.UserPass := edtkullanici_sifresi.Text;

      AppLanguage := ConnSetting.Language;

      GDataBase.ConfigureConnection(ConnSetting.SQLServer,
                                    ConnSetting.DatabaseName,
                                    ConnSetting.DBUserName,
                                    ConnSetting.DBUserPassword,
                                    ConnSetting.DBPortNo);
      GDataBase.Connection.Connect;
    except
      on E: Exception do
      begin
        ModalResult := mrNone;
        raise Exception.Create('Veri tabaný baðlantý hatasý!' + AddLBs(2) + E.Message);
        Exit;
      end;
    end;

    if GDataBase.Connection.Connected then
    begin
      try
        GDataBase.Connection.ExecuteDirect('SET ths_erp.user_name = ' + QuotedStr(edtkullanici_adi.Text));

        pb1.Max := 11;
        pb1.Min := 0;
        pb1.Position := 0;
        pb1.Visible := True;

        GDataBase.DateDB := GDataBase.GetToday;
        if GSysKullanici = nil then
          GSysKullanici := TSysKullanici.Create(GDataBase);
        if GSysOndalikHane = nil then
          GSysOndalikHane := TSysOndalikHane.Create(GDataBase);
        if GSysApplicationSetting = nil then
          GSysApplicationSetting := TSysUygulamaAyari.Create(GDataBase);
        if GSysLisan = nil then
          GSysLisan := TSysLisan.Create(GDataBase);
        if GParaBirimi = nil then
          GParaBirimi := TSysParaBirimi.Create(GDataBase);
        if GSysTableInfo = nil then
          GSysTableInfo := TSysViewColumns.Create(GDataBase);
        if GGridColWidth = nil then
          GGridColWidth := TSysGridKolon.Create(GDataBase);
        if GGuiIcerik = nil then
          GGuiIcerik := TDictionary<string, TGuiIcerik>.Create;

        LGuiIcerik := TSysLisanGuiIcerik.Create(GDataBase);
        try
          LGuiIcerik.SelectToList(' AND ' + LGuiIcerik.Lisan.QryName + '=' + QuotedStr(cbblisan.Text), False, False);
          for n1 := 0 to LGuiIcerik.List.Count-1 do
          begin
            LGuiContent.FLisan := TSysLisanGuiIcerik(LGuiIcerik.List[n1]).Lisan.AsString;
            LGuiContent.FKod := TSysLisanGuiIcerik(LGuiIcerik.List[n1]).Kod.AsString;
            LGuiContent.FIcerikTipi := TSysLisanGuiIcerik(LGuiIcerik.List[n1]).IcerikTipi.AsString;
            LGuiContent.FTabloAdi := TSysLisanGuiIcerik(LGuiIcerik.List[n1]).TabloAdi.AsString;
            LGuiContent.FDeger := TSysLisanGuiIcerik(LGuiIcerik.List[n1]).Deger.AsString;
            LGuiContent.FIsFabrika := TSysLisanGuiIcerik(LGuiIcerik.List[n1]).IsFabrika.AsBoolean;
            LGuiContent.FFormAdi := TSysLisanGuiIcerik(LGuiIcerik.List[n1]).FormAdi.AsString;

            GGuiIcerik.AddOrSetValue(TSysLisanGuiIcerik(LGuiIcerik.List[n1]).Kod.AsString, LGuiContent);
          end;
          IncProgress;
        finally
          LGuiIcerik.Free;
        end;
        //if AppVersion is wrong then
        //call before the login for use UpdateApplicationExe in Main form

        GSysApplicationSetting.SelectToList('', False, False);
        IncProgress;

        LUserID := Login(edtkullanici_adi.Text, edtkullanici_sifresi.Text);


        if LUserID = -1 then
          raise Exception.Create(edtkullanici_adi.Text + ': böyle bir kullanýcý yok')
        else if LUserID = -2 then
          raise Exception.Create(edtkullanici_adi.Text + ' kullanýcýsý aktif deðil!')
  //        else if vUserID = -3 then
  //          raise Exception.Create(edtUserName.Text + ' kullanýcýsý bu bilgisayardan programý çalýþtýramaz!' + AddLBs(2) +
  //                                 'IP Adres Hatasý' + FERHAT_UYARI)
        else if LUserID = -4 then
          raise Exception.Create('Geçersiz Kullanýcý Þifresi!')
        else if LUserID = -6 then begin
          Application.MessageBox('Yeni bir güncellemeniz var.', 'Güncelleme', MB_ICONINFORMATION);
          TfrmDashboard(Application.MainForm).UpdateApplicationExe();
          Exit;
        end;
  //        else if vUserID = -7 then
  //          raise Exception.Create(edtUserName.Text + ' kullanýcýsý bu bilgisayardan programý çalýþtýramaz!' + AddLBs(2) +
  //                                 'MAC Adres Hatasý' + FERHAT_UYARI);


        GSysKullanici.SelectToList(' AND ' + GSysKullanici.TableName + '.' + GSysKullanici.Id.FieldName + '=' + IntToStr(LUserID), False, False);
        IncProgress;
        GSysLisan.SelectToList(' AND ' + GSysLisan.TableName + '.' + GSysLisan.Lisan.FieldName + '=' + QuotedStr(cbblisan.Text), False, False);
        IncProgress;
        if GSysKullanici.List.Count = 0 then
          raise Exception.Create('Kullanýcý Adý/Þifre tanýmlý deðil veya doðru deðil!');

        GParaBirimi.SelectToList(' ORDER BY 1 ', False, False);
        IncProgress;
        GSysTableInfo.SelectToList('', False, False);
        IncProgress;
        GSysOndalikHane.SelectToList('', False, False);
        IncProgress;
        GGridColWidth.SelectToList('', False, False);

        ModalResult := mrYes;

        if chkayarlari_kaydet.Checked then
          ConnSetting.SaveToFile
        else
          ConnSetting.SaveToFile(True);
      except
        pb1.Visible := False;
      end;
    end;
  end;
end;

procedure TfrmGiris.cbblisanChange(Sender: TObject);
begin
  inherited;
  ConnSetting.Language := cbblisan.Text;
  RefreshLangValue;

  Repaint;
end;

procedure TfrmGiris.cbbtemaChange(Sender: TObject);
begin
  TStyleManager.TrySetStyle(cbbtema.Text, False);
end;

procedure TfrmGiris.edtkullanici_adiDblClick(Sender: TObject);
var
  IsBuyuk: Boolean;
begin
  IsBuyuk := Self.Height = scaleBySystemDPI(FormBig);

  if IsBuyuk then
    Self.Height := scaleBySystemDPI(FormSmall)
  else
    Self.Height := scaleBySystemDPI(FormBig);
  Repaint;
end;

procedure TfrmGiris.FormCreate(Sender: TObject);
var
  n1: Integer;
begin
  inherited;

  ConnSetting := TConnSettings.Create;
  ConnSetting.ReadFromFile;

  Langs := TLangs.Create;
  Langs.ReadFromFile;

  LoginText := TLoginText.Create;
  LoginText.ReadFromFile(ConnSetting.Language);

  Self.Height := scaleBySystemDPI(FormSmall);;
  Repaint;

  dm.illogo.GetIcon(0, imglogo.Picture.Icon);

  cbbtema.Clear;
  for n1 := 0 to Length(TStyleManager.StyleNames)-1 do
    cbbtema.Items.Add(TStyleManager.StyleNames[n1]);
  cbbtema.ItemIndex := cbbtema.Items.IndexOf(ConnSetting.Theme);
  if (cbbtema.Items.Count > 0) and (cbbtema.Text = '') then
    cbbtema.ItemIndex := 0;

  if cbbtema.Text <> '' then
    TStyleManager.TrySetStyle(cbbtema.Text);

  edtkullanici_adi.CharCase := ecUpperCase;

  btnAccept.Visible := True;
  btnClose.Visible := True;
  btnDelete.Visible := False;
  btnSpin.Visible := False;

  cbblisan.Clear;
  cbblisan.Items.Add(ConnSetting.Language);

  {$IFDEF DEBUG}edtkullanici_adi.Text := ConnSetting.UserName;{$ELSE}edtkullanici_adi.Clear;{$ENDIF}
  {$IFDEF DEBUG}edtkullanici_sifresi.Text := ConnSetting.UserPass;{$ELSE}edtkullanici_sifresi.Clear;{$ENDIF}
  edtdb_kullanici.Text := ConnSetting.DBUserName;
  edtdb_kullanici_sifre.Text := ConnSetting.DBUserPassword;
  edtdb_host.Text := ConnSetting.SQLServer;
  edtdb_adi.Text := ConnSetting.DatabaseName;
  edtdb_port.Text := ConnSetting.DBPortNo.ToString;

  cbblisan.ItemIndex := cbblisan.Items.IndexOf(ConnSetting.Language);
  cbblisanChange(cbblisan);
end;

procedure TfrmGiris.FormDestroy(Sender: TObject);
begin
  LoginText.Free;
  Langs.Free;
  ConnSetting.Free;
  inherited;
end;

procedure TfrmGiris.FormShow(Sender: TObject);
var
  n1: Integer;

  LList: TNetworkCardInfoList;
  LLen: Integer;
begin
  inherited;

  cbblisan.Clear;
  for n1 := 0 to Langs.LangList.Count-1 do
    cbblisan.Items.Add( Langs.LangList.Strings[n1]);
  cbblisan.ItemIndex := cbblisan.Items.IndexOf( ConnSetting.Language );
  RefreshLangValue;


  lblprocess_id_val.Caption := GetPIDByHWnd(Application.Handle).ToString;
  lblversiyon_val.Caption := APP_VERSION;

  lblip_address_val.Caption := '';
  LList := GetMACAddress;
  LLen := Length(LList);
  for n1 := 0 to LLen-1 do
    lblip_address_val.Caption := lblip_address_val.Caption + LList[n1].IPAddress + AddLBs +
                                                             LList[n1].MacAddress + AddLBs(2);
end;

procedure TfrmGiris.RefreshLangValue;
begin
  LoginText.ReadFromFile(ConnSetting.Language);

  Caption := LoginText.Title;
  lbllisan.Caption := LoginText.Lang;
  lblkullanici_adi.Caption := LoginText.User;
  lblkullanici_sifresi.Caption := LoginText.UserPass;
  lbldb_kullanici.Caption := LoginText.DBUser;
  lbldb_kullanici_sifre.Caption := LoginText.DBPass;
  lbldb_host.Caption := LoginText.Server;
  lblsuncu_ornek.Caption := LoginText.Example;
  lbldb_adi.Caption := LoginText.DBName;
  lbldb_port.Caption := LoginText.DBPort;
  lblayarlari_kaydet.Caption := LoginText.SaveSettings;
  lbltema.Caption := LoginText.ThemeName;
end;

procedure TfrmGiris.Repaint;
var
  LVisible: Boolean;
begin
  inherited;
  if Self.Height = scaleBySystemDPI(FormSmall) then
    LVisible := False
  else
    LVisible := True;

  edtdb_kullanici.Visible := LVisible;
  edtdb_kullanici_sifre.Visible := LVisible;
  edtdb_host.Visible := LVisible;
  edtdb_adi.Visible := LVisible;
  edtdb_port.Visible := LVisible;
  chkayarlari_kaydet.Visible := LVisible;
end;

end.
