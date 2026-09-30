unit AccAccountPlan.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EAccAccountPlanException = class(EAppException);

  EAccAccountPlanExceptionCodeUnique = class(EAccAccountPlanException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EAccAccountPlanExceptionCodeUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TAccAccountPlan.CodeUnique, 'This account plan code already exists.');
end;

end.
