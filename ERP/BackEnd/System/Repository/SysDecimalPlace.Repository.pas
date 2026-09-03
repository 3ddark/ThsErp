unit SysDecimalPlace.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, Service,
  FilterCriterion, UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  SysDecimalPlace;

type
  TSysDecimalPlaceRepository = class(TRepository<TSysDecimalPlace>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TSysDecimalPlace; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TSysDecimalPlace; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TSysDecimalPlace; override;


    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TList<TSysDecimalPlace>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TSysDecimalPlace; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TSysDecimalPlace; override;

    procedure DoAdd(AModel: TSysDecimalPlace); override;
    procedure DoAddBatch(AModels: TArray<TSysDecimalPlace>); override;

    procedure DoUpdate(AModel: TSysDecimalPlace); override;
    procedure DoUpdateBatch(AModels: TArray<TSysDecimalPlace>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TSysDecimalPlace); override;
    procedure DoDeleteBatch(AModels: TArray<TSysDecimalPlace>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TSysDecimalPlaceRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSysDecimalPlaceRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TSysDecimalPlace) +
            ' (quantity, price, total, stock_quantity, exchange_rate) ' +
            ' VALUES (:quantity, :price, :total, :stock_quantity, :exchange_rate)';
end;

function TSysDecimalPlaceRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TSysDecimalPlace) +
            ' SET quantity = :quantity, price = :price, total = :total, ' +
            '     stock_quantity = :stock_quantity, exchange_rate = :exchange_rate ' +
            ' WHERE id = :id';
end;

function TSysDecimalPlaceRepository.PrepareDeleteSql: string;
begin
  //WHERE k�sm� �zellikle b�yle yaz�ld�. Filtre vermeden i�lem yap�lmamas� i�in. Hatal� kodlamada t�m tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TSysDecimalPlace) + ' WHERE';
end;

procedure TSysDecimalPlaceRepository.SetInsertParams(Q: TFDQuery; AModel: TSysDecimalPlace; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('quantity').AsSmallInt := AModel.Quantity;
    Q.ParamByName('price').AsSmallInt := AModel.Price;
    Q.ParamByName('total').AsSmallInt := AModel.Total;
    Q.ParamByName('stock_quantity').AsSmallInt := AModel.StockQuantity;
    Q.ParamByName('exchange_rate').AsSmallInt := AModel.ExchangeRate;
  end
  else
  begin
    Q.ParamByName('quantity').AsSmallInts[AIndex] := AModel.Quantity;
    Q.ParamByName('price').AsSmallInts[AIndex] := AModel.Price;
    Q.ParamByName('total').AsSmallInts[AIndex] := AModel.Total;
    Q.ParamByName('stock_quantity').AsSmallInts[AIndex] := AModel.StockQuantity;
    Q.ParamByName('exchange_rate').AsSmallInts[AIndex] := AModel.ExchangeRate;
  end;
end;

procedure TSysDecimalPlaceRepository.SetUpdateParams(Q: TFDQuery; AModel: TSysDecimalPlace; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('id').AsSmallInt              := AModel.Id;
    Q.ParamByName('quantity').AsSmallInt        := AModel.Quantity;
    Q.ParamByName('price').AsSmallInt           := AModel.Price;
    Q.ParamByName('total').AsSmallInt           := AModel.Total;
    Q.ParamByName('stock_quantity').AsSmallInt  := AModel.StockQuantity;
    Q.ParamByName('exchange_rate').AsSmallInt   := AModel.ExchangeRate;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex]             := AModel.Id;
    Q.ParamByName('quantity').AsSmallInts[AIndex]       := AModel.Quantity;
    Q.ParamByName('price').AsSmallInts[AIndex]          := AModel.Price;
    Q.ParamByName('total').AsSmallInts[AIndex]          := AModel.Total;
    Q.ParamByName('stock_quantity').AsSmallInts[AIndex] := AModel.StockQuantity;
    Q.ParamByName('exchange_rate').AsSmallInts[AIndex]  := AModel.ExchangeRate;
  end;
end;

function TSysDecimalPlaceRepository.MapFromQuery(Q: TFDQuery): TSysDecimalPlace;
begin
  Result                := TSysDecimalPlace.Create;
  Result.Id             := Q.FieldByName('id').AsLargeInt;
  Result.Quantity       := Q.FieldByName('quantity').AsInteger;
  Result.Price          := Q.FieldByName('price').AsInteger;
  Result.Total          := Q.FieldByName('total').AsInteger;
  Result.StockQuantity  := Q.FieldByName('stock_quantity').AsInteger;
  Result.ExchangeRate   := Q.FieldByName('exchange_rate').AsInteger;
end;

function TSysDecimalPlaceRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT * FROM ' + Self.GetFullViewName(TSysDecimalPlace) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TSysDecimalPlaceRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TList<TSysDecimalPlace>;
var
  Q: TFDQuery;
  Item: TSysDecimalPlace;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TSysDecimalPlace>.Create(True);
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := Self.PrepareSelectFromView(AFilter, ALock, False, False);

    if Assigned(AFilter) and (AFilter.Count > 0) then
    begin
      for Criteria in AFilter do
        Q.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
    end;

    Q.ParamByName('locale').Value := TAppContext.Instance.CurrentUser.ActiveLanguage;

    Q.Open;
    while not Q.Eof do
    begin
      Item := MapFromQuery(Q);
      Result.Add(Item);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

function TSysDecimalPlaceRepository.DoFindById(AId: TValue; ALock: Boolean): TSysDecimalPlace;
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
    Q.Open;

    if not Q.IsEmpty then
      Result := MapFromQuery(Q);
  finally
    Q.Free;
    Criteria.Free;
  end;
end;

function TSysDecimalPlaceRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TSysDecimalPlace;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := nil;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := Self.PrepareSelectFromView(AFilter, ALock, True, False);

    if Assigned(AFilter) and (AFilter.Count > 0) then
      for Criteria in AFilter do
        Q.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
    Q.Open;

    if not Q.IsEmpty then
      Result := MapFromQuery(Q);
  finally
    Q.Free;
  end;
end;

procedure TSysDecimalPlaceRepository.DoAdd(AModel: TSysDecimalPlace);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareAddSql + ' RETURNING id';
    SetInsertParams(Q, AModel);
    Q.Open;
    AModel.Id := Q.FieldByName('id').AsLargeInt;
  finally
    Q.Free;
  end;
end;

procedure TSysDecimalPlaceRepository.DoAddBatch(AModels: TArray<TSysDecimalPlace>);
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
      SetInsertParams(Q, AModels[I], I);

    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TSysDecimalPlaceRepository.DoUpdate(AModel: TSysDecimalPlace);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareUpdateSql;
    SetUpdateParams(Q, AModel);
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TSysDecimalPlaceRepository.DoUpdateBatch(AModels: TArray<TSysDecimalPlace>);
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
      SetUpdateParams(Q, AModels[I], I);

    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TSysDecimalPlaceRepository.DoDelete(AID: TValue);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareDeleteSql + ' id = :id';
    Q.ParamByName('id').AsLargeInt := AID.AsInt64;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TSysDecimalPlaceRepository.DoDelete(AModel: TSysDecimalPlace);
begin
  Delete(AModel.Id);
end;

procedure TSysDecimalPlaceRepository.DoDeleteBatch(AModels: TArray<TSysDecimalPlace>);
var
  Q: TFDQuery;
  I, Count: Integer;
begin
  Count := Length(AModels);
  if Count = 0 then Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareDeleteSql + ' id = :id';
    Q.Params.ArraySize := Count;

    for I := 0 to Count - 1 do
      Q.ParamByName('id').AsLargeInts[I] := AModels[I].Id;

    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TSysDecimalPlaceRepository.DoDeleteBatch(AIDs: TArray<TValue>);
var
  Q: TFDQuery;
  I, Count: Integer;
begin
  Count := Length(AIDs);
  if Count = 0 then Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareDeleteSql + ' id = :id';
    Q.Params.ArraySize := Count;

    for I := 0 to Count - 1 do
      Q.ParamByName('id').AsLargeInts[I] := AIDs[I].AsInt64;

    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TSysDecimalPlaceRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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

    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

end.
