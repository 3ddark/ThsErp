unit SysGridColumn.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  ESysGridColumnException = class(EAppException);

  ESysGridColumnExceptionTableNameColumnNameUnique = class(ESysGridColumnException)
  protected
    class function GetMessage: string; override;
  end;

  ESysGridColumnExceptionTableNameColumnOrderUnique = class(ESysGridColumnException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function ESysGridColumnExceptionTableNameColumnNameUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSysGridColumn.TableNameColumnName, 'The pair %s, %s has already been assigned. It cannot be assigned again.');
end;

class function ESysGridColumnExceptionTableNameColumnOrderUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSysGridColumn.TableNameColumnOrder, 'The pair %s, %s has already been assigned. It cannot be assigned again.');
end;

end.
