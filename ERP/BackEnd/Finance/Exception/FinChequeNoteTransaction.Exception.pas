unit FinChequeNoteTransaction.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EFinChequeNoteTransactionException = class(EAppException);

  EFinChequeNoteTransactionExceptionOnlyLast = class(EFinChequeNoteTransactionException)
  protected
    class function GetMessage: string; override;
  end;

  EFinChequeNoteTransactionExceptionOpeningLocked = class(EFinChequeNoteTransactionException)
  protected
    class function GetMessage: string; override;
  end;

  EFinChequeNoteTransactionExceptionNoteChanged = class(EFinChequeNoteTransactionException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EFinChequeNoteTransactionExceptionOnlyLast.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TFinChequeNoteTransaction.OnlyLast, 'Only the last transaction of the document can be changed or deleted.');
end;

class function EFinChequeNoteTransactionExceptionOpeningLocked.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TFinChequeNoteTransaction.OpeningLocked, 'The opening transaction cannot be deleted. Delete the document instead.');
end;

class function EFinChequeNoteTransactionExceptionNoteChanged.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TFinChequeNoteTransaction.NoteChanged, 'The document of an existing transaction cannot be changed.');
end;

end.
