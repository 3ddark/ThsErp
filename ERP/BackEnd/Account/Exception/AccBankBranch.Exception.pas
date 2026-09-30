unit AccBankBranch.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EAccBankBranchException = class(EAppException);

  EAccBankBranchExceptionBranchCodeUnique = class(EAccBankBranchException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EAccBankBranchExceptionBranchCodeUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TAccBankBranch.BranchCodeUnique, 'This branch code already exists for the bank.');
end;

end.
