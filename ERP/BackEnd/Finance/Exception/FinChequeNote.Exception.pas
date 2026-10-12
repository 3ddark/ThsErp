unit FinChequeNote.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EFinChequeNoteException = class(EAppException);

  EFinChequeNoteExceptionSerialUnique = class(EFinChequeNoteException)
  protected
    class function GetMessage: string; override;
  end;

  EFinChequeNoteExceptionPortfolioNoUnique = class(EFinChequeNoteException)
  protected
    class function GetMessage: string; override;
  end;

  EFinChequeNoteExceptionBankRequired = class(EFinChequeNoteException)
  protected
    class function GetMessage: string; override;
  end;

  EFinChequeNoteExceptionDueBeforeIssue = class(EFinChequeNoteException)
  protected
    class function GetMessage: string; override;
  end;

  EFinChequeNoteExceptionBranchBank = class(EFinChequeNoteException)
  protected
    class function GetMessage: string; override;
  end;

  EFinChequeNoteExceptionHasTransactions = class(EFinChequeNoteException)
  protected
    class function GetMessage: string; override;
  end;

  EFinChequeNoteExceptionKeyFieldsLocked = class(EFinChequeNoteException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EFinChequeNoteExceptionSerialUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TFinChequeNote.SerialUnique, 'A document with this number already exists for this bank.');
end;

class function EFinChequeNoteExceptionPortfolioNoUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TFinChequeNote.PortfolioNoUnique, 'This portfolio number already exists.');
end;

class function EFinChequeNoteExceptionBankRequired.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TFinChequeNote.BankRequired, 'Bank is required for cheques.');
end;

class function EFinChequeNoteExceptionDueBeforeIssue.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TFinChequeNote.DueBeforeIssue, 'Due date cannot be earlier than the issue date.');
end;

class function EFinChequeNoteExceptionBranchBank.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TFinChequeNote.BranchBank, 'The branch does not belong to the selected bank.');
end;

class function EFinChequeNoteExceptionHasTransactions.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TFinChequeNote.HasTransactions, 'The document has transactions. Delete the transactions first.');
end;

class function EFinChequeNoteExceptionKeyFieldsLocked.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TFinChequeNote.KeyFieldsLocked, 'Kind, direction and account cannot be changed after the document has transactions.');
end;

end.
