unit SysViewColumnRepository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Stan.Param,
  BaseEntity, BaseRepository, SysViewColumn, TableNameService;

type
  TSysViewColumnRepository = class(TBaseRepository<TSysViewColumn>)
//  private
//    procedure Save(AEntity: TSysViewColumn);
  public
    constructor Create(AConnection: TFDConnection);

    function CreateQueryForUI(const AFilterKey: string): string; override;
    function Find(AFilter: string; ALock: Boolean): TList<TSysViewColumn>; override;
    function FindById(AId: Integer; ALock: Boolean): TSysViewColumn; override;
    procedure Add(AEntity: TSysViewColumn);
    procedure Update(AEntity: TSysViewColumn);
    procedure Delete(AId: Int64); override;
  end;

implementation

procedure TSysViewColumnRepository.Add(AEntity: TSysViewColumn);
begin
//
end;

constructor TSysViewColumnRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSysViewColumnRepository.CreateQueryForUI(const AFilterKey: string): string;
var
  SQL, LTableName: string;
  Entity: TSysViewColumn;
  n1: Integer;
begin
  Result := '';
  try
    Entity := TSysViewColumn.Create;
    try
      LTableName := TTableNameService.TableName(Entity.ClassType);

      SQL := Format('SELECT %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s FROM %s WHERE 1=1 ', [
        Entity.Id.QryName,
        Entity.TabloAdi.QryName,
        Entity.ColumnName.QryName,
        Entity.IsNullable.QryName,
        LTableName
        ]);
//        SELECT id, table_name, column_name, is_nullable, data_type, character_maximum_length, ordinal_position,
//        orj_table_name, orj_column_name, table_type, numeric_precision, numeric_scale FROM public.sys_view_columns;
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

function TSysViewColumnRepository.Find(AFilter: string; ALock: Boolean): TList<TSysViewColumn>;
var
  Q: TFDQuery;
  Entity: TSysViewColumn;
  SQL, LTableName: string;
begin
  Result := TList<TSysViewColumn>.Create;
  Q := NewQuery(nil);
  try
    Entity := TSysViewColumn.Create;
    LTableName := TTableNameService.TableName(TSysViewColumn);

    SQL := Format('SELECT %s, %s, %s, %s FROM %s WHERE 1=1 %s', [
      Entity.Id.QryName,
      Entity.TabloAdi.QryName,
      Entity.ColumnName.QryName,
      Entity.IsNullable.QryName,
      LTableName,
      AFilter
      ]);

    if ALock then
      SQL := SQL + ' FOR UPDATE OF ' + LTableName + ' NOWAIT';

    Q.SQL.Text := SQL;
    Q.Open;

    while not Q.Eof do
    begin
      Entity := TSysViewColumn.Create;
      Entity.Id.ValueFirstSet(Q.FieldByName(Entity.Id.FieldName).AsInteger);
      Entity.TabloAdi.ValueFirstSet(Q.FieldByName(Entity.TabloAdi.FieldName).AsString);
      Result.Add(Entity);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

function TSysViewColumnRepository.FindById(AId: Integer; ALock: Boolean): TSysViewColumn;
var
  Q: TFDQuery;
  SQL, LTableName: string;
begin
  Result := TSysViewColumn.Create;
  Q := NewQuery(nil);
  try
    LTableName := TTableNameService.TableName(TSysViewColumn);
    SQL := Format('SELECT %s, %s, %s, %s FROM %s WHERE %s', [
      Result.Id.QryName,
      Result.TabloAdi.QryName,
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
      Result.TabloAdi.ValueFirstSet(Q.FieldByName(Result.TabloAdi.FieldName).AsString);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

//procedure TSysViewColumnRepository.Save(AEntity: TSysViewColumn);
//var
//  Q: TFDQuery;
//  LTableName: string;
//begin
//  Q := NewQuery(nil);
//  try
//    LTableName := TTableNameService.TableName(TSysViewColumn);
//    if AEntity.Id.Value <= 0 then
//    begin
//      Q.SQL.Text := Format('INSERT INTO %s (%s, %s, %s) VALUES (:%s, :%s, :%s) RETURNING %s',[
//        LTableName,
//        AEntity.TabloAdi.FieldName,
//        AEntity.Id.FieldName
//      ]);
//      Q.ParamByName(AEntity.TabloAdi.AsParamName).AsString := AEntity.TabloAdi.Value;
//      Q.Open;
//      AEntity.Id.ValueFirstSet(Q.FieldByName('id').AsInteger);
//    end
//    else
//    begin
//      Q.SQL.Text := Format('UPDATE %s SET %s, %s, %s WHERE %s', [
//        LTableName,
//        AEntity.TabloAdi.FieldName + ':' + AEntity.TabloAdi.AsParamName,
//        AEntity.Id.FieldName + ':' + AEntity.Id.AsParamName
//      ]);
//      Q.ParamByName(AEntity.TabloAdi.AsParamName).AsString := AEntity.TabloAdi.Value;
//      Q.ParamByName(AEntity.Id.AsParamName).AsInteger := AEntity.Id.Value;
//      Q.ExecSQL;
//    end;
//  finally
//    Q.Free;
//  end;
//end;

procedure TSysViewColumnRepository.Update(AEntity: TSysViewColumn);
begin

end;

procedure TSysViewColumnRepository.Delete(AId: Int64);
begin
  DeleteById(AId, TTableNameService.TableName(TSysViewColumn));
end;

end.
