unit PrdLabour.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EPrdLabourException = class(EAppException);

  EPrdLabourExceptionCodeUnique = class(EPrdLabourException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EPrdLabourExceptionCodeUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPrdLabour.CodeUnique, 'This code already exists.');
end;

end.
