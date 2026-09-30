unit Password.Helper;

interface

uses
  System.SysUtils, BCrypt;

type
  TPasswordHelper = class
  private
    const DEFAULT_COST = 12; // Daha yüksek = daha güvenli ama daha yavaş
  public
    // Şifre kuralları — test/geliştirme aşamasında esnek (ör. '123' geçerli).
    // Canlıya geçerken: MIN_PASSWORD_LENGTH = 8, REQUIRE_COMPLEXITY = True
    const MIN_PASSWORD_LENGTH = 3;
    const MAX_PASSWORD_LENGTH = 128;
    const REQUIRE_COMPLEXITY: Boolean = False; // büyük + küçük harf + rakam zorunluluğu (tipli: kod elenmez)

    /// <summary>
    /// Düz metin şifreyi hash'ler (kayıt için)
    /// </summary>
    class function HashPassword(const APlainPassword: string): string;

    /// <summary>
    /// Kullanıcının girdiği şifreyi hash ile karşılaştırır (login için)
    /// </summary>
    class function VerifyPassword(const APlainPassword, AHashedPassword: string): Boolean;

    /// <summary>
    /// Şifre kuralı kontrolü: MIN/MAX_PASSWORD_LENGTH; REQUIRE_COMPLEXITY açıksa
    /// en az 1 büyük harf, 1 küçük harf, 1 rakam
    /// </summary>
    class function ValidatePasswordStrength(const APassword: string; out AErrorMessage: string): Boolean;
  end;

implementation

class function TPasswordHelper.HashPassword(const APlainPassword: string): string;
begin
  if APlainPassword.IsEmpty then
    raise Exception.Create('Şifre boş olamaz');

  // BCrypt ile hash oluştur
  Result := TBCrypt.HashPassword(APlainPassword, DEFAULT_COST);
end;

class function TPasswordHelper.VerifyPassword(const APlainPassword, AHashedPassword: string): Boolean;
var
  LNeedRecalculate: Boolean;
begin
  if APlainPassword.IsEmpty or AHashedPassword.IsEmpty then
    Exit(False);

  try
    // BCrypt hash doğrulaması
    Result := TBCrypt.CheckPassword(APlainPassword, AHashedPassword, LNeedRecalculate);
  except
    Result := False;
  end;
end;

class function TPasswordHelper.ValidatePasswordStrength(const APassword: string;
  out AErrorMessage: string): Boolean;
var
  HasUpper, HasLower, HasDigit: Boolean;
  I: Integer;
begin
  Result := False;
  AErrorMessage := '';

  // Minimum uzunluk kontrolü
  if Length(APassword) < MIN_PASSWORD_LENGTH then
  begin
    AErrorMessage := Format('Şifre en az %d karakter olmalıdır', [MIN_PASSWORD_LENGTH]);
    Exit;
  end;

  // Maksimum uzunluk kontrolü (güvenlik için)
  if Length(APassword) > MAX_PASSWORD_LENGTH then
  begin
    AErrorMessage := Format('Şifre en fazla %d karakter olabilir', [MAX_PASSWORD_LENGTH]);
    Exit;
  end;

  Result := True;

  // Karmaşıklık kuralı (REQUIRE_COMPLEXITY = False iken devre dışı)
  if REQUIRE_COMPLEXITY then
  begin
    HasUpper := False;
    HasLower := False;
    HasDigit := False;

    for I := 1 to Length(APassword) do
    begin
      if CharInSet(APassword[I], ['A'..'Z']) then
        HasUpper := True
      else if CharInSet(APassword[I], ['a'..'z']) then
        HasLower := True
      else if CharInSet(APassword[I], ['0'..'9']) then
        HasDigit := True;
    end;

    if not HasUpper then
      AErrorMessage := 'Şifre en az bir büyük harf içermelidir'
    else if not HasLower then
      AErrorMessage := 'Şifre en az bir küçük harf içermelidir'
    else if not HasDigit then
      AErrorMessage := 'Şifre en az bir rakam içermelidir';

    Result := AErrorMessage = '';
  end;
end;

end.
