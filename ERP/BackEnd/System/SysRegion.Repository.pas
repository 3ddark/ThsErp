unit SysRegion.Repository;

interface

uses
  SysUtils, Classes, Types, DB, System.Generics.Collections,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Stan.Param,
  BaseEntity, BaseRepository, TableNameService, SysRegion;

type
  TSysRegionRepository = class(TBaseRepository<TSysRegion>)
  public
    constructor Create(AConnection: TFDConnection);
    function CreateQueryForUI(const AFilterKey: string): string; override;
  end;

implementation

constructor TSysRegionRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSysRegionRepository.CreateQueryForUI(const AFilterKey: string): string;
var
  SQL, LTableName: string;
  Entity: TSysRegion;
  n1: Integer;
begin
  Result := '';
  try
    Entity := TSysRegion.Create;
    try
      LTableName := TTableNameService.TableName(Entity.ClassType);

      SQL := Format('SELECT %s, %s FROM %s WHERE 1=1 ', [
        Entity.Id.QryName,
        Entity.RegionName.QryName,
        LTableName
        ]);
    finally
      for n1 := 0 to Entity.Fields.Count-1 do
      begin
        if Entity.Fields[n1].OwnerEntity <> nil then
          Entity.Fields[n1].OwnerEntity := nil;
      end;
    end;

    Result := SQL;
  except
    raise;
  end;
end;

end.
