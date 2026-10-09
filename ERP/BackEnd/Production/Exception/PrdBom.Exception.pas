unit PrdBom.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EPrdBomException = class(EAppException);

  EPrdBomExceptionBomNameUnique = class(EPrdBomException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EPrdBomExceptionBomNameUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPrdBom.BomNameUnique, 'This product already has a BoM with this name.');
end;

end.
