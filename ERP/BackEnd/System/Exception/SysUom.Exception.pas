unit SysUom.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  ESysUomException = class(EAppException);

  ESysUomExceptionUnitCodeUnique = class(ESysUomException)
  protected
    class function GetMessage: string; override;
  end;

implementation


class function ESysUomExceptionUnitCodeUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSysUom.UnitCodeUnique, 'Ölçü Birimi Kodu değeri zaten atanmış. Tekrar atanamaz.');
end;

end.
