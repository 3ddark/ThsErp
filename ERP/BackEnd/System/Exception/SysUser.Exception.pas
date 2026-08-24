unit SysUser.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  ESysUserException = class(EAppException);

  ESysUserExceptionUsernameUnique = class(ESysUserException)
  protected
    class function GetMessage: string; override;
  end;

implementation


class function ESysUserExceptionUsernameUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSysUser.UsernameUnique, 'Username kullanıcıya zaten atanmış. Tekrar atanamaz.');
end;

end.
