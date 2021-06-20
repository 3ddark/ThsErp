unit ufrmLogin;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  System.Classes,
  System.StrUtils,
  System.Threading,
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
  FireDAC.Comp.Client,
  IdGlobal,
  IdStack,
  xmldom,
  XMLDoc,
  XMLIntf,
  Ths.Erp.Helper.Edit,
  Ths.Erp.Helper.ComboBox,
  udm,
  ufrmBase,
  ufrmBaseInput;

type
  TfrmLogin = class(TfrmBase)
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
    procedure RefreshLangValue();
    procedure cbbLanguageChange(Sender: TObject);
    procedure cbbtheme_nameChange(Sender: TObject);
    procedure edtUserNameDblClick(Sender: TObject);
  public
    class function Execute(): Boolean;
  published
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
    procedure btnAcceptClick(Sender: TObject); override;
    procedure Repaint; override;
  end;

const
  FormSmall = 270;
  FormBig = 430;

implementation

uses
  Vcl.Themes,
  Vcl.Styles,
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton,
  Ths.Erp.Database,
  Ths.Erp.Database.Connection.Settings,
  Ths.Erp.Database.Table,
  Ths.Erp.Database.Table.SysKullanici,
  Ths.Erp.Database.Table.SysLisan,
  Ths.Erp.Database.Table.SysLisanGuiIcerik,
  Ths.Erp.Database.Table.SysOndalikHane,
  Ths.Erp.Database.Table.SysUygulamaAyari,
  Ths.Erp.Database.Table.SysUygulamaAyariDiger,
  Ths.Erp.Database.Table.SysGun,
  Ths.Erp.Database.Table.SysAy,
  Ths.Erp.Database.Table.SysParaBirimi,
  Ths.Erp.Database.Table.View.SysViewColumns,
  ufrmMain;

{$R *.dfm}

class function TfrmLogin.Execute(): boolean;
begin
  with TfrmLogin.Create(nil) do
  try
    if (ShowModal = mrYes) then
      Result := True
    else
      Result := False;
  finally
    Free;
  end;
end;

procedure TfrmLogin.btnAcceptClick(Sender: TObject);
var
  vUserID: Integer;
begin
  if (edtUserName.Text <> '') and (edtPassword.Text <> '') then
  begin
    try
      if GDataBase.Connection.Connected then
      begin
        GDataBase.Connection.Close;
        GDataBase.ConManager.Close;
      end;

      GDataBase.ConnSetting.Language := cbbLanguage.Text;
      GDataBase.ConnSetting.Theme := cbbtheme_name.Text;
      GDataBase.ConnSetting.SQLServer := edtServer.Text;
      GDataBase.ConnSetting.DatabaseName := edtDatabase.Text;
      GDataBase.ConnSetting.DBUserName := edtDBUserName.Text;
      GDataBase.ConnSetting.DBUserPassword := edtDBPassword.Text;
      GDataBase.ConnSetting.DBPortNo := StrToIntDef(edtPortNo.Text, 0);
      GDataBase.ConnSetting.UserName := edtUserName.Text;
      GDataBase.ConnSetting.UserPass := edtPassword.Text;

      GDataBase.ConfigureConnection;
      GDataBase.Connection.Open();
    except
      on E: Exception do
      begin
        ModalResult := mrNone;
        raise Exception.Create(TranslateText('Veri tabaný baðlantý hatasý!', FrameworkLang.ErrorDatabaseConnection, LngMsgError, LngSystem) + sLineBreak + sLineBreak + E.Message);
        Exit;
      end;
    end;

    if GDataBase.Connection.Connected then
    begin
      GDataBase.DateDB := GDataBase.GetToday;

      if GSysKullanici = nil then
        GSysKullanici := TSysKullanici.Create(GDataBase);
      if GSysOndalikHane = nil then
        GSysOndalikHane := TSysOndalikHane.Create(GDataBase);
      if GSysUygulamaAyari = nil then
        GSysUygulamaAyari := TSysUygulamaAyari.Create(GDataBase);
      if GSysUygulamaAyariDiger = nil then
        GSysUygulamaAyariDiger := TSysUygulamaAyariDiger.Create(GDataBase);
      if GSysLisan = nil then
        GSysLisan := TSysLisan.Create(GDataBase);
      if GSysGun = nil then
        GSysGun := TSysGun.Create(GDataBase);
      if GSysAy = nil then
        GSysAy := TSysAy.Create(GDataBase);
      if GParaBirimi = nil then
        GParaBirimi := TSysParaBirimi.Create(GDataBase);
      if GSysTableInfo = nil then
        GSysTableInfo := TSysViewColumns.Create(GDataBase);

      //if AppVersion is wrong then
      //call before the login for use UpdateApplicationExe in Main form

      GSysUygulamaAyari.SelectToList('', False, False);
      GSysUygulamaAyariDiger.SelectToList('', False, False);

      vUserID := Login(edtUserName.Text, edtPassword.Text);


      if vUserID = -1 then
        raise Exception.Create(edtUserName.Text + ': böyle bir kullanýcý yok')
      else if vUserID = -2 then
        raise Exception.Create(edtUserName.Text + ' kullanýcýsý aktif deðil!')
//        else if vUserID = -3 then
//          raise Exception.Create(edtUserName.Text + ' kullanýcýsý bu bilgisayardan programý çalýþtýramaz!' + AddLBs(2) +
//                                 'IP Adres Hatasý' + FERHAT_UYARI)
      else if vUserID = -4 then
        raise Exception.Create('Geçersiz Kullanýcý Þifresi!')
      else if vUserID = -6 then begin
        Application.MessageBox('Yeni bir güncellemeniz var.', 'Güncelleme', MB_ICONINFORMATION);
        TfrmMain(Application.MainForm).UpdateApplicationExe();
        Exit;
      end;
//        else if vUserID = -7 then
//          raise Exception.Create(edtUserName.Text + ' kullanýcýsý bu bilgisayardan programý çalýþtýramaz!' + AddLBs(2) +
//                                 'MAC Adres Hatasý' + FERHAT_UYARI);


      GSysKullanici.SelectToList(' AND ' + GSysKullanici.TableName + '.' + GSysKullanici.Id.FieldName + '=' + IntToStr(vUserID), False, False);
      GSysLisan.SelectToList(' AND ' + GSysLisan.TableName + '.' + GSysLisan.Lisan.FieldName + '=' + QuotedStr(cbbLanguage.Text), False, False);
      if GSysKullanici.List.Count = 0 then
        raise Exception.Create(TranslateText('Kullanýcý Adý/Þifre tanýmlý veya doðru deðil!', FrameworkLang.ErrorLogin, LngMsgError, LngSystem));

      GSysGun.SelectToList(' ORDER BY 1 ', False, False);
      GParaBirimi.SelectToList(' ORDER BY 1 ', False, False);
      GSysAy.SelectToList(' ORDER BY 1 ', False, False);
      GSysTableInfo.SelectToList('', False, False);
      GSysOndalikHane.SelectToList('', False, False);

      ModalResult := mrYes;

      if chkSaveSettings.Checked then
        GDataBase.ConnSetting.SaveToFile
      else
        GDataBase.ConnSetting.SaveToFile(True);
    end;
  end;
end;

procedure TfrmLogin.cbbLanguageChange(Sender: TObject);
begin
  inherited;
  GDataBase.ConnSetting.Language := cbbLanguage.Text;
  RefreshLangValue;

  Repaint;
end;

procedure TfrmLogin.cbbtheme_nameChange(Sender: TObject);
begin
  TStyleManager.TrySetStyle(cbbtheme_name.Text, False);
end;

procedure TfrmLogin.edtUserNameDblClick(Sender: TObject);
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

procedure TfrmLogin.FormCreate(Sender: TObject);
var
  n1: Integer;
begin
  inherited;

  Self.Height := scaleBySystemDPI(FormSmall);;
  Repaint;

  dm.illogo.GetIcon(0, imglogo.Picture.Icon);

  cbbtheme_name.Clear;
  for n1 := 0 to Length(TStyleManager.StyleNames)-1 do
    cbbtheme_name.Items.Add(TStyleManager.StyleNames[n1]);
  cbbtheme_name.ItemIndex := cbbtheme_name.Items.IndexOf(GDataBase.ConnSetting.Theme);
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
  cbbLanguage.Items.Add(GDataBase.ConnSetting.Language);

  {$IFDEF DEBUG}edtUserName.Text := GDataBase.ConnSetting.UserName;{$ELSE}edtUserName.Clear;{$ENDIF}
  {$IFDEF DEBUG}edtPassword.Text := GDataBase.ConnSetting.UserPass;{$ELSE}edtPassword.Clear;{$ENDIF}
  edtDBUserName.Text := GDataBase.ConnSetting.DBUserName;
  edtDBPassword.Text := GDataBase.ConnSetting.DBUserPassword;
  edtServer.Text := GDataBase.ConnSetting.SQLServer;
  edtDatabase.Text := GDataBase.ConnSetting.DatabaseName;
  edtPortNo.Text := GDataBase.ConnSetting.DBPortNo.ToString;

  cbbLanguage.ItemIndex := cbbLanguage.Items.IndexOf(GDataBase.ConnSetting.Language);
  cbbLanguageChange(cbbLanguage);
end;

procedure TfrmLogin.FormShow(Sender: TObject);
var
  n1: Integer;

  LList: TNetworkCardInfoList;
  LLen: Integer;
begin
  inherited;

  cbbLanguage.Clear;
  for n1 := 0 to GDataBase.Langs.LangList.Count-1 do
    cbbLanguage.Items.Add( GDataBase.Langs.LangList.Strings[n1]);
  cbbLanguage.ItemIndex := cbbLanguage.Items.IndexOf( GDataBase.ConnSetting.Language );
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

procedure TfrmLogin.RefreshLangValue;
begin
  Self.Caption := 'Giriþ';

  GDataBase.LoginText.ReadFromFile(GDataBase.ConnSetting.Language);

  lblLanguage.Caption := GDataBase.LoginText.Lang;
  lblUserName.Caption := GDataBase.LoginText.User;
  lblPassword.Caption := GDataBase.LoginText.UserPass;
  lblDBUserName.Caption := GDataBase.LoginText.DBUser;
  lblDBPassword.Caption := GDataBase.LoginText.DBPass;
  lblServer.Caption := GDataBase.LoginText.Server;
  lblServerExample.Caption := GDataBase.LoginText.Example;
  lblDatabase.Caption := GDataBase.LoginText.DBName;
  lblPortNo.Caption := GDataBase.LoginText.DBPort;
  lblSaveSettings.Caption := GDataBase.LoginText.SaveSettings;
  lbltheme_name.Caption := GDataBase.LoginText.ThemeName;
end;

procedure TfrmLogin.Repaint;
var
  LVisible: Boolean;
begin
  inherited;
  if Self.Height = FormSmall then
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

