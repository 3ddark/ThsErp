unit SysCurrency.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  ESysCurrencyException = class(EAppException);

  ESysCurrencyExceptionCurrencyUnique = class(ESysCurrencyException)
  protected
    class function GetMessage: string; override;
  end;

implementation


class function ESysCurrencyExceptionCurrencyUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSysCurrency.CurrencyUnique, '%s zaten atanmýþ. Tekrar atanamaz.');
end;

end.
