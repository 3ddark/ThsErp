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
    lblUserName: TLabel;
    lblPassword: TLabel;
    lblServer: TLabel;
    lblServerExample: TLabel;
    lblDatabase: TLabel;
    lblPortNo: TLabel;
    lblSaveSettings: TLabel;
    lblDBUserName: TLabel;
    lblDBPassword: TLabel;
    lblprocess_id: TLabel;
    lblprocess_id_val: TLabel;
    lblip_address: TLabel;
    lblip_address_val: TLabel;
    lblLanguage: TLabel;
    lblversion: TLabel;
    lblversion_val: TLabel;
    lbltheme_name: TLabel;
    cbbLanguage: TComboBox;
    cbbtheme_name: TComboBox;
    edtUserName: TEdit;
    edtPassword: TEdit;
    edtDBUserName: TEdit;
    edtDBPassword: TEdit;
    edtServer: TEdit;
    edtDatabase: TEdit;
    edtPortNo: TEdit;
    chkSaveSettings: TCheckBox;
    imglogo: TImage;
    pb1: TProgressBar;
    procedure RefreshLangValue();
    procedure cbbLanguageChange(Sender: TObject);
    procedure cbbtheme_nameChange(Sender: TObject);
    procedure edtUserNameDblClick(Sender: TObject);
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
  if (edtUserName.Text <> '') and (edtPassword.Text <> '') then
  begin
    try
      if GDataBase.Connection.Connected then
        GDataBase.Connection.Disconnect;

      ConnSetting.Language := cbbLanguage.Text;
      ConnSetting.Theme := cbbtheme_name.Text;
      ConnSetting.SQLServer := edtServer.Text;
      ConnSetting.DatabaseName := edtDatabase.Text;
      ConnSetting.DBUserName := edtDBUserName.Text;
      ConnSetting.DBUserPassword := edtDBPassword.Text;
      ConnSetting.DBPortNo := StrToIntDef(edtPortNo.Text, 0);
      ConnSetting.UserName := edtUserName.Text;
      ConnSetting.UserPass := edtPassword.Text;

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
          LGuiIcerik.SelectToList(' AND ' + LGuiIcerik.Lisan.QryName + '=' + QuotedStr(cbbLanguage.Text), False, False);
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

        LUserID := Login(edtUserName.Text, edtPassword.Text);


        if LUserID = -1 then
          raise Exception.Create(edtUserName.Text + ': böyle bir kullanýcý yok')
        else if LUserID = -2 then
          raise Exception.Create(edtUserName.Text + ' kullanýcýsý aktif deðil!')
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
        GSysLisan.SelectToList(' AND ' + GSysLisan.TableName + '.' + GSysLisan.Lisan.FieldName + '=' + QuotedStr(cbbLanguage.Text), False, False);
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

        if chkSaveSettings.Checked then
          ConnSetting.SaveToFile
        else
          ConnSetting.SaveToFile(True);
      except
        pb1.Visible := False;
      end;
    end;
  end;
end;

procedure TfrmGiris.cbbLanguageChange(Sender: TObject);
begin
  inherited;
  ConnSetting.Language := cbbLanguage.Text;
  RefreshLangValue;

  Repaint;
end;

procedure TfrmGiris.cbbtheme_nameChange(Sender: TObject);
begin
  TStyleManager.TrySetStyle(cbbtheme_name.Text, False);
end;

procedure TfrmGiris.edtUserNameDblClick(Sender: TObject);
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

  cbbtheme_name.Clear;
  for n1 := 0 to Length(TStyleManager.StyleNames)-1 do
    cbbtheme_name.Items.Add(TStyleManager.StyleNames[n1]);
  cbbtheme_name.ItemIndex := cbbtheme_name.Items.IndexOf(ConnSetting.Theme);
  if (cbbtheme_name.Items.Count > 0) and (cbbtheme_name.Text = '') then
    cbbtheme_name.ItemIndex := 0;

  if cbbtheme_name.Text <> '' then
    TStyleManager.TrySetStyle(cbbtheme_name.Text);

  edtUserName.CharCase := ecUpperCase;

  btnAccept.Visible := True;
  btnClose.Visible := True;
  btnDelete.Visible := False;
  btnSpin.Visible := False;

  cbbLanguage.Clear;
  cbbLanguage.Items.Add(ConnSetting.Language);

  {$IFDEF DEBUG}edtUserName.Text := ConnSetting.UserName;{$ELSE}edtUserName.Clear;{$ENDIF}
  {$IFDEF DEBUG}edtPassword.Text := ConnSetting.UserPass;{$ELSE}edtPassword.Clear;{$ENDIF}
  edtDBUserName.Text := ConnSetting.DBUserName;
  edtDBPassword.Text := ConnSetting.DBUserPassword;
  edtServer.Text := ConnSetting.SQLServer;
  edtDatabase.Text := ConnSetting.DatabaseName;
  edtPortNo.Text := ConnSetting.DBPortNo.ToString;

  cbbLanguage.ItemIndex := cbbLanguage.Items.IndexOf(ConnSetting.Language);
  cbbLanguageChange(cbbLanguage);
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

  cbbLanguage.Clear;
  for n1 := 0 to Langs.LangList.Count-1 do
    cbbLanguage.Items.Add( Langs.LangList.Strings[n1]);
  cbbLanguage.ItemIndex := cbbLanguage.Items.IndexOf( ConnSetting.Language );
  RefreshLangValue;


  lblprocess_id_val.Caption := GetPIDByHWnd(Application.Handle).ToString;
  lblversion_val.Caption := APP_VERSION;

  lblip_address_val.Caption := '';
  LList := GetMACAddress;
  LLen := Length(LList);
  for n1 := 0 to LLen-1 do
    lblip_address_val.Caption := lblip_address_val.Caption + LList[n1].IPAddress + AddLBs +
                                                             LList[n1].MacAddress + AddLBs(2);
end;

procedure TfrmGiris.RefreshLangValue;
begin
  Self.Caption := 'Giriþ';

  LoginText.ReadFromFile(ConnSetting.Language);

  Caption := LoginText.Title;
  lblLanguage.Caption := LoginText.Lang;
  lblUserName.Caption := LoginText.User;
  lblPassword.Caption := LoginText.UserPass;
  lblDBUserName.Caption := LoginText.DBUser;
  lblDBPassword.Caption := LoginText.DBPass;
  lblServer.Caption := LoginText.Server;
  lblServerExample.Caption := LoginText.Example;
  lblDatabase.Caption := LoginText.DBName;
  lblPortNo.Caption := LoginText.DBPort;
  lblSaveSettings.Caption := LoginText.SaveSettings;
  lbltheme_name.Caption := LoginText.ThemeName;
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

  edtDBUserName.Visible := LVisible;
  edtDBPassword.Visible := LVisible;
  edtServer.Visible := LVisible;
  edtDatabase.Visible := LVisible;
  edtPortNo.Visible := LVisible;
  chkSaveSettings.Visible := LVisible;
end;

end.
