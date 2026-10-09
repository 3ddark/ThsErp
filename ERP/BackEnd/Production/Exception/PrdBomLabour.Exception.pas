unit PrdBomLabour.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EPrdBomLabourException = class(EAppException);

  EPrdBomLabourExceptionLabourUnique = class(EPrdBomLabourException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EPrdBomLabourExceptionLabourUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPrdBomLabour.LabourUnique, 'This labour is already in the BoM.');
end;

end.
