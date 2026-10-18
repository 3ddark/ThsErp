unit EInvDocumentSetting.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EEInvDocumentSettingException = class(EAppException);

  EEInvDocumentSettingExceptionScopeUnique = class(EEInvDocumentSettingException)
  protected
    class function GetMessage: string; override;
  end;

  EEInvDocumentSettingExceptionSeriesScope = class(EEInvDocumentSettingException)
  protected
    class function GetMessage: string; override;
  end;

  EEInvDocumentSettingExceptionNoCompany = class(EEInvDocumentSettingException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EEInvDocumentSettingExceptionScopeUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TEInvDocumentSetting.ScopeUnique, 'This document type is already defined for the company.');
end;

class function EEInvDocumentSettingExceptionSeriesScope.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TEInvDocumentSetting.SeriesScope, 'The selected series belongs to another document type.');
end;

class function EEInvDocumentSettingExceptionNoCompany.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TEInvDocumentSetting.NoCompany, 'Company settings record not found.');
end;

end.
