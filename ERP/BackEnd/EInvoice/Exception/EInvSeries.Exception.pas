unit EInvSeries.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EEInvSeriesException = class(EAppException);

  EEInvSeriesExceptionCodeUnique = class(EEInvSeriesException)
  protected
    class function GetMessage: string; override;
  end;

  EEInvSeriesExceptionInUse = class(EEInvSeriesException)
  protected
    class function GetMessage: string; override;
  end;

  EEInvSeriesExceptionCodeFormat = class(EEInvSeriesException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EEInvSeriesExceptionCodeUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TEInvSeries.CodeUnique, 'This code already exists.');
end;

class function EEInvSeriesExceptionInUse.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TEInvSeries.InUse, 'This record is in use. Make it passive instead of deleting it.');
end;

class function EEInvSeriesExceptionCodeFormat.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TEInvSeries.CodeFormat, 'Series code must be 3 characters (A-Z, 0-9).');
end;

end.
