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
  Result := TLocalizationManager.Translate(TLangKeys.TSysUomGroup.KeyUnique, 'A Unit of Measure Group Key value has already been assigned. It cannot be assigned again.');
end;

end.
