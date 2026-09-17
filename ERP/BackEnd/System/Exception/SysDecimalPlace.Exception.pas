unit SysDecimalPlace.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  ESysDecimalPlaceException = class(EAppException);

  ESysDecimalPlaceExceptionMustContainOnlyOneRecord = class(ESysDecimalPlaceException)
  protected
    class function GetMessage: string; override;
  end;

  ESysDecimalPlaceExceptionNegativeValueNotAllowed = class(ESysDecimalPlaceException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function ESysDecimalPlaceExceptionMustContainOnlyOneRecord.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TMessage.MustContainOnlyOneRecord, 'It must contain only a single record.');
end;

class function ESysDecimalPlaceExceptionNegativeValueNotAllowed.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TValidation.NegativeValueNotAllowed, 'It cannot be a negative value.');
end;

end.
