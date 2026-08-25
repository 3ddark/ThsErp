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
  Result := TLocalizationManager.Translate(TLangKeys.TMessage.MustContainOnlyOneRecord, 'Yalnýzca tek bir kayýt içermelidir');
end;

class function ESysDecimalPlaceExceptionNegativeValueNotAllowed.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TValidation.NegativeValueNotAllowed, 'Negatif deðer olamaz');
end;

end.
