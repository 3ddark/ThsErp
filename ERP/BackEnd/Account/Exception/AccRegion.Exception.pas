unit AccRegion.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EAccRegionException = class(EAppException);

  EAccRegionExceptionNameUnique = class(EAccRegionException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EAccRegionExceptionNameUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TAccRegion.NameUnique, 'This region already exists.');
end;

end.
