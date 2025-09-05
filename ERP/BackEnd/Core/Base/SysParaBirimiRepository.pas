unit SysParaBirimiRepository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, FireDAC.Stan.Param, BaseRepository, SysParaBirimi;

type
  TSysParaBirimiRepository = class(TBaseRepository)
  public
    constructor Create(AConnection: TFDConnection);
    destructor Destroy; override;

    function CreateQueryForUI(): TFDQuery;
    function Find(AFilter: string; ALock: Boolean): TObjectList;
    function FindById(AId: Integer; ALock: Boolean): TSysParaBirimi;
    procedure Save(AEntity: TSysParaBirimi);
    procedure Delete(AId: Integer);
  end;

implementation

constructor TSysParaBirimiRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
  TableName := 'sys_para_birimleri';
end;

destructor TSysParaBirimiRepository.Destroy;
begin
  //
  inherited;
end;

function TSysParaBirimiRepository.CreateQueryForUI(): TFDQuery;
var
  SQL: string;
  Entity: TSysParaBirimi;
begin
  Result := NewQuery(nil);
  try
    Entity := TSysParaBirimi.Create();
    try
      SQL := Format('SELECT %, %, %, % FROM %', [Entity.Id.FieldName, Entity.Para.FieldName, Entity.Sembol.FieldName, Entity.Aciklama.FieldName, TableName]);
      Result.SQL.Text := SQL;

      Result.Open;
    finally
      Entity.Free;
    end;
  except
    FreeAndNil(Result);
    raise;
  end;
end;

function TSysParaBirimiRepository.Find(AFilter: string; ALock: Boolean): TObjectList;
var
  Q: TFDQuery;
  Entity: TSysParaBirimi;
  SQL: string;
begin
  Result := TObjectList.Create(True);
  Q := NewQuery(nil);
  Entity := TSysParaBirimi.Create();
  try
    try
      SQL := Format('SELECT %, %, %, % FROM % WHERE 1=1 %', [
        Entity.Id.FieldName, Entity.Para.FieldName, Entity.Sembol.FieldName, Entity.Aciklama.FieldName,
        TableName,
        AFilter]);

      if ALock then
        SQL := SQL + ' FOR UPDATE OF ' + TableName + ' NOWAIT';

      Q.SQL.Text := SQL;
      Q.Open;

      while not Q.Eof do
      begin
        Entity.Id.ValueFirstSet(Q.FieldByName('id').AsInteger);
        Entity.Para.ValueFirstSet(Q.FieldByName('para').AsString);
        Entity.Sembol.ValueFirstSet(Q.FieldByName('sembol').AsString);
        Entity.Aciklama.ValueFirstSet(Q.FieldByName('aciklama').AsString);
        Result.Add(Entity);
        Q.Next;
      end;
    except
      raise;
    end;
  finally
    Q.Free;
    Entity.Free;
  end;
end;

function TSysParaBirimiRepository.FindById(AId: Integer; ALock: Boolean): TSysParaBirimi;
var
  Q: TFDQuery;
  SQL: string;
begin
  Result := TSysParaBirimi.Create;
  Q := NewQuery(nil);
  try
    SQL := 'SELECT ' + TableName + Result.Id.FieldName + ',' + TableName + '.para, ' + TableName + '.sembol, ' + TableName + '.aciklama ' + 'FROM ' + TableName + ' WHERE id=:p_id ';

    if ALock then
      SQL := SQL + ' FOR UPDATE OF ' + TableName + ' NOWAIT';

    Q.SQL.Text := SQL;
    Q.ParamByName('p_id').AsInteger := AId;
    Q.Open;

    if not Q.Eof then
    begin
      Result.Id.ValueFirstSet(Q.FieldByName('id').AsInteger);
      Result.Para.ValueFirstSet(Q.FieldByName('para').AsString);
      Result.Sembol.ValueFirstSet(Q.FieldByName('sembol').AsString);
      Result.Aciklama.ValueFirstSet(Q.FieldByName('aciklama').AsString);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

procedure TSysParaBirimiRepository.Save(AEntity: TSysParaBirimi);
var
  Q: TFDQuery;
begin
  Q := NewQuery(nil);
  try
    if AEntity.Id.Value <= 0 then
    begin
      Q.SQL.Text := 'INSERT INTO ' + TableName + ' (para,sembol,aciklama) VALUES (:p_para, :p_sembol, :p_aciklama) RETURNING id';
      Q.ParamByName('p_para').AsString := AEntity.Para.Value;
      Q.ParamByName('p_sembol').AsString := AEntity.Sembol.Value;
      Q.ParamByName('p_aciklama').AsString := AEntity.Aciklama.Value;
      Q.Open;
      AEntity.Id.ValueFirstSet(Q.FieldByName('id').AsInteger);
    end
    else
    begin
      Q.SQL.Text := 'UPDATE ' + TableName + ' SET para=:p_para, sembol=:p_sembol, aciklama=:p_aciklama WHERE id=:p_id';
      Q.ParamByName('p_para').AsString := AEntity.Para.Value;
      Q.ParamByName('p_sembol').AsString := AEntity.Sembol.Value;
      Q.ParamByName('p_aciklama').AsString := AEntity.Aciklama.Value;
      Q.ParamByName('p_id').AsInteger := AEntity.Id.Value;
      Q.ExecSQL;
    end;
  finally
    Q.Free;
  end;
end;

procedure TSysParaBirimiRepository.Delete(AId: Integer);
begin
  DeleteById(AId);
end;

end.

