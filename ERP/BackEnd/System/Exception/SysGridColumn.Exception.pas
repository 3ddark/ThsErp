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
  Result := TLocalizationManager.Translate(TLangKeys.TSysGridColumn.TableNameColumnName, 'This column is already defined for this table.');
end;

class function ESysGridColumnExceptionTableNameColumnOrderUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSysGridColumn.TableNameColumnOrder, 'This column order is already in use for this table.');
end;

end.
