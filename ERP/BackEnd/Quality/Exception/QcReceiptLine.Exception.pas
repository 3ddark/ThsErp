unit QcReceiptLine.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EQcReceiptLineException = class(EAppException);

  EQcReceiptLineExceptionReadOnly = class(EQcReceiptLineException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EQcReceiptLineExceptionReadOnly.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TQcReceiptLine.ReadOnly, 'This list is read-only; record the inspection instead.');
end;

end.
