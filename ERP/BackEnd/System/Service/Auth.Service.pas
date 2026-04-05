unit Auth.Service;

interface

uses
  System.Classes, System.Generics.Collections, System.SysUtils,
  FireDAC.Comp.Client, FireDAC.Stan.Param, Data.DB,
  Logger, Password.Helper, ConnectionManager, Repository, Service, FilterCriterion,
  SysUser, SysUser.Repository;

type
  TLoginStatus = (
    lsSuccess = 0,
    lsUserNotFound = -1,
    lsInactiveUser = -2,
    lsInvalidAppVersion = -3,
    lsInvalidPassword = -4,
    lsAccountLocked = -5
  );

  TLoginResult = record
    UserId: Int64;
    Username: string;
    IsManager: Boolean;
    IsSuperUser: Boolean;
    Success: Boolean;
    Status: TLoginStatus;
    ErrorMessage: string;
    class function Create: TLoginResult; static;
  end;

  TRegisterResult = record
    UserId: Int64;
    Success: Boolean;
    ErrorMessage: string;
    class function Create: TRegisterResult; static;
  end;

  TAuthService = class(TService<TSysUser>)
  public
    function Login(const AUserName, AUserPassword: string): TLoginResult;
    function Register(AUser: TSysUser): TRegisterResult;
    function ChangePassword(AUserId: Int64; const AOldPassword, ANewPassword: string): Boolean;
    function ResetPassword(AUserId: Int64; const ANewPassword: string): Boolean;
    function SetUserActive(AUserId: Int64; AActive: Boolean): Boolean;
  end;

implementation

class function TLoginResult.Create: TLoginResult;
begin
  Result.UserId := 0;
  Result.Username := '';
  Result.IsManager := False;
  Result.IsSuperUser := False;
  Result.Success := False;
  Result.Status := lsUserNotFound;
  Result.ErrorMessage := '';
end;

class function TRegisterResult.Create: TRegisterResult;
begin
  Result.UserId := 0;
  Result.Success := False;
  Result.ErrorMessage := '';
end;

function TAuthService.Login(const AUserName, AUserPassword: string): TLoginResult;
var
  LUser: TSysUser;
  LPasswordValid: Boolean;
  LRepo: IRepository<TSysUser>;
begin
  Result := TLoginResult.Create;
  GLogger.InfoFmt('Login denemesi: %s', [AUserName]);
  try
    LRepo := Self.UoW.GetRepository<TSysUser, TSysUserRepository>;

    Filter.Clear;
    Filter.Add(TFilterCriterion.New('Username', '=', AUserName));
    LUser := LRepo.FindOne(Filter);
    if LUser = nil then
    begin
      Result.Status := lsUserNotFound;
      Result.ErrorMessage := 'Kullanıcı bulunamadı';
      GLogger.WarningFmt('Login başarısız: Kullanıcı bulunamadı [%s]', [AUserName]);
      Exit;
    end;

    try
      if not LUser.Active then
      begin
        Result.Status := lsInactiveUser;
        Result.ErrorMessage := 'Kullanıcı hesabı aktif değil';
        GLogger.WarningFmt('Login başarısız: Hesap aktif değil [%s]', [AUserName]);
        Exit;
      end;
      //LUser.UserPassword := TPasswordHelper.HashPassword(AUserPassword);
      LPasswordValid := TPasswordHelper.VerifyPassword(AUserPassword, LUser.UserPassword);

      if not LPasswordValid then
      begin
        Result.Status := lsInvalidPassword;
        Result.ErrorMessage := 'Geçersiz şifre';
        GLogger.WarningFmt('Login başarısız: Geçersiz şifre [%s]', [AUserName]);
        Exit;
      end;

      Result.Success := True;
      Result.Status := lsSuccess;
      Result.UserId := LUser.Id;
      Result.Username := LUser.Username;
      Result.IsManager := LUser.Manager;
      Result.IsSuperUser := LUser.SuperUser;
      Result.ErrorMessage := 'Giriş başarılı';

      GLogger.InfoFmt('Login başarılı: %s (ID: %d)', [AUserName, LUser.Id]);
    finally
      LUser.Free;
    end;
  except
    on E: Exception do
    begin
      Result.Status := lsInvalidPassword;
      Result.ErrorMessage := 'Beklenmeyen hata: ' + E.Message;
      GLogger.ErrorLog(E, Format('Login hatası [%s]', [AUserName]));
    end;
  end;
end;

function TAuthService.Register(AUser: TSysUser): TRegisterResult;
var
  LHashedPassword: string;
  LErrorMsg: string;
//  LNewUser,
  LExistingUser: TSysUser;
  LRepo: IRepository<TSysUser>;
begin
  Result := TRegisterResult.Create;
  GLogger.InfoFmt('Kayıt denemesi: %s', [AUser.Username]);
  try
    if AUser.Username.Trim.IsEmpty then
    begin
      Result.ErrorMessage := 'Kullanıcı adı boş olamaz';
      GLogger.Warning('Kayıt başarısız: Kullanıcı adı boş');
      Exit;
    end;

    if not TPasswordHelper.ValidatePasswordStrength(AUser.UserPassword, LErrorMsg) then
    begin
      Result.ErrorMessage := LErrorMsg;
      GLogger.WarningFmt('Kayıt başarısız: %s [%s]', [LErrorMsg, AUser.Username]);
      Exit;
    end;

    LRepo := Self.UoW.GetRepository<TSysUser, TSysUserRepository>;

    Filter.Clear;
    Filter.Add(TFilterCriterion.New('Username', '=', AUser.Username));
    LExistingUser := LRepo.FindOne(Filter);
    if LExistingUser <> nil then
    begin
      LExistingUser.Free;
      Result.ErrorMessage := 'Bu kullanıcı adı zaten kullanımda';
      GLogger.WarningFmt('Kayıt başarısız: Kullanıcı adı mevcut [%s]', [AUser.Username]);
      Exit;
    end;

    LHashedPassword := TPasswordHelper.HashPassword(AUser.UserPassword);

    AUser := TSysUser.Create;
    AUser.UserPassword := LHashedPassword;

    LRepo.Add(AUser);
    Result.UserId := AUser.Id;

    if Result.UserId > 0 then
    begin
      Result.Success := True;
      Result.ErrorMessage := 'Kayıt başarılı';
      GLogger.InfoFmt('Kayıt başarılı: %s (ID: %d)', [AUser.Username, Result.UserId]);
    end
    else
    begin
      Result.ErrorMessage := 'Kullanıcı oluşturulamadı';
      GLogger.ErrorFmt('Kayıt başarısız: Kullanıcı oluşturulamadı [%s]', [AUser.Username]);
    end;
  except
    on E: Exception do
    begin
      Result.ErrorMessage := 'Beklenmeyen hata: ' + E.Message;
      GLogger.ErrorLog(E, Format('Kayıt hatası [%s]', [AUser.Username]));
    end;
  end;
end;

function TAuthService.ChangePassword(AUserId: Int64; const AOldPassword, ANewPassword: string): Boolean;
var
  LQuery: TFDQuery;
  LConn: TFDConnection;
  LCurrentHash, LNewHash: string;
  LErrorMsg: string;
begin
  Result := False;
  GLogger.InfoFmt('Şifre değiştirme: UserID=%d', [AUserId]);
  try
    if not TPasswordHelper.ValidatePasswordStrength(ANewPassword, LErrorMsg) then
    begin
      GLogger.WarningFmt('Şifre değiştirme başarısız: %s [UserID=%d]', [LErrorMsg, AUserId]);
      Exit;
    end;

    LConn := TConnectionManager.Instance.GetConnection(ContextMain);
    LQuery := TFDQuery.Create(nil);
    try
      LQuery.Connection := LConn;
      LQuery.SQL.Text := 'SELECT user_password FROM sys_users WHERE id = :id';
      LQuery.ParamByName('id').AsLargeInt := AUserId;
      LQuery.Open;

      if LQuery.IsEmpty then
      begin
        GLogger.WarningFmt('Şifre değiştirme: Kullanıcı bulunamadı [UserID=%d]', [AUserId]);
        Exit;
      end;

      LCurrentHash := LQuery.FieldByName('user_password').AsString;

      if not TPasswordHelper.VerifyPassword(AOldPassword, LCurrentHash) then
      begin
        GLogger.WarningFmt('Şifre değiştirme: Eski şifre yanlış [UserID=%d]', [AUserId]);
        Exit;
      end;

      LNewHash := TPasswordHelper.HashPassword(ANewPassword);

      LQuery.Close;
      LQuery.SQL.Text := 'UPDATE sys_users SET user_password = :password WHERE id = :id';
      LQuery.ParamByName('password').AsString := LNewHash;
      LQuery.ParamByName('id').AsLargeInt := AUserId;
      LQuery.ExecSQL;

      Result := True;
      GLogger.InfoFmt('Şifre başarıyla değiştirildi [UserID=%d]', [AUserId]);

    finally
      LQuery.Free;
    end;

  except
    on E: Exception do
      GLogger.ErrorLog(E, Format('Şifre değiştirme hatası [UserID=%d]', [AUserId]));
  end;
end;

function TAuthService.ResetPassword(AUserId: Int64; const ANewPassword: string): Boolean;
var
  LQuery: TFDQuery;
  LConn: TFDConnection;
  LNewHash: string;
  LErrorMsg: string;
begin
  Result := False;
  GLogger.InfoFmt('Şifre sıfırlama: UserID=%d', [AUserId]);
  try
    if not TPasswordHelper.ValidatePasswordStrength(ANewPassword, LErrorMsg) then
    begin
      GLogger.WarningFmt('Şifre sıfırlama başarısız: %s [UserID=%d]', [LErrorMsg, AUserId]);
      Exit;
    end;

    LNewHash := TPasswordHelper.HashPassword(ANewPassword);

    LConn := TConnectionManager.Instance.GetConnection(ContextMain);
    LQuery := TFDQuery.Create(nil);
    try
      LQuery.Connection := LConn;
      LQuery.SQL.Text := 'UPDATE sys_users SET user_password = :password WHERE id = :id';
      LQuery.ParamByName('password').AsString := LNewHash;
      LQuery.ParamByName('id').AsLargeInt := AUserId;
      LQuery.ExecSQL;

      Result := LQuery.RowsAffected > 0;

      if Result then
        GLogger.InfoFmt('Şifre başarıyla sıfırlandı [UserID=%d]', [AUserId])
      else
        GLogger.WarningFmt('Şifre sıfırlama: Kullanıcı bulunamadı [UserID=%d]', [AUserId]);
    finally
      LQuery.Free;
    end;
  except
    on E: Exception do
      GLogger.ErrorLog(E, Format('Şifre sıfırlama hatası [UserID=%d]', [AUserId]));
  end;
end;

function TAuthService.SetUserActive(AUserId: Int64; AActive: Boolean): Boolean;
var
  LQuery: TFDQuery;
  LConn: TFDConnection;
begin
  Result := False;
  GLogger.InfoFmt('Kullanıcı aktiflik değiştirme: UserID=%d, Active=%s', [AUserId, BoolToStr(AActive, True)]);
  try
    LConn := TConnectionManager.Instance.GetConnection(ContextMain);
    LQuery := TFDQuery.Create(nil);
    try
      LQuery.Connection := LConn;
      LQuery.SQL.Text := 'UPDATE sys_users SET active = :active WHERE id = :id';
      LQuery.ParamByName('active').AsBoolean := AActive;
      LQuery.ParamByName('id').AsLargeInt := AUserId;
      LQuery.ExecSQL;

      Result := LQuery.RowsAffected > 0;

      if Result then
        GLogger.InfoFmt('Kullanıcı aktiflik durumu değiştirildi [UserID=%d]', [AUserId])
      else
        GLogger.WarningFmt('Aktiflik değiştirme: Kullanıcı bulunamadı [UserID=%d]', [AUserId]);
    finally
      LQuery.Free;
    end;
  except
    on E: Exception do
      GLogger.ErrorLog(E, Format('Aktiflik değiştirme hatası [UserID=%d]', [AUserId]));
  end;
end;

end.
