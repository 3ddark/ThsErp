unit StkCinsAileRepository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Stan.Param,
  BaseEntity, BaseRepository, StkCinsAile, TableNameService;

type
  TStkCinsAileRepository = class(TBaseRepository<TStkCinsAile>)
  public
    constructor Create(AConnection: TFDConnection);

    function CreateQueryForUI(const AFilterKey: string): string;
    function Find(AFilter: string; ALock: Boolean): TObjectList<TStkCinsAile>;
    function FindById(AId: Integer; ALock: Boolean): TStkCinsAile;
    procedure Save(AEntity: TStkCinsAile);
    procedure Delete(AId: Integer);
  end;

implementation

constructor TStkCinsAileRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TStkCinsAileRepository.CreateQueryForUI(const AFilterKey: string): string;
var
  SQL: string;
  Entity: TStkCinsAile;
begin
  Result := '';
  try
    Entity := TStkCinsAile.Create;
    try
      SQL := Format('SELECT %, %, %, % FROM % WHERE 1=1 ', [
        Entity.Id.QryName,
        Entity.Family.QryName,
        Entity.Description.QryName,
        Entity.Active.QryName,
        TTableNameService.TableName(TStkCinsAile)
        ]);
    finally
      Entity := nil;
    end;

    Result := SQL;
  except
    raise;
  end;
end;

function TStkCinsAileRepository.Find(AFilter: string; ALock: Boolean): TObjectList<TStkCinsAile>;
var
  Q: TFDQuery;
  Entity: TStkCinsAile;
  SQL: string;
begin
  Result := TObjectList<TStkCinsAile>.Create(True);
  Q := NewQuery(nil);
  try
    Entity := TStkCinsAile.Create;
    try
      SQL := Format('SELECT %, %, %, % FROM % WHERE 1=1 %', [
        Entity.Id.QryName,
        Entity.Family.QryName,
        Entity.Description.QryName,
        Entity.Active.QryName,
        TTableNameService.TableName(TStkCinsAile),
        AFilter
        ]);
    finally
      Entity := nil;
    end;

    if ALock then
      SQL := SQL + ' FOR UPDATE OF ' + '' + ' NOWAIT';

    Q.SQL.Text := SQL;
    Q.Open;

    while not Q.Eof do
    begin
      Entity := TStkCinsAile.Create;
      Entity.Id.ValueFirstSet(Q.FieldByName(Entity.Family.FieldName).AsInteger);
      Entity.Family.ValueFirstSet(Q.FieldByName(Entity.Family.FieldName).AsString);
      Entity.Family.ValueFirstSet(Q.FieldByName(Entity.Family.FieldName).AsString);
      Entity.Family.ValueFirstSet(Q.FieldByName(Entity.Family.FieldName).AsString);
      Result.Add(Entity);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

function TStkCinsAileRepository.FindById(AId: Integer; ALock: Boolean): TStkCinsAile;
var
  Q: TFDQuery;
  SQL: string;
begin
  Result := TStkCinsAile.Create;
  Q := NewQuery(nil);
  try
    SQL := Format('SELECT %, %, %, % FROM % WHERE %', [
      Result.Id.QryName,
      Result.Family.QryName,
      Result.Description.QryName,
      Result.Active.QryName,
      TTableNameService.TableName(TStkCinsAile),
      Result.Id.QryName + '=:' + Result.Id.AsParamName
    ]);

    if ALock then
      SQL := SQL + ' FOR UPDATE OF ' + TTableNameService.TableName(TStkCinsAile) + ' NOWAIT';

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

procedure TStkCinsAileRepository.Save(AEntity: TStkCinsAile);
var
  Q: TFDQuery;
begin
  Q := NewQuery(nil);
  try
    if AEntity.Id.Value <= 0 then
    begin
      Q.SQL.Text := Format('INSERT INTO % (%, %, %) VALUES (:%, :%, :%) RETURNING %',[
        TTableNameService.TableName(TStkCinsAile),
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
    end
    else
    begin
      Q.SQL.Text := Format('UPDATE % SET %, %, % WHERE %', [
        TTableNameService.TableName(TStkCinsAile),
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
    end;
  finally
    Q.Free;
  end;
end;

procedure TStkCinsAileRepository.Delete(AId: Integer);
begin
  DeleteById(AId);
end;

end.
