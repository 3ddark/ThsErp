unit AccVoucher.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EAccVoucherException = class(EAppException);

  EAccVoucherExceptionNoUnique = class(EAccVoucherException)
  protected
    class function GetMessage: string; override;
  end;

  EAccVoucherExceptionNoLines = class(EAccVoucherException)
  protected
    class function GetMessage: string; override;
  end;

  EAccVoucherDetailExceptionAmountRule = class(EAccVoucherException)
  protected
    class function GetMessage: string; override;
  end;

  EAccVoucherDetailExceptionDetailAccountOnly = class(EAccVoucherException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EAccVoucherExceptionNoUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TAccVoucher.NoUnique, 'This voucher number is already used.');
end;

class function EAccVoucherExceptionNoLines.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TAccVoucher.NoLines, 'The voucher has no lines.');
end;

class function EAccVoucherDetailExceptionAmountRule.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TAccVoucherDetail.AmountRule, 'Enter either a debit or a credit amount (greater than zero).');
end;

class function EAccVoucherDetailExceptionDetailAccountOnly.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TAccVoucherDetail.DetailAccountOnly, 'Only detail (posting) accounts can be used on a voucher.');
end;

end.
