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
    function FindById(AId: Integer; ALock: Boolean): TStkKindFamily; override;
    procedure Add(AEntity: TStkKindFamily); override;
    procedure Update(AEntity: TStkKindFamily); override;
    procedure Delete(AId: Int64); override;
  end;

implementation

constructor TStkKindFamilyRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

procedure TStkKindFamilyRepository.Add(AEntity: TStkKindFamily);
var
  Q: TFDQuery;
  LTableName: string;
begin
  if AEntity.Id.Value > 0 then
    Exit;

  Q := NewQuery(nil);
  try
    LTableName := TTableNameService.TableName(TStkKindFamily);

    Q.SQL.Text := Format('INSERT INTO %s (%s, %s, %s) VALUES (:%s, :%s, :%s) RETURNING %s',[
      LTableName,
      AEntity.Family.FieldName,
      AEntity.Description.FieldName,
      AEntity.Active.FieldName,
      AEntity.Family.AsParamName,
      AEntity.Description.AsParamName,
      AEntity.Active.AsParamName,
      AEntity.Id.FieldName
    ]);
    Q.ParamByName(AEntity.Family.AsParamName).AsString := AEntity.Family.Value;
    Q.ParamByName(AEntity.Description.AsParamName).AsString := AEntity.Description.Value;
    Q.ParamByName(AEntity.Active.AsParamName).AsBoolean := AEntity.Active.Value;
    Q.Open;
    AEntity.Id.ValueFirstSet(Q.FieldByName('id').AsInteger);
  finally
    Q.Free;
  end;
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

function TStkKindFamilyRepository.FindById(AId: Integer; ALock: Boolean): TStkKindFamily;
var
  Q: TFDQuery;
  SQL, LTableName: string;
begin
  Result := TStkKindFamily.Create;
  Q := NewQuery(nil);
  try
    LTableName := TTableNameService.TableName(TStkKindFamily);
    SQL := Format('SELECT %s, %s, %s, %s FROM %s WHERE %s', [
      Result.Id.QryName,
      Result.Family.QryName,
      Result.Description.QryName,
      Result.Active.QryName,
      LTableName,
      Result.Id.QryName + '=:' + Result.Id.AsParamName
    ]);

    if ALock then
      SQL := SQL + ' FOR UPDATE OF ' + LTableName + ' NOWAIT';

    Q.SQL.Text := SQL;
    Q.ParamByName(Result.Id.AsParamName).AsInteger := AId;
    Q.Open;

    if not Q.Eof then
    begin
      Result.Id.ValueFirstSet(Q.FieldByName(Result.Id.FieldName).AsInteger);
      Result.Family.ValueFirstSet(Q.FieldByName(Result.Family.FieldName).AsString);
      Result.Description.ValueFirstSet(Q.FieldByName(Result.Description.FieldName).AsString);
      Result.Active.ValueFirstSet(Q.FieldByName(Result.Active.FieldName).AsBoolean);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

procedure TStkKindFamilyRepository.Update(AEntity: TStkKindFamily);
var
  Q: TFDQuery;
  LTableName: string;
begin
  if AEntity.Id.Value <= 0 then
    Exit;

  Q := NewQuery(nil);
  try
    LTableName := TTableNameService.TableName(TStkKindFamily);
    Q.SQL.Text := Format('UPDATE %s SET %s, %s, %s WHERE %s', [
      LTableName,
      AEntity.Family.FieldName + ':' + AEntity.Family.AsParamName,
      AEntity.Description.FieldName + ':' + AEntity.Description.AsParamName,
      AEntity.Active.FieldName + ':' + AEntity.Active.AsParamName,
      AEntity.Id.FieldName + ':' + AEntity.Id.AsParamName
    ]);
    Q.ParamByName(AEntity.Family.AsParamName).AsString := AEntity.Family.Value;
    Q.ParamByName(AEntity.Description.AsParamName).AsString := AEntity.Description.Value;
    Q.ParamByName(AEntity.Active.AsParamName).AsBoolean := AEntity.Active.Value;
    Q.ParamByName(AEntity.Id.AsParamName).AsInteger := AEntity.Id.Value;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TStkKindFamilyRepository.Delete(AId: Int64);
begin
  DeleteById(AId, TTableNameService.TableName(TStkKindFamily));
end;

end.
