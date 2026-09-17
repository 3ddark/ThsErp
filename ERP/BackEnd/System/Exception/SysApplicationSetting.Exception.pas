unit SysApplicationSetting.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  ESysApplicationSettingException = class(EAppException);

  ESysApplicationSettingExceptionMustContainOnlyOneRecord = class(ESysApplicationSettingException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function ESysApplicationSettingExceptionMustContainOnlyOneRecord.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TMessage.MustContainOnlyOneRecord, 'It must contain only a single record.');
end;

end.
