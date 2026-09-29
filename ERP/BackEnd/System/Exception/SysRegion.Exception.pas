unit SysRegion.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  ESysRegionException = class(EAppException);

  ESysRegionExceptionNameUnique = class(ESysRegionException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function ESysRegionExceptionNameUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSysRegion.RegionNameUnique, 'This region name is already in use. It cannot be assigned again.');
end;

end.
