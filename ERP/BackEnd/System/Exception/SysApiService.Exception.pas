unit SysApiService.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  ESysApiServiceException = class(EAppException);

  ESysApiServiceExceptionKindUnique = class(ESysApiServiceException)
  protected
    class function GetMessage: string; override;
  end;

  ESysApiServiceExceptionKindInvalid = class(ESysApiServiceException)
  protected
    class function GetMessage: string; override;
  end;

  ESysApiServiceExceptionOptionsInvalid = class(ESysApiServiceException)
  protected
    class function GetMessage: string; override;
  end;

  ESysApiServiceExceptionTimeoutRange = class(ESysApiServiceException)
  protected
    class function GetMessage: string; override;
  end;

  ESysApiServiceExceptionNoCompany = class(ESysApiServiceException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function ESysApiServiceExceptionKindUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSysApiService.KindUnique, 'This service type is already defined for the company.');
end;

class function ESysApiServiceExceptionKindInvalid.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSysApiService.KindInvalid, 'Service type must be 2-32 lowercase letters / digits / _ and start with a letter (e.g. einvoice).');
end;

class function ESysApiServiceExceptionOptionsInvalid.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSysApiService.OptionsInvalid, 'Provider options must be a JSON object, e.g. {"branch": "default"}.');
end;

class function ESysApiServiceExceptionTimeoutRange.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSysApiService.TimeoutRange, 'Timeout must be between 1 and 3600 seconds.');
end;

class function ESysApiServiceExceptionNoCompany.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSysApiService.NoCompany, 'Company settings record not found.');
end;

end.
