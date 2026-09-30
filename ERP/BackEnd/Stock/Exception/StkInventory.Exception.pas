unit StkInventory.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EStkInventoryException = class(EAppException);

  EStkInventoryExceptionCodeUnique = class(EStkInventoryException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EStkInventoryExceptionCodeUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TStkInventory.CodeUnique, 'This stock code already exists.');
end;

end.
