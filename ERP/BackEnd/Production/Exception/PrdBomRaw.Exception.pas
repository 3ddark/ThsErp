unit PrdBomRaw.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EPrdBomRawException = class(EAppException);

  EPrdBomRawExceptionInventoryUnique = class(EPrdBomRawException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EPrdBomRawExceptionInventoryUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPrdBomRaw.InventoryUnique, 'This raw material is already in the BoM.');
end;

end.
