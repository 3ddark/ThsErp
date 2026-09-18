unit SysGridColumnHelper;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, Data.DB,
  FireDAC.Comp.Client, FireDAC.Stan.Param, Logger,
  SysGridColumn.Cache;

type
  TGridColumnHelper = class
  public
    class function BuildSelectColumns(
      AConnection: TFDConnection;
      const ATableName: string;
      const AAlwaysFetch: TArray<string>
    ): string;
  end;

implementation

class function TGridColumnHelper.BuildSelectColumns(
  AConnection: TFDConnection;
  const ATableName: string;
  const AAlwaysFetch: TArray<string>
): string;
begin
  Result := TSysGridColumnCache.BuildSelectColumns(AConnection, ATableName, AAlwaysFetch);
end;

end.
