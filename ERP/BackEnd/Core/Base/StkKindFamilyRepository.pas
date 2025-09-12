unit StkKindFamilyRepository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Stan.Param,
  BaseEntity, BaseRepository, StkKindFamily, TableNameService;

type
  TStkKindFamilyRepository = class(TBaseRepository<TStkKindFamily>)
  public
    constructor Create(AConnection: TFDConnection);

    function CreateQueryForUI(const AFilterKey: string): string; override;
    function Find(AFilter: string; ALock: Boolean): TList<TStkKindFamily>; override;
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

function TStkKindFamilyRepository.Find(AFilter: string; ALock: Boolean): TList<TStkKindFamily>;
var
  Q: TFDQuery;
  Entity: TStkKindFamily;
  SQL, LTableName: string;
begin
  Result := TList<TStkKindFamily>.Create;
  Q := NewQuery(nil);
  try
    Entity := TStkKindFamily.Create;
    LTableName := TTableNameService.TableName(TStkKindFamily);

    SQL := Format('SELECT %s, %s, %s, %s FROM %s WHERE 1=1 %s', [
      Entity.Id.QryName,
      Entity.Family.QryName,
      Entity.Description.QryName,
      Entity.Active.QryName,
      LTableName,
      AFilter
      ]);

    if ALock then
      SQL := SQL + ' FOR UPDATE OF ' + LTableName + ' NOWAIT';

    Q.SQL.Text := SQL;
    Q.Open;

    while not Q.Eof do
    begin
      Entity := TStkKindFamily.Create;
      Entity.Id.ValueFirstSet(Q.FieldByName(Entity.Id.FieldName).AsInteger);
      Entity.Family.ValueFirstSet(Q.FieldByName(Entity.Family.FieldName).AsString);
      Entity.Description.ValueFirstSet(Q.FieldByName(Entity.Description.FieldName).AsString);
      Entity.Active.ValueFirstSet(Q.FieldByName(Entity.Active.FieldName).AsBoolean);
      Result.Add(Entity);

      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

end.
