unit FinPosTerminal.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EFinPosTerminalException = class(EAppException);

  EFinPosTerminalExceptionNameUnique = class(EFinPosTerminalException)
  protected
    class function GetMessage: string; override;
  end;

  EFinPosTerminalExceptionHasTransactions = class(EFinPosTerminalException)
  protected
    class function GetMessage: string; override;
  end;

  EFinPosTerminalExceptionRateRange = class(EFinPosTerminalException)
  protected
    class function GetMessage: string; override;
  end;

  EFinPosTerminalExceptionBlockedDaysRange = class(EFinPosTerminalException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EFinPosTerminalExceptionNameUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TFinPosTerminal.NameUnique, 'This POS name already exists.');
end;

class function EFinPosTerminalExceptionHasTransactions.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TFinPosTerminal.HasTransactions, 'This record has transactions. Delete the transactions first.');
end;

class function EFinPosTerminalExceptionRateRange.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TFinPosTerminal.RateRange, 'Commission rate must be between 0 and 100.');
end;

class function EFinPosTerminalExceptionBlockedDaysRange.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TFinPosTerminal.BlockedDaysRange, 'Blocked days must be between 0 and 365.');
end;

end.
