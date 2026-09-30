unit SysPermissionTemplate.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  ESysPermissionTemplateException = class(EAppException);

  ESysPermissionTemplateExceptionKeyUnique = class(ESysPermissionTemplateException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function ESysPermissionTemplateExceptionKeyUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSysPermissionTemplate.TemplateKeyUnique, 'This template key already exists.');
end;

end.
