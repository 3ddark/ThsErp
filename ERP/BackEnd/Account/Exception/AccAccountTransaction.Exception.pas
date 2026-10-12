unit AccAccountTransaction.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EAccAccountTransactionException = class(EAppException);

  EAccAccountTransactionExceptionReadOnly = class(EAccAccountTransactionException)
  protected
    class function GetMessage: string; override;
  end;

  EAccAccountTransactionExceptionUnknownSource = class(EAccAccountTransactionException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EAccAccountTransactionExceptionReadOnly.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TAccAccountTransaction.ReadOnly, 'Account transactions are created from their source documents.');
end;

class function EAccAccountTransactionExceptionUnknownSource.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TAccAccountTransaction.UnknownSource, 'The source document type is not supported.');
end;

end.
