unit SysGridFilter.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  ESysGridFilterException = class(EAppException);

  ESysGridFilterExceptionTableNameUnique = class(ESysGridFilterException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function ESysGridFilterExceptionTableNameUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSysGridFilter.TableNameUnique, '%s is already assigned. It cannot be assigned again.');
end;

end.
