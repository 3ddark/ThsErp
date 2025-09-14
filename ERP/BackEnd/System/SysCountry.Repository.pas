unit SysCountry.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Stan.Param,
  BaseEntity, BaseRepository, SysCountry, TableNameService;

type
  TSysCountryRepository = class(TBaseRepository<TSysCountry>)
  public
    constructor Create(AConnection: TFDConnection);
    function CreateQueryForUI(const AFilterKey: string): string; override;
  end;

implementation

constructor TSysCountryRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSysCountryRepository.CreateQueryForUI(const AFilterKey: string): string;
var
  SQL, LTableName: string;
  Entity: TSysCountry;
  n1: Integer;
begin
  Result := '';
  try
    Entity := TSysCountry.Create;
    try
      LTableName := TTableNameService.TableName(Entity.ClassType);

      SQL := Format('SELECT %s, %s, %s, %s, %s, %s FROM %s WHERE 1=1 ', [
        Entity.Id.QryName,
        Entity.CountryCode.QryName,
        Entity.CountryName.QryName,
        Entity.ISOYear.QryName,
        Entity.ISOCCTLD.QryName,
        Entity.IsEuMember.QryName,
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
