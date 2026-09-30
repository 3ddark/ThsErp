unit AccGroup.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EAccGroupException = class(EAppException);

  EAccGroupExceptionNameUnique = class(EAccGroupException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EAccGroupExceptionNameUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TAccGroup.NameUnique, 'This account group already exists.');
end;

end.
