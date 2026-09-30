unit AccVoucher.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EAccVoucherException = class(EAppException);

  EAccVoucherExceptionJournalNoUnique = class(EAccVoucherException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EAccVoucherExceptionJournalNoUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TAccVoucher.JournalNoUnique, 'This journal number already exists.');
end;

end.
