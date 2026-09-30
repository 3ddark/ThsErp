unit StkKindFamily.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EStkKindFamilyException = class(EAppException);

  EStkKindFamilyExceptionFamilyUnique = class(EStkKindFamilyException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EStkKindFamilyExceptionFamilyUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TStkKindFamily.FamilyUnique, 'This kind family already exists.');
end;

end.
