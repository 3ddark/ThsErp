unit QcSetting.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EQcSettingException = class(EAppException);

  EQcSettingExceptionNoCompany = class(EQcSettingException)
  protected
    class function GetMessage: string; override;
  end;

  EQcSettingExceptionUnique = class(EQcSettingException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EQcSettingExceptionNoCompany.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TQcSetting.NoCompany, 'Company settings were not found.');
end;

class function EQcSettingExceptionUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TQcSetting.SettingUnique, 'Quality control settings already exist for this company.');
end;

end.
