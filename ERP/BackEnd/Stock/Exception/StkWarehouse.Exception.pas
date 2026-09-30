unit StkWarehouse.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EStkWarehouseException = class(EAppException);

  EStkWarehouseExceptionWarehouseNameUnique = class(EStkWarehouseException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EStkWarehouseExceptionWarehouseNameUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TStkWarehouse.WarehouseNameUnique, 'This warehouse already exists.');
end;

end.
