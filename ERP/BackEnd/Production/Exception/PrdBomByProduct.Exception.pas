unit PrdBomByProduct.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EPrdBomByProductException = class(EAppException);

  EPrdBomByProductExceptionInventoryUnique = class(EPrdBomByProductException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EPrdBomByProductExceptionInventoryUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPrdBomByProduct.InventoryUnique, 'This by-product is already in the BoM.');
end;

end.
