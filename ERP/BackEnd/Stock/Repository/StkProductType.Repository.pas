unit StkProductType.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, StkProductType;

type
  TStkProductTypeRepository = class(TRepository<TStkProductType>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TStkProductType; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TStkProductType; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TStkProductType; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TStkProductType>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TStkProductType; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TStkProductType; override;

    procedure DoAdd(AModel: TStkProductType); override;
    procedure DoAddBatch(AModels: TArray<TStkProductType>); override;

    procedure DoUpdate(AModel: TStkProductType); override;
    procedure DoUpdateBatch(AModels: TArray<TStkProductType>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TStkProductType); override;
    procedure DoDeleteBatch(AModels: TArray<TStkProductType>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TStkProductTypeRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TStkProductTypeRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TStkProductType) +
            ' (product_type_name, description, active) ' +
            ' VALUES (:product_type_name, :description, :active)';
end;

function TStkProductTypeRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TStkProductType) +
            ' SET product_type_name = :product_type_name, description = :description, active = :active ' +
            ' WHERE id = :id';
end;

function TStkProductTypeRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TStkProductType) + ' WHERE';
end;

procedure TStkProductTypeRepository.SetInsertParams(Q: TFDQuery; AModel: TStkProductType; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('product_type_name').AsString := AModel.ProductTypeName;
    Q.ParamByName('description').AsString := AModel.Description;
    Q.ParamByName('active').AsBoolean := AModel.Active;
  end
  else
  begin
    Q.ParamByName('product_type_name').AsStrings[AIndex] := AModel.ProductTypeName;
    Q.ParamByName('description').AsStrings[AIndex] := AModel.Description;
    Q.ParamByName('active').AsBooleans[AIndex] := AModel.Active;
  end;
end;

procedure TStkProductTypeRepository.SetUpdateParams(Q: TFDQuery; AModel: TStkProductType; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('id').AsLargeInt := AModel.Id;
    Q.ParamByName('product_type_name').AsString := AModel.ProductTypeName;
    Q.ParamByName('description').AsString := AModel.Description;
    Q.ParamByName('active').AsBoolean := AModel.Active;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('product_type_name').AsStrings[AIndex] := AModel.ProductTypeName;
    Q.ParamByName('description').AsStrings[AIndex] := AModel.Description;
    Q.ParamByName('active').AsBooleans[AIndex] := AModel.Active;
  end;
end;

function TStkProductTypeRepository.MapFromQuery(Q: TFDQuery): TStkProductType;
begin
  Result := TStkProductType.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.ProductTypeName := Q.FieldByName('product_type_name').AsString;
  Result.Description := Q.FieldByName('description').AsString;
  Result.Active := Q.FieldByName('active').AsBoolean;
end;

function TStkProductTypeRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TStkProductType) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TStkProductTypeRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TStkProductType>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TStkProductType>.Create(True);
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := Self.PrepareSelectFromView(AFilter, ALock, False, False);

    if Assigned(AFilter) and (AFilter.Count > 0) then
      for Criteria in AFilter do
        Q.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;

    LogQuery(Q, 'DoFind');
    Q.Open;
    while not Q.Eof do
    begin
      Result.Add(MapFromQuery(Q));
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

function TStkProductTypeRepository.DoFindById(AId: TValue; ALock: Boolean): TStkProductType;
var
  Q: TFDQuery;
  Criteria: TFilterCriteria;
begin
  Result := nil;
  Q := TFDQuery.Create(nil);
  Criteria := TFilterCriteria.Create;
  try
    Q.Connection := Connection;

    Criteria.Add(TFilterCriterion.New('id', '=', AId));
    Q.SQL.Text := Self.PrepareSelectFromView(Criteria, ALock, True, False);

    Q.ParamByName('id').AsLargeInt := AId.AsInt64;
    LogQuery(Q, 'DoFindById');
    Q.Open;

    if not Q.IsEmpty then
      Result := MapFromQuery(Q);
  finally
    Q.Free;
    Criteria.Free;
  end;
end;

function TStkProductTypeRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TStkProductType;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := nil;
  if not Assigned(AFilter) or (AFilter.Count = 0) then
    Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := Self.PrepareSelectFromView(AFilter, ALock, True, False);

    for Criteria in AFilter do
      Q.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
    LogQuery(Q, 'DoFindOne');
    Q.Open;

    if not Q.IsEmpty then
      Result := MapFromQuery(Q);
  finally
    Q.Free;
  end;
end;

procedure TStkProductTypeRepository.DoAdd(AModel: TStkProductType);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareAddSql + ' RETURNING id';
    SetInsertParams(Q, AModel);
    LogQuery(Q, 'DoAdd');
    Q.Open;
    AModel.Id := Q.FieldByName('id').AsLargeInt;
  finally
    Q.Free;
  end;
end;

procedure TStkProductTypeRepository.DoAddBatch(AModels: TArray<TStkProductType>);
var
  Q: TFDQuery;
  I, Count: Integer;
begin
  Count := Length(AModels);
  if Count = 0 then
    Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareAddSql;
    Q.Params.ArraySize := Count;

    for I := 0 to Count - 1 do
      SetInsertParams(Q, AModels[I], I);

    LogQuery(Q, 'DoAddBatch');
    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TStkProductTypeRepository.DoUpdate(AModel: TStkProductType);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareUpdateSql;
    SetUpdateParams(Q, AModel);
    LogQuery(Q, 'DoUpdate');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TStkProductTypeRepository.DoUpdateBatch(AModels: TArray<TStkProductType>);
var
  Q: TFDQuery;
  I, Count: Integer;
begin
  Count := Length(AModels);
  if Count = 0 then
    Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareUpdateSql;
    Q.Params.ArraySize := Count;

    for I := 0 to Count - 1 do
      SetUpdateParams(Q, AModels[I], I);

    LogQuery(Q, 'DoUpdateBatch');
    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TStkProductTypeRepository.DoDelete(AID: TValue);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareDeleteSql + ' id = :id';
    Q.ParamByName('id').AsLargeInt := AID.AsInt64;
    LogQuery(Q, 'DoDelete');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TStkProductTypeRepository.DoDelete(AModel: TStkProductType);
begin
  Delete(AModel.Id);
end;

procedure TStkProductTypeRepository.DoDeleteBatch(AModels: TArray<TStkProductType>);
var
  Q: TFDQuery;
  I, Count: Integer;
begin
  Count := Length(AModels);
  if Count = 0 then
    Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareDeleteSql + ' id = :id';
    Q.Params.ArraySize := Count;

    for I := 0 to Count - 1 do
      Q.ParamByName('id').AsLargeInts[I] := AModels[I].Id;

    LogQuery(Q, 'DoDeleteBatch');
    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TStkProductTypeRepository.DoDeleteBatch(AIDs: TArray<TValue>);
var
  Q: TFDQuery;
  I, Count: Integer;
begin
  Count := Length(AIDs);
  if Count = 0 then
    Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareDeleteSql + ' id = :id';
    Q.Params.ArraySize := Count;

    for I := 0 to Count - 1 do
      Q.ParamByName('id').AsLargeInts[I] := AIDs[I].AsInt64;

    LogQuery(Q, 'DoDeleteBatch');
    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TStkProductTypeRepository.DoDeleteBatch(AFilter: TFilterCriteria);
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  if not Assigned(AFilter) or (AFilter.Count = 0) then
    Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareDeleteSql + ' 1=1 ';

    for Criteria in AFilter do
      Q.SQL.Text := Q.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;

    for Criteria in AFilter do
      Q.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;

    LogQuery(Q, 'DoDeleteBatch');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

end.
