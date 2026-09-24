unit ufrmLogin;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Classes, System.Generics.Collections, System.StrUtils,
  System.Rtti, System.Threading, Vcl.Controls, Vcl.Forms, Vcl.Samples.Spin,
  Vcl.StdCtrls, Vcl.Dialogs, Vcl.Menus, Vcl.Graphics, Vcl.AppEvnts,
  Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Themes, Vcl.Styles,
  Vcl.Imaging.pngimage, Winapi.Windows, FireDAC.Comp.Client, Logger,
  Ths.Helper.Edit, Ths.Helper.ComboBox, udm, ufrmBase,
  Ths.Database.Connection.Settings,

  AppContext, UserContext, Repository, LocalizationManager,
  ConnectionManager, UnitOfWork, FilterCriterion, Auth.Service,
  SysPermission.Repository, SysPermission, SysLanguage, SysLanguage.Repository,
  SysUser.Repository, SysAccessRight.Repository, SysAccessRight,
  SysGridColumn.Cache;

type
  TfrmLogin = class(TfrmBase)
    lblusername: TLabel;
    lbluser_password: TLabel;
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
    lblversion: TLabel;
    lblversion_val: TLabel;
    lbltheme: TLabel;
    cbbtheme: TComboBox;
    edtusername: TEdit;
    edtuser_password: TEdit;
    edtdb_kullanici: TEdit;
    edtdb_kullanici_sifre: TEdit;
    edtdb_host: TEdit;
    edtdb_adi: TEdit;
    edtdb_port: TEdit;
    chkayarlari_kaydet: TCheckBox;
    imglogo: TImage;
    pb1: TProgressBar;
    lbllanguage: TLabel;
    cbblanguage: TComboBox;
    procedure cbbthemeChange(Sender: TObject);
    procedure cbblanguageChange(Sender: TObject);
    procedure edtusernameDblClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject); override;
  private
    ConnSetting: TConnSettings;
  public
    class function Execute(): Boolean;
  published
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
    procedure btnAcceptClick(Sender: TObject); override;
    procedure Repaint; override;
    procedure ApplyLocalization; override;
  end;

const
  FormSmall = 246;
  FormBig = 430;

implementation

uses
  Ths.Constants, Ths.Globals, ufrmDashboard, Ths.Language.Cache;

{$R *.dfm}

class function TfrmLogin.Execute(): boolean;
begin
  with TfrmLogin.Create(nil) do
  try
    Result := (ShowModal = mrYes);
  finally
    Free;
  end;
end;

procedure TfrmLogin.btnAcceptClick(Sender: TObject);
var
  LConn    : TFDConnection;
  LUserRepo: TSysUserRepository;
  LLangRepo: IRepository<TSysLanguage>;
  LAuthSvc : TAuthService;
  LLoginRes: TLoginResult;
  LPerms   : TObjectDictionary<Integer, TSysAccessRight>;
  LLangs   : TArray<string>;
  LSelectedLang: string;

  procedure IncProgress;
  begin
    pb1.Position := pb1.Position + 1;
  end;

begin
  LLangs        := SplitString(cbblanguage.Text, '|');
  LSelectedLang := IfThen(Length(LLangs) > 1, Trim(LLangs[1]), 'tr-TR');
  TLocalizationManager.SetLanguage(LSelectedLang);
  ConnSetting.Language := LSelectedLang;

  if (edtusername.Text = '') or (edtuser_password.Text = '') then
    Exit;

  ConnSetting.Theme           := cbbtheme.Text;
  ConnSetting.SQLServer       := edtdb_host.Text;
  ConnSetting.DatabaseName    := edtdb_adi.Text;
  ConnSetting.DBUserName      := edtdb_kullanici.Text;
  ConnSetting.DBUserPassword  := edtdb_kullanici_sifre.Text;
  ConnSetting.DBPortNo        := StrToIntDef(edtdb_port.Text, 0);
  ConnSetting.UserName        := edtusername.Text;
  ConnSetting.UserPass        := edtuser_password.Text;

  try
    LConn := TConnectionManager.Instance.GetConnection(
      ContextMain,
      ConnSetting.SQLServer,
      ConnSetting.DatabaseName,
      ConnSetting.DBUserName,
      ConnSetting.DBUserPassword,
      ConnSetting.DBPortNo);
  except
    on E: Exception do
    begin
      ModalResult := mrNone;
      raise;
    end;
  end;

  if not LConn.Connected then Exit;

  GLogger.DBConnectionPID := TConnectionManager.Instance.GetConnectionPID(ContextMain).ToString;

  TUnitOfWork.Initialize(LConn);

  TLanguageCache.Load;
  TSysGridColumnCache.LoadGlobal(LConn);

  LAuthSvc  := TAuthService.Create;
  LUserRepo := TSysUserRepository.Create(LConn);
  try
    try
      LConn.ExecSQLScalar('SELECT set_config(''ths_erp.user_name'', :uname, false)', [edtusername.Text]);

      pb1.Max      := 11;
      pb1.Min      := 0;
      pb1.Position := 0;
      pb1.Visible  := True;

      TAppContext.Initialize(LConn);

      var LUserCtx := TUserContext.Create(nil, True);
      LUserCtx.ActiveLanguage := LSelectedLang;
      TAppContext.Instance.SetCurrentUser(LUserCtx);

      IncProgress;

      LLoginRes := LAuthSvc.Login(edtusername.Text, edtuser_password.Text);

      case LLoginRes.Status of
        lsUserNotFound:
          raise Exception.Create(
            TLocalizationManager.Translate(TLangKeys.TLogin.UserNotFound, [edtusername.Text], edtusername.Text + ': böyle bir kullanıcı yok'));

        lsInactiveUser:
          raise Exception.Create(
            TLocalizationManager.Translate(TLangKeys.TLogin.UserInactive, [edtusername.Text], edtusername.Text + ' kullanıcısı aktif değil!'));

        lsInvalidPassword:
          raise Exception.Create(
            TLocalizationManager.Translate(TLangKeys.TLogin.InvalidPassword, 'Geçersiz Kullanıcı Şifresi!'));

        lsInvalidAppVersion:
        begin
          Application.MessageBox(
            PChar(TLocalizationManager.Translate(TLangKeys.TLogin.UpdateAvailable, 'Yeni bir güncellemeniz var.')),
            PChar(TLocalizationManager.Translate(TLangKeys.TLogin.UpdateTitle, 'Güncelleme')),
            MB_ICONINFORMATION);
          TfrmDashboard(Application.MainForm).UpdateApplicationExe;
          Exit;
        end;

        lsSuccess: ;
      else
        raise Exception.Create(LLoginRes.ErrorMessage);
      end;

      IncProgress;

      LLangRepo := TUnitOfWork.Instance.GetRepository<TSysLanguage, TSysLanguageRepository>();

      var LFilter := TFilterCriteria.Create;
      try
        LFilter.Add(TFilterCriterion.New('locale', '=', TValue.From<string>(LSelectedLang)));
        var LLang := LLangRepo.FindOne(LFilter);
        try
          if not Assigned(LLang) then
            raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TLogin.UserNotFound, 'Dil bulunamadı'));

          var LUser := LUserRepo.FindById(TValue.From<Int64>(LLoginRes.UserId), False);

          TAppContext.Instance.CurrentUser.User          := LUser;
          TAppContext.Instance.CurrentUser.ActiveLanguageId := LLang.Id;
        finally
          LLang.Free;
        end;
      finally
        LFilter.Free;
      end;

      IncProgress;

      var LAccessRepo := TSysAccessRightRepository.Create(LConn);
      try
        LPerms := LAccessRepo.GetUserPermissions(TValue.From<Int64>(LLoginRes.UserId));
        try
          TAppContext.Instance.CurrentUser.AddPermissions(LPerms);
        finally
          LPerms.Free;
        end;
      finally
        LAccessRepo.Free;
      end;

      TSysGridColumnCache.LoadUser(LConn, LLoginRes.UserId);

      IncProgress;

      ModalResult := mrYes;

      ConnSetting.Language := LSelectedLang;
      if TLanguageCache.IsLoaded then
        ConnSetting.SaveSupportedLanguages(TLanguageCache.GetLocales);

      if chkayarlari_kaydet.Checked then
        ConnSetting.SaveToFile
      else
        ConnSetting.SaveToFile(True);

    except
      pb1.Visible := False;
      raise;
    end;
  finally
    LAuthSvc.Free;
    LUserRepo.Free;
  end;
end;

procedure TfrmLogin.cbbthemeChange(Sender: TObject);
begin
  TStyleManager.TrySetStyle(cbbtheme.Text, False);
end;

procedure TfrmLogin.cbblanguageChange(Sender: TObject);
var
  LLangs: TArray<string>;
  LSelectedLang: string;
begin
  LLangs := SplitString(cbblanguage.Text, '|');
  LSelectedLang := IfThen(Length(LLangs) > 1, Trim(LLangs[1]), 'tr-TR');
  TLocalizationManager.SetLanguage(LSelectedLang);
  if Assigned(ConnSetting) then
  begin
    ConnSetting.Language := LSelectedLang;
    ConnSetting.SaveToFile(True);
  end;
  ApplyLocalization;
end;

procedure TfrmLogin.edtusernameDblClick(Sender: TObject);
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
  LTargetLang: string;
  LFoundIdx: Integer;
  LParts: TArray<string>;
begin
  inherited;

  ConnSetting := TConnSettings.Create;
  ConnSetting.ReadFromFile;

  Self.Height := scaleBySystemDPI(FormSmall);
  Repaint;

  dm.illogo.GetIcon(0, imglogo.Picture.Icon);

  cbbtheme.Clear;
  for n1 := 0 to Length(TStyleManager.StyleNames) - 1 do
    cbbtheme.Items.Add(TStyleManager.StyleNames[n1]);
  cbbtheme.ItemIndex := cbbtheme.Items.IndexOf(ConnSetting.Theme);
  if (cbbtheme.Items.Count > 0) and (cbbtheme.Text = '') then
    cbbtheme.ItemIndex := 0;

  if cbbtheme.Text <> '' then
    TStyleManager.TrySetStyle(cbbtheme.Text);

  cbblanguage.Items.BeginUpdate;
  try
    cbblanguage.Clear;
    ConnSetting.ReadSupportedLanguages(cbblanguage.Items);
    if cbblanguage.Items.Count = 0 then
    begin
      if TLocalizationManager.LanguageFileExists('tr-TR') then
        cbblanguage.Items.Add('Turkce | tr-TR');
      if TLocalizationManager.LanguageFileExists('en-US') then
        cbblanguage.Items.Add('English | en-US');
    end;
  finally
    cbblanguage.Items.EndUpdate;
  end;

  LTargetLang := ConnSetting.Language;
  if LTargetLang = '' then
    LTargetLang := 'tr-TR';

  LFoundIdx := -1;
  for n1 := 0 to cbblanguage.Items.Count - 1 do
  begin
    LParts := SplitString(cbblanguage.Items[n1], '|');
    if Length(LParts) > 1 then
    begin
      if SameText(Trim(LParts[1]), LTargetLang) then
      begin
        LFoundIdx := n1;
        Break;
      end;
    end
    else if SameText(Trim(cbblanguage.Items[n1]), LTargetLang) then
    begin
      LFoundIdx := n1;
      Break;
    end;
  end;

  if LFoundIdx >= 0 then
    cbblanguage.ItemIndex := LFoundIdx
  else
    cbblanguage.ItemIndex := 0;

  cbblanguageChange(nil);

  edtusername.CharCase := ecUpperCase;

  btnAccept.Visible := True;
  btnClose.Visible := True;
  btnDelete.Visible := False;
  btnSpin.Visible := False;

  {$IFDEF DEBUG}
  edtusername.Text := ConnSetting.UserName;
  edtuser_password.Text := ConnSetting.UserPass;
  {$ELSE}
  edtusername.Clear;
  edtuser_password.Clear;
  {$ENDIF}
  edtdb_kullanici.Text := ConnSetting.DBUserName;
  edtdb_kullanici_sifre.Text := ConnSetting.DBUserPassword;
  edtdb_host.Text := ConnSetting.SQLServer;
  edtdb_adi.Text := ConnSetting.DatabaseName;
  edtdb_port.Text := ConnSetting.DBPortNo.ToString;

  TTask.Run(
    procedure
    begin
      TThread.Synchronize(nil,
        procedure
        var
          n1: Integer;
          LList: TNetworkCardInfoList;
          LLen: Integer;
        begin

          lblip_address_val.Caption := '';
          LList := GetMACAddress;
          LLen := Length(LList);
          for n1 := 0 to LLen - 1 do
            lblip_address_val.Caption := lblip_address_val.Caption + LList[n1].IPAddress + AddLBs + LList[n1].MacAddress + AddLBs(2);

        end
      );
    end);
end;

procedure TfrmLogin.FormDestroy(Sender: TObject);
begin
  ConnSetting.Free;
  inherited;
end;

procedure TfrmLogin.FormShow(Sender: TObject);
begin
  inherited;

  lblprocess_id_val.Caption := GetPIDByHWnd(Application.Handle).ToString;
  lblversion_val.Caption := APP_VERSION;
end;

procedure TfrmLogin.Repaint;
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

procedure TfrmLogin.ApplyLocalization;
begin
  inherited;
  Caption := TLocalizationManager.Translate(TLangKeys.TLogin.WindowTitle, 'System Login');

  lblusername.Caption           := TLocalizationManager.Translate(TLangKeys.TLogin.Username, 'User Name');
  lbluser_password.Caption      := TLocalizationManager.Translate(TLangKeys.TLogin.Password, 'Password');
  lbldb_host.Caption            := TLocalizationManager.Translate(TLangKeys.TLogin.DbHost, 'Database Server IP');
  lblsuncu_ornek.Caption        := TLocalizationManager.Translate(TLangKeys.TLogin.DbHostHint, 'Server Example: 192.168.1.100 / localhost / 127.0.0.1');
  lbldb_adi.Caption             := TLocalizationManager.Translate(TLangKeys.TLogin.DbName, 'Database Name');
  lbldb_port.Caption            := TLocalizationManager.Translate(TLangKeys.TLogin.DbPort, 'Database Port');
  lblayarlari_kaydet.Caption    := TLocalizationManager.Translate(TLangKeys.TLogin.SaveSettings, 'Save Settings');
  lbldb_kullanici.Caption       := TLocalizationManager.Translate(TLangKeys.TLogin.DbUser, 'Database User');
  lbldb_kullanici_sifre.Caption := TLocalizationManager.Translate(TLangKeys.TLogin.DbPassword, 'Database Password');
  lblprocess_id.Caption         := TLocalizationManager.Translate(TLangKeys.TLogin.ProcessId, 'Process ID');
  lblip_address.Caption         := TLocalizationManager.Translate(TLangKeys.TLogin.IpAddress, 'IP Address');
  lblversion.Caption            := TLocalizationManager.Translate(TLangKeys.TLogin.Version, 'Version');
  lbltheme.Caption              := TLocalizationManager.Translate(TLangKeys.TLogin.Theme, 'Theme');
  lbllanguage.Caption           := TLocalizationManager.Translate(TLangKeys.TLogin.Language, 'Language');

  if Assigned(btnAccept) then
    btnAccept.Caption := TLocalizationManager.Translate(TLangKeys.TGeneral.Login, 'Login');
end;

end.

