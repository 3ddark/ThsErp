unit SysUserPermissionTemplate.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  ESysUserPermissionTemplateException = class(EAppException);

  ESysUserPermissionTemplateExceptionUnique = class(ESysUserPermissionTemplateException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function ESysUserPermissionTemplateExceptionUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSysUserPermissionTemplate.UserTemplateUnique, 'This template is already assigned to the user.');
end;

end.
