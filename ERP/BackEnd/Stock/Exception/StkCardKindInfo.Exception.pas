unit StkCardKindInfo.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EStkCardKindInfoException = class(EAppException);

  EStkCardKindInfoExceptionInventoryUnique = class(EStkCardKindInfoException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EStkCardKindInfoExceptionInventoryUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TStkCardKindInfo.InventoryUnique, 'Kind information already exists for this stock card.');
end;

end.
