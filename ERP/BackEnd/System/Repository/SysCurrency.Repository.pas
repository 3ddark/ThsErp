unit SysCurrency.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, Service,
  FilterCriterion, UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  SysCurrency;

type
  TSysCurrencyRepository = class(TRepository<TSysCurrency>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TSysCurrency; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TSysCurrency; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TSysCurrency; override;


    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TList<TSysCurrency>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TSysCurrency; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TSysCurrency; override;

    procedure DoAdd(AModel: TSysCurrency); override;
    procedure DoAddBatch(AModels: TArray<TSysCurrency>); override;

    procedure DoUpdate(AModel: TSysCurrency); override;
    procedure DoUpdateBatch(AModels: TArray<TSysCurrency>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TSysCurrency); override;
    procedure DoDeleteBatch(AModels: TArray<TSysCurrency>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TSysCurrencyRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSysCurrencyRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TSysCurrency) + ' (currency, symbol, description) VALUES (:currency, :symbol, :description)';
end;

function TSysCurrencyRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TSysCurrency) + ' SET currency = :currency, symbol = :symbol, description = :description WHERE id = :id';
end;

function TSysCurrencyRepository.PrepareDeleteSql: string;
begin
  //WHERE kýsmý özellikle böyle yazýldý. Filtre vermeden iþlem yapýlmamasý için. Hatalý kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TSysCurrency) + ' WHERE';
end;

procedure TSysCurrencyRepository.SetInsertParams(Q: TFDQuery; AModel: TSysCurrency; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('currency').AsString := AModel.Currency;
    Q.ParamByName('symbol').AsString := AModel.Symbol;
    Q.ParamByName('description').AsString := AModel.Description;
  end
  else
  begin
    Q.ParamByName('currency').AsStrings[AIndex] := AModel.Currency;
    Q.ParamByName('symbol').AsStrings[AIndex] := AModel.Symbol;
    Q.ParamByName('description').AsStrings[AIndex] := AModel.Description;
  end;
end;

procedure TSysCurrencyRepository.SetUpdateParams(Q: TFDQuery; AModel: TSysCurrency; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('id').AsSmallInt := AModel.Id;
    Q.ParamByName('currency').AsString := AModel.Currency;
    Q.ParamByName('symbol').AsString := AModel.Symbol;
    Q.ParamByName('description').AsString := AModel.Description;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('currency').AsStrings[AIndex] := AModel.Currency;
    Q.ParamByName('symbol').AsStrings[AIndex] := AModel.Symbol;
    Q.ParamByName('description').AsStrings[AIndex] := AModel.Description;
  end;
end;

function TSysCurrencyRepository.MapFromQuery(Q: TFDQuery): TSysCurrency;
begin
  Result := TSysCurrency.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.Currency := Q.FieldByName('currency').AsString;
  Result.Symbol := Q.FieldByName('symbol').AsString;
  Result.Description := Q.FieldByName('description').AsString;
end;

function TSysCurrencyRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT * FROM ' + Self.GetFullViewName(TSysCurrency) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TSysCurrencyRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TList<TSysCurrency>;
var
  Q: TFDQuery;
  Item: TSysCurrency;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TSysCurrency>.Create(True);
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

function TSysCurrencyRepository.DoFindById(AId: TValue; ALock: Boolean): TSysCurrency;
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

function TSysCurrencyRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TSysCurrency;
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

procedure TSysCurrencyRepository.DoAdd(AModel: TSysCurrency);
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

procedure TSysCurrencyRepository.DoAddBatch(AModels: TArray<TSysCurrency>);
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

procedure TSysCurrencyRepository.DoUpdate(AModel: TSysCurrency);
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

procedure TSysCurrencyRepository.DoUpdateBatch(AModels: TArray<TSysCurrency>);
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

procedure TSysCurrencyRepository.DoDelete(AID: TValue);
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

procedure TSysCurrencyRepository.DoDelete(AModel: TSysCurrency);
begin
  Delete(AModel.Id);
end;

procedure TSysCurrencyRepository.DoDeleteBatch(AModels: TArray<TSysCurrency>);
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

procedure TSysCurrencyRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TSysCurrencyRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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

