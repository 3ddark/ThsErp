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
  Result := TLocalizationManager.Translate(TLangKeys.TSysUser.UsernameUnique, 'The username has already been assigned to the user. It cannot be assigned again.');
end;

end.
