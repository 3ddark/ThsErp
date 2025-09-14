unit StkKindFamilyRepository;

interface

uses
  SysUtils, Classes, Types, DB, System.Generics.Collections,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Stan.Param,
  BaseEntity, BaseRepository, StkKindFamily, TableNameService;

type
  TStkKindFamilyRepository = class(TBaseRepository<TStkKindFamily>)
  public
    constructor Create(AConnection: TFDConnection);
    function CreateQueryForUI(const AFilterKey: string): string; override;
  end;

implementation

constructor TStkKindFamilyRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TStkKindFamilyRepository.CreateQueryForUI(const AFilterKey: string): string;
var
  SQL, LTableName: string;
  Entity: TStkKindFamily;
  n1: Integer;
begin
  Result := '';
  try
    Entity := TStkKindFamily.Create;
    try
      LTableName := TTableNameService.TableName(Entity.ClassType);

      SQL := Format('SELECT %s, %s, %s, %s FROM %s WHERE 1=1 ', [
        Entity.Id.QryName,
        Entity.Family.QryName,
        Entity.Description.QryName,
        Entity.Active.QryName,
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
