unit StkGroup.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EStkGroupException = class(EAppException);

  EStkGroupExceptionNameUnique = class(EStkGroupException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EStkGroupExceptionNameUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TStkGroup.NameUnique, 'This stock group already exists.');
end;

end.
