unit EInvDiibLine.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EEInvDiibLineException = class(EAppException);

  EEInvDiibLineExceptionLineCodeUnique = class(EEInvDiibLineException)
  protected
    class function GetMessage: string; override;
  end;

  EEInvDiibLineExceptionQuantityNegative = class(EEInvDiibLineException)
  protected
    class function GetMessage: string; override;
  end;

  EEInvDiibLineExceptionInUse = class(EEInvDiibLineException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EEInvDiibLineExceptionLineCodeUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TEInvDiibLine.LineCodeUnique, 'This line code already exists in the certificate.');
end;

class function EEInvDiibLineExceptionQuantityNegative.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TEInvDiibLine.QuantityNegative, 'Quantity cannot be negative.');
end;

class function EEInvDiibLineExceptionInUse.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TEInvDiibLine.InUse, 'This record is in use. Make it passive instead of deleting it.');
end;

end.
