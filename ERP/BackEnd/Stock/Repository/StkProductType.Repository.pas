unit StkProductType.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections, System.Rtti,
  FireDAC.Comp.Client, FireDAC.Stan.Param, Entity, Repository, StkProductType, FilterCriterion;

type
  TStkProductTypeRepository = class(TRepository<TStkProductType>)
  protected
    function PrepareSelectSql: string; virtual;
    function PrepareAddSql: string; virtual;
    function PrepareUpdateSql: string; virtual;
    function PrepareDeleteSql: string; virtual;

    procedure SetModelParams(Q: TFDQuery; AModel: TStkProductType; AIndex: Integer = -1);
  public
    constructor Create(AConnection: TFDConnection);
    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function FindById(AId: TValue; ALock: Boolean = False): TStkProductType; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TStkProductType; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean = False): TList<TStkProductType>; override;

    procedure Add(AModel: TStkProductType); override;
    procedure AddBatch(AModels: TArray<TStkProductType>); override;

    procedure Update(AModel: TStkProductType); override;
    procedure UpdateBatch(AModels: TArray<TStkProductType>); override;

    procedure Delete(AID: TValue); override;
    procedure Delete(AModel: TStkProductType); override;
    procedure DeleteBatch(AModels: TArray<TStkProductType>); override;
  end;

implementation

constructor TStkProductTypeRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TStkProductTypeRepository.PrepareSelectSql: string;
begin
  Result := 'SELECT id, product_type_name FROM public.' + Self.GetTableName(TStkProductType);
end;

function TStkProductTypeRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TStkProductType) +
    ' (product_type_name) VALUES (:product_type_name)';
end;

function TStkProductTypeRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TStkProductType) +
    ' SET product_type_name = :product_type_name WHERE id = :id';
end;

function TStkProductTypeRepository.PrepareDeleteSql: string;
begin
  Result := 'DELETE FROM public.' + Self.GetTableName(TStkProductType) + ' WHERE id = :id';
end;

procedure TStkProductTypeRepository.SetModelParams(Q: TFDQuery; AModel: TStkProductType; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('product_type_name').AsString := AModel.ProductTypeName;

    if (AModel.Id > 0) and (Q.FindParam('id') <> nil) then
      Q.ParamByName('id').AsLargeInt := AModel.Id;
  end
  else
  begin
    Q.ParamByName('product_type_name').AsStrings[AIndex] := AModel.ProductTypeName;

    if (AModel.Id > 0) and (Q.FindParam('id') <> nil) then
      Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
  end;
end;

function TStkProductTypeRepository.FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT * FROM public.stk_product_type WHERE 1=1 ';
end;

procedure TStkProductTypeRepository.Add(AModel: TStkProductType);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareAddSql + ' RETURNING id';
    SetModelParams(Q, AModel);
    Q.Open;
    AModel.Id := Q.FieldByName('id').AsLargeInt;
  finally
    Q.Free;
  end;
end;

procedure TStkProductTypeRepository.AddBatch(AModels: TArray<TStkProductType>);
var
  Q: TFDQuery;
  I, Count: Integer;
begin
  Count := Length(AModels);
  if Count = 0 then Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareAddSql;
    Q.Params.ArraySize := Count;

    for I := 0 to Count - 1 do
      SetModelParams(Q, AModels[I], I);

    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TStkProductTypeRepository.Update(AModel: TStkProductType);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareUpdateSql;
    SetModelParams(Q, AModel);
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TStkProductTypeRepository.UpdateBatch(AModels: TArray<TStkProductType>);
var
  Q: TFDQuery;
  I, Count: Integer;
begin
  Count := Length(AModels);
  if Count = 0 then Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareUpdateSql;
    Q.Params.ArraySize := Count;

    for I := 0 to Count - 1 do
      SetModelParams(Q, AModels[I], I);

    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TStkProductTypeRepository.Delete(AID: TValue);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareDeleteSql;
    Q.ParamByName('id').AsLargeInt := AID.AsInt64;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TStkProductTypeRepository.Delete(AModel: TStkProductType);
begin
  Delete(AModel.Id);
end;

procedure TStkProductTypeRepository.DeleteBatch(AModels: TArray<TStkProductType>);
var
  Q: TFDQuery;
  I, Count: Integer;
begin
  Count := Length(AModels);
  if Count = 0 then Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareDeleteSql;
    Q.Params.ArraySize := Count;

    for I := 0 to Count - 1 do
      Q.ParamByName('id').AsLargeInts[I] := AModels[I].Id;

    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

function TStkProductTypeRepository.FindById(AId: TValue; ALock: Boolean): TStkProductType;
var
  Q: TFDQuery;
begin
  Result := nil;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareSelectSql + ' WHERE id = :id';
    if ALock then
      Q.SQL.Text := Q.SQL.Text + ' FOR UPDATE';

    Q.ParamByName('id').AsLargeInt := AId.AsInt64;
    Q.Open;

    if not Q.IsEmpty then
    begin
      Result := TStkProductType.Create;
      Result.Id := Q.FieldByName('id').AsLargeInt;
      Result.ProductTypeName := Q.FieldByName('product_type_name').AsString;
    end;
  finally
    Q.Free;
  end;
end;

function TStkProductTypeRepository.FindOne(AFilter: TFilterCriteria; ALock: Boolean): TStkProductType;
var
  Q: TFDQuery;
  Criterion: TFilterCriterion;
begin
  Result := nil;
  if not Assigned(AFilter) or (AFilter.Count = 0) then
    Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareSelectSql + ' WHERE 1=1';

    for Criterion in AFilter do
      Q.SQL.Text := Q.SQL.Text + ' AND ' + Criterion.FieldName + ' ' + Criterion.Operator + ' :' + Criterion.FieldName;

    if ALock then
      Q.SQL.Text := Q.SQL.Text + ' FOR UPDATE';

    Q.SQL.Text := Q.SQL.Text + ' LIMIT 1';

    for Criterion in AFilter do
      Q.ParamByName(Criterion.FieldName).Value := Criterion.Value.AsVariant;

    Q.Open;

    if not Q.IsEmpty then
    begin
      Result := TStkProductType.Create;
      Result.Id := Q.FieldByName('id').AsLargeInt;
      Result.ProductTypeName := Q.FieldByName('product_type_name').AsString;
    end;
  finally
    Q.Free;
  end;
end;

function TStkProductTypeRepository.Find(AFilter: TFilterCriteria; ALock: Boolean): TList<TStkProductType>;
var
  Q: TFDQuery;
  Item: TStkProductType;
  Criterion: TFilterCriterion;
begin
  Result := TObjectList<TStkProductType>.Create(True);
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareSelectSql + ' WHERE 1=1';

    if Assigned(AFilter) and (AFilter.Count > 0) then
    begin
      for Criterion in AFilter do
        Q.SQL.Text := Q.SQL.Text + ' AND ' + Criterion.FieldName + ' ' + Criterion.Operator + ' :' + Criterion.FieldName;
    end;

    if ALock then
      Q.SQL.Text := Q.SQL.Text + ' FOR UPDATE';

    if Assigned(AFilter) and (AFilter.Count > 0) then
    begin
      for Criterion in AFilter do
        Q.ParamByName(Criterion.FieldName).Value := Criterion.Value.AsVariant;
    end;

    Q.Open;
    while not Q.Eof do
    begin
      Item := TStkProductType.Create;
      Item.Id := Q.FieldByName('id').AsLargeInt;
      Item.ProductTypeName := Q.FieldByName('product_type_name').AsString;
      Result.Add(Item);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

end.