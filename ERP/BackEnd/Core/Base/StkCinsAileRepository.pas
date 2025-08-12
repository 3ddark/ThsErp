unit StkCinsAileRepository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Stan.Param,
  BaseRepository, StkCinsAile;

type
  TStkCinsAileRepository = class(TBaseRepository)
  public
    constructor Create(AConnection: TFDConnection);

    function CreateQueryForUI(const AFilterKey: string; AOwner: TComponent): TFDQuery;
    function Find(AFilter: string; ALock: Boolean): TObjectList;
    function FindById(AId: Integer; ALock: Boolean): TStkCinsAile;
    procedure Save(AEntity: TStkCinsAile);
    procedure Delete(AId: Integer);
  end;

implementation

constructor TStkCinsAileRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
  TableName := 'stk_cins_aileleri';
end;

function TStkCinsAileRepository.CreateQueryForUI(const AFilterKey: string; AOwner: TComponent): TFDQuery;
var
  SQL: string;
begin
  Result := NewQuery(AOwner);
  try
    SQL := 'SELECT id, aile FROM ' + TableName;

    if AFilterKey = 'AKTIF_KULLANICILAR' then
    begin
      SQL := SQL + ' WHERE is_active = :p_is_active';
      Result.SQL.Text := SQL;
      Result.ParamByName('p_is_active').AsBoolean := True;
    end
    else if AFilterKey = 'PASIF_KULLANICILAR' then
    begin
      SQL := SQL + ' WHERE is_active = :p_is_active';
      Result.SQL.Text := SQL;
      Result.ParamByName('p_is_active').AsBoolean := False;
    end
    else if AFilterKey = 'TUM_KULLANICILAR' then
    begin
      Result.SQL.Text := SQL;
    end
    else
    begin
      Result.SQL.Text := SQL;
    end;

    Result.Open;
  except
    FreeAndNil(Result);
    raise;
  end;
end;

function TStkCinsAileRepository.Find(AFilter: string; ALock: Boolean): TObjectList;
var
  Q: TFDQuery;
  Entity: TStkCinsAile;
  SQL: string;
begin
  Result := TObjectList.Create(True);
  Q := NewQuery(nil);
  try
    SQL :=
      'SELECT ' +
        TableName + '.id, ' +
        TableName + '.aile ' +
      'FROM ' + TableName + ' WHERE 1=1 ' + AFilter;

    if ALock then
      SQL := SQL + ' FOR UPDATE OF ' + TableName + ' NOWAIT';

    Q.SQL.Text := SQL;
    Q.Open;

    while not Q.Eof do
    begin
      Entity := TStkCinsAile.Create;
      Entity.Id.ValueFirstSet(Q.FieldByName('id').AsInteger);
      Entity.Aile.ValueFirstSet(Q.FieldByName('aile').AsString);
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
    SQL :=
      'SELECT ' +
        TableName + '.id, ' +
        TableName + '.aile ' +
      'FROM ' + TableName + ' WHERE id=:p_id ';

    if ALock then
      SQL := SQL + ' FOR UPDATE OF ' + TableName + ' NOWAIT';

    Q.SQL.Text := SQL;
    Q.ParamByName('p_id').AsInteger := AId;
    Q.Open;

    if not Q.Eof then
    begin
      Result.Id.ValueFirstSet(Q.FieldByName('id').AsInteger);
      Result.Aile.ValueFirstSet(Q.FieldByName('aile').AsString);
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
      Q.SQL.Text := 'INSERT INTO ' + TableName + ' (aile) VALUES (:p_aile) RETURNING id';
      Q.ParamByName('p_aile').AsString := AEntity.Aile.Value;
      Q.Open;
      AEntity.Id.ValueFirstSet(Q.FieldByName('id').AsInteger);
    end
    else
    begin
      Q.SQL.Text := 'UPDATE ' + TableName + ' SET aile=:p_aile WHERE id=:p_id';
      Q.ParamByName('p_aile').AsString := AEntity.Aile.Value;
      Q.ParamByName('p_id').AsInteger := AEntity.Id.Value;
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

