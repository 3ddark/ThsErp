unit StkProductType.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EStkProductTypeException = class(EAppException);

  EStkProductTypeExceptionProductTypeNameUnique = class(EStkProductTypeException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EStkProductTypeExceptionProductTypeNameUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TStkProductType.ProductTypeNameUnique, 'This product type already exists.');
end;

end.
