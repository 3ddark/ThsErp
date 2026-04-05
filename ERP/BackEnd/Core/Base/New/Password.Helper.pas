unit Password.Helper;

interface

uses
  System.SysUtils, BCrypt;

type
  TPasswordHelper = class
  private
    const DEFAULT_COST = 12; // Daha yüksek = daha güvenli ama daha yavaş
  public
    /// <summary>
    /// Düz metin şifreyi hash'ler (kayıt için)
    /// </summary>
    class function HashPassword(const APlainPassword: string): string;

    /// <summary>
    /// Kullanıcının girdiği şifreyi hash ile karşılaştırır (login için)
    /// </summary>
    class function VerifyPassword(const APlainPassword, AHashedPassword: string): Boolean;

    /// <summary>
    /// Şifre karmaşıklığı kontrolü
    /// Min 8 karakter, en az 1 büyük harf, 1 küçük harf, 1 rakam
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
    if LNeedRecalculate then
      Result := False;
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
  if Length(APassword) < 8 then
  begin
    AErrorMessage := 'Şifre en az 8 karakter olmalıdır';
    Exit;
  end;

  // Maksimum uzunluk kontrolü (güvenlik için)
  if Length(APassword) > 128 then
  begin
    AErrorMessage := 'Şifre en fazla 128 karakter olabilir';
    Exit;
  end;

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
    AErrorMessage := 'Şifre en az bir rakam içermelidir'
  else
    Result := True;
end;

end.
