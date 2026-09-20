unit SysGridSort.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  ESysGridSortException = class(EAppException);

  ESysGridSortExceptionTableNameUnique = class(ESysGridSortException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function ESysGridSortExceptionTableNameUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSysGridSort.TableNameUnique, '%s is already assigned. It cannot be assigned again.');
end;

end.
