unit StkKindProperty.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EStkKindPropertyException = class(EAppException);

  EStkKindPropertyExceptionKindUnique = class(EStkKindPropertyException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EStkKindPropertyExceptionKindUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TStkKindProperty.KindUnique, 'This kind already exists.');
end;

end.
