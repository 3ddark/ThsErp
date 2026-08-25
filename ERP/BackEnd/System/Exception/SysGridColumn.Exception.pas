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
  Result := TLocalizationManager.Translate(TLangKeys.TSysGridColumn.TableNameColumnName, '%s, %s ikilisi zaten atanmýþ. Tekrar atanamaz.');
end;

class function ESysGridColumnExceptionTableNameColumnOrderUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSysGridColumn.TableNameColumnOrder, '%s, %s ikilisi zaten atanmýþ. Tekrar atanamaz.');
end;
end.
