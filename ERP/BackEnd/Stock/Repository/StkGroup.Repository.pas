unit StkGroup.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, StkGroup;

type
  TStkGroupRepository = class(TRepository<TStkGroup>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TStkGroup; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TStkGroup; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TStkGroup; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TStkGroup>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TStkGroup; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TStkGroup; override;

    procedure DoAdd(AModel: TStkGroup); override;
    procedure DoAddBatch(AModels: TArray<TStkGroup>); override;

    procedure DoUpdate(AModel: TStkGroup); override;
    procedure DoUpdateBatch(AModels: TArray<TStkGroup>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TStkGroup); override;
    procedure DoDeleteBatch(AModels: TArray<TStkGroup>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TStkGroupRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TStkGroupRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TStkGroup) +
            ' (name, vat_rate, raw_material_stock_account, raw_material_usage_account, semi_product_account) ' +
            ' VALUES (:name, :vat_rate, :raw_material_stock_account, :raw_material_usage_account, :semi_product_account)';
end;

function TStkGroupRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TStkGroup) +
            ' SET name = :name, vat_rate = :vat_rate, raw_material_stock_account = :raw_material_stock_account, raw_material_usage_account = :raw_material_usage_account, semi_product_account = :semi_product_account ' +
            ' WHERE id = :id';
end;

function TStkGroupRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TStkGroup) + ' WHERE';
end;

procedure TStkGroupRepository.SetInsertParams(Q: TFDQuery; AModel: TStkGroup; AIndex: Integer);

  // Kod ile bağlanan FK: boş değer NULL gönderilir
  procedure SetCode(const AName, AValue: string);
  begin
    Q.ParamByName(AName).DataType := ftString;
    if AValue <> '' then
    begin
      if AIndex < 0 then
        Q.ParamByName(AName).AsString := AValue
      else
        Q.ParamByName(AName).AsStrings[AIndex] := AValue;
    end
    else if AIndex < 0 then
      Q.ParamByName(AName).Clear
    else
      Q.ParamByName(AName).Clear(AIndex);
  end;

begin
  if AIndex < 0 then
  begin
    Q.ParamByName('name').AsString := AModel.Name;
    Q.ParamByName('vat_rate').AsCurrency := AModel.VatRate;
  end
  else
  begin
    Q.ParamByName('name').AsStrings[AIndex] := AModel.Name;
    Q.ParamByName('vat_rate').AsCurrencys[AIndex] := AModel.VatRate;
  end;

  SetCode('raw_material_stock_account', AModel.RawMaterialStockAccount);
  SetCode('raw_material_usage_account', AModel.RawMaterialUsageAccount);
  SetCode('semi_product_account', AModel.SemiProductAccount);
end;

procedure TStkGroupRepository.SetUpdateParams(Q: TFDQuery; AModel: TStkGroup; AIndex: Integer);

  // Kod ile bağlanan FK: boş değer NULL gönderilir
  procedure SetCode(const AName, AValue: string);
  begin
    Q.ParamByName(AName).DataType := ftString;
    if AValue <> '' then
    begin
      if AIndex < 0 then
        Q.ParamByName(AName).AsString := AValue
      else
        Q.ParamByName(AName).AsStrings[AIndex] := AValue;
    end
    else if AIndex < 0 then
      Q.ParamByName(AName).Clear
    else
      Q.ParamByName(AName).Clear(AIndex);
  end;

begin
  if AIndex < 0 then
  begin
    Q.ParamByName('id').AsLargeInt := AModel.Id;
    Q.ParamByName('name').AsString := AModel.Name;
    Q.ParamByName('vat_rate').AsCurrency := AModel.VatRate;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('name').AsStrings[AIndex] := AModel.Name;
    Q.ParamByName('vat_rate').AsCurrencys[AIndex] := AModel.VatRate;
  end;

  SetCode('raw_material_stock_account', AModel.RawMaterialStockAccount);
  SetCode('raw_material_usage_account', AModel.RawMaterialUsageAccount);
  SetCode('semi_product_account', AModel.SemiProductAccount);
end;

function TStkGroupRepository.MapFromQuery(Q: TFDQuery): TStkGroup;
begin
  Result := TStkGroup.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.Name := Q.FieldByName('name').AsString;
  Result.VatRate := Q.FieldByName('vat_rate').AsCurrency;
  Result.RawMaterialStockAccount := Q.FieldByName('raw_material_stock_account').AsString;
  Result.RawMaterialUsageAccount := Q.FieldByName('raw_material_usage_account').AsString;
  Result.SemiProductAccount := Q.FieldByName('semi_product_account').AsString;
end;

function TStkGroupRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TStkGroup) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TStkGroupRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TStkGroup>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TStkGroup>.Create(True);
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

function TStkGroupRepository.DoFindById(AId: TValue; ALock: Boolean): TStkGroup;
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

function TStkGroupRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TStkGroup;
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

procedure TStkGroupRepository.DoAdd(AModel: TStkGroup);
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

procedure TStkGroupRepository.DoAddBatch(AModels: TArray<TStkGroup>);
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

procedure TStkGroupRepository.DoUpdate(AModel: TStkGroup);
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

procedure TStkGroupRepository.DoUpdateBatch(AModels: TArray<TStkGroup>);
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

procedure TStkGroupRepository.DoDelete(AID: TValue);
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

procedure TStkGroupRepository.DoDelete(AModel: TStkGroup);
begin
  Delete(AModel.Id);
end;

procedure TStkGroupRepository.DoDeleteBatch(AModels: TArray<TStkGroup>);
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

procedure TStkGroupRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TStkGroupRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
