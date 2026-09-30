unit SysPermissionTemplateRight.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  ESysPermissionTemplateRightException = class(EAppException);

  ESysPermissionTemplateRightExceptionUnique = class(ESysPermissionTemplateRightException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function ESysPermissionTemplateRightExceptionUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSysPermissionTemplateRight.TemplatePermissionUnique, 'This permission is already defined in the template.');
end;

end.
