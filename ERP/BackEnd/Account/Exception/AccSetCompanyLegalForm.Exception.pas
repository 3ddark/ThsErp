unit AccSetCompanyLegalForm.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EAccSetCompanyLegalFormException = class(EAppException);

  EAccSetCompanyLegalFormExceptionLegalFormKeyUnique = class(EAccSetCompanyLegalFormException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EAccSetCompanyLegalFormExceptionLegalFormKeyUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TAccSetCompanyLegalForm.LegalFormKeyUnique, 'This legal form key already exists.');
end;

end.
