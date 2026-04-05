unit ufrmLogin;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Classes, System.Generics.Collections, Vcl.Controls,
  Vcl.Forms, Vcl.Samples.Spin, Vcl.StdCtrls, Vcl.Dialogs, Vcl.Graphics,
  Vcl.AppEvnts, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Menus, Vcl.Themes, Vcl.Styles,
  Vcl.Imaging.pngimage, Winapi.Windows, FireDAC.Comp.Client, Logger,
  Ths.Helper.Edit, Ths.Helper.ComboBox, udm, ufrmBase,
  Ths.Database.Connection.Settings,

  AppContext, UserContext, Repository,
  ConnectionManager, UnitOfWork, FilterCriterion, Auth.Service, SysUser.Repository,
  SysPermission.Repository, SysPermission;

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
    procedure cbbthemeChange(Sender: TObject);
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
  end;

const
  FormSmall = 246;
  FormBig = 430;

implementation

uses
  Ths.Constants, Ths.Globals, ufrmDashboard;

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
  LConn: TFDConnection;

  LUserRepo: TSysUserRepository;
  LAuthSvc: TAuthService;
  LLoginRes: TLoginResult;

  procedure IncProgress;
  begin
    pb1.Position := pb1.Position + 1;
  end;

begin
  if (edtusername.Text = '') or (edtuser_password.Text = '') then
    Exit;

  try
    ConnSetting.Theme := cbbtheme.Text;
    ConnSetting.SQLServer := edtdb_host.Text;
    ConnSetting.DatabaseName := edtdb_adi.Text;
    ConnSetting.DBUserName := edtdb_kullanici.Text;
    ConnSetting.DBUserPassword := edtdb_kullanici_sifre.Text;
    ConnSetting.DBPortNo := StrToIntDef(edtdb_port.Text, 0);
    ConnSetting.UserName := edtusername.Text;
    ConnSetting.UserPass := edtuser_password.Text;

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
      Exit;
    end;
  end;

  if LConn.Connected then
  begin
    GLogger.DBConnectionPID := TConnectionManager.Instance.GetConnectionPID(ContextMain).ToString;

    TUnitOfWork.Initialize(LConn);

    LAuthSvc := TAuthService.Create;
    LUserRepo := TSysUserRepository.Create(LConn);
    try
      try
        LConn.ExecSQL('SET ths_erp.user_name = ' + QuotedStr(edtusername.Text));

        pb1.Max := 11;
        pb1.Min := 0;
        pb1.Position := 0;
        pb1.Visible := True;

        LLoginRes := LAuthSvc.Login(edtusername.Text, edtuser_password.Text);
        if LLoginRes.UserId = Ord(TLoginStatus.lsUserNotFound) then
          raise Exception.Create(edtusername.Text + ': böyle bir kullanıcı yok')
        else if LLoginRes.UserId = Ord(TLoginStatus.lsInactiveUser) then
          raise Exception.Create(edtusername.Text + ' kullanıcısı aktif değil!')
        else if LLoginRes.UserId = Ord(TLoginStatus.lsInvalidPassword) then
          raise Exception.Create('Geçersiz Kullanıcı Şifresi!')
        else if LLoginRes.UserId = Ord(TLoginStatus.lsInvalidAppVersion) then
        begin
          Application.MessageBox('Yeni bir güncellemeniz var.', 'Güncelleme', MB_ICONINFORMATION);
          TfrmDashboard(Application.MainForm).UpdateApplicationExe();
          Exit;
        end;


        var user := LUserRepo.FindById(LLoginRes.UserId, False, [ioIncludeParent]);

        TAppContext.Initialize(LConn);

        TAppContext.Instance.SetCurrentUser(TUserContext.Create(user));

        ModalResult := mrYes;

        if chkayarlari_kaydet.Checked then
          ConnSetting.SaveToFile
        else
          ConnSetting.SaveToFile(True);
      except
        pb1.Visible := False;
      end;
    finally
      LAuthSvc.Free;
      LUserRepo.Free;
    end;
  end;
end;

procedure TfrmLogin.cbbthemeChange(Sender: TObject);
begin
  TStyleManager.TrySetStyle(cbbtheme.Text, False);
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

  edtusername.CharCase := ecUpperCase;

  btnAccept.Visible := True;
  btnClose.Visible := True;
  btnDelete.Visible := False;
  btnSpin.Visible := False;

  {$IFDEF DEBUG}
  edtusername.Text := ConnSetting.UserName;
  edtuser_password.Text := ConnSetting.UserPass;
  {$ELSE}
  edtkullanici_adi.Clear;
  edtkullanici_sifresi.Clear;
  {$ENDIF}
  edtdb_kullanici.Text := ConnSetting.DBUserName;
  edtdb_kullanici_sifre.Text := ConnSetting.DBUserPassword;
  edtdb_host.Text := ConnSetting.SQLServer;
  edtdb_adi.Text := ConnSetting.DatabaseName;
  edtdb_port.Text := ConnSetting.DBPortNo.ToString;
end;

procedure TfrmLogin.FormDestroy(Sender: TObject);
begin
  ConnSetting.Free;
  inherited;
end;

procedure TfrmLogin.FormShow(Sender: TObject);
var
  n1: Integer;
  LList: TNetworkCardInfoList;
  LLen: Integer;
begin
  inherited;

  lblprocess_id_val.Caption := GetPIDByHWnd(Application.Handle).ToString;
  lblversion_val.Caption := APP_VERSION;

  lblip_address_val.Caption := '';
  LList := GetMACAddress;
  LLen := Length(LList);
  for n1 := 0 to LLen - 1 do
    lblip_address_val.Caption := lblip_address_val.Caption + LList[n1].IPAddress + AddLBs + LList[n1].MacAddress + AddLBs(2);
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

end.

