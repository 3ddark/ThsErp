unit FinMoneyLedger.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EFinMoneyLedgerException = class(EAppException);

  EFinMoneyLedgerExceptionReadOnly = class(EFinMoneyLedgerException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EFinMoneyLedgerExceptionReadOnly.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TFinMoneyLedger.ReadOnly, 'The statement is read-only. Use the transactions screen.');
end;

end.
