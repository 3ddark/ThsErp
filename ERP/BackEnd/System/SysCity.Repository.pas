unit SysCity.Repository;

interface

uses
  SysUtils, Classes, Types, DB, System.Generics.Collections,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Stan.Param,
  BaseEntity, BaseRepository, TableNameService, SysCity;

type
  TSysCityRepository = class(TBaseRepository<TSysCity>)
  public
    constructor Create(AConnection: TFDConnection);
    function CreateQueryForUI(const AFilterKey: string): string; override;
  end;

implementation

constructor TSysCityRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSysCityRepository.CreateQueryForUI(const AFilterKey: string): string;
var
  SQL, LTableName: string;
  Entity: TSysCity;
  n1: Integer;
begin
  Result := '';
  try
    Entity := TSysCity.Create;
    try
      LTableName := TTableNameService.TableName(Entity.ClassType);

      SQL := Format('SELECT %s FROM %s WHERE 1=1 ', [
        Entity.Id.QryName,
        Entity.CityName.QryName,
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
