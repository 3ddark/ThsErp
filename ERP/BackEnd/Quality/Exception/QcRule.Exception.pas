unit QcRule.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EQcRuleException = class(EAppException);

  EQcRuleExceptionTarget = class(EQcRuleException)
  protected
    class function GetMessage: string; override;
  end;

  EQcRuleExceptionGroupUnique = class(EQcRuleException)
  protected
    class function GetMessage: string; override;
  end;

  EQcRuleExceptionInventoryUnique = class(EQcRuleException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EQcRuleExceptionTarget.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TQcRule.Target, 'Select either a stock group or a stock card.');
end;

class function EQcRuleExceptionGroupUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TQcRule.GroupUnique, 'A rule already exists for this stock group.');
end;

class function EQcRuleExceptionInventoryUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TQcRule.InventoryUnique, 'A rule already exists for this stock card.');
end;

end.
