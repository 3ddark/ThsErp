unit SysUomGroup.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  ESysUomGroupException = class(EAppException);

  ESysUomGroupExceptionKeyUnique = class(ESysUomGroupException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function ESysUomGroupExceptionKeyUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSysUomGroup.KeyUnique, 'Ölçü Birimi Grubu Key değeri zaten atanmış. Tekrar atanamaz.');
end;

end.
