unit PurQuotationComparison.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EPurQuotationComparisonException = class(EAppException);

  EPurQuotationComparisonExceptionReadOnly = class(EPurQuotationComparisonException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EPurQuotationComparisonExceptionReadOnly.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurQuotationComparison.ReadOnly, 'The quotation comparison is read-only.');
end;

end.
