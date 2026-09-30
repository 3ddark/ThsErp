unit AccSetTaxRate.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, AccSetTaxRate;

type
  TAccSetTaxRateRepository = class(TRepository<TAccSetTaxRate>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TAccSetTaxRate; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TAccSetTaxRate; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TAccSetTaxRate; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TAccSetTaxRate>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TAccSetTaxRate; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TAccSetTaxRate; override;

    procedure DoAdd(AModel: TAccSetTaxRate); override;
    procedure DoAddBatch(AModels: TArray<TAccSetTaxRate>); override;

    procedure DoUpdate(AModel: TAccSetTaxRate); override;
    procedure DoUpdateBatch(AModels: TArray<TAccSetTaxRate>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TAccSetTaxRate); override;
    procedure DoDeleteBatch(AModels: TArray<TAccSetTaxRate>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TAccSetTaxRateRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TAccSetTaxRateRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TAccSetTaxRate) +
            ' (tax_rate, sales_account, sales_return_account, purchase_account, purchase_return_account) ' +
            ' VALUES (:tax_rate, :sales_account, :sales_return_account, :purchase_account, :purchase_return_account)';
end;

function TAccSetTaxRateRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TAccSetTaxRate) +
            ' SET tax_rate = :tax_rate, sales_account = :sales_account, sales_return_account = :sales_return_account, purchase_account = :purchase_account, purchase_return_account = :purchase_return_account ' +
            ' WHERE id = :id';
end;

function TAccSetTaxRateRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TAccSetTaxRate) + ' WHERE';
end;

procedure TAccSetTaxRateRepository.SetInsertParams(Q: TFDQuery; AModel: TAccSetTaxRate; AIndex: Integer);

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
    Q.ParamByName('tax_rate').AsCurrency := AModel.TaxRate;
  end
  else
  begin
    Q.ParamByName('tax_rate').AsCurrencys[AIndex] := AModel.TaxRate;
  end;

  SetCode('sales_account', AModel.SalesAccount);
  SetCode('sales_return_account', AModel.SalesReturnAccount);
  SetCode('purchase_account', AModel.PurchaseAccount);
  SetCode('purchase_return_account', AModel.PurchaseReturnAccount);
end;

procedure TAccSetTaxRateRepository.SetUpdateParams(Q: TFDQuery; AModel: TAccSetTaxRate; AIndex: Integer);

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
    Q.ParamByName('tax_rate').AsCurrency := AModel.TaxRate;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('tax_rate').AsCurrencys[AIndex] := AModel.TaxRate;
  end;

  SetCode('sales_account', AModel.SalesAccount);
  SetCode('sales_return_account', AModel.SalesReturnAccount);
  SetCode('purchase_account', AModel.PurchaseAccount);
  SetCode('purchase_return_account', AModel.PurchaseReturnAccount);
end;

function TAccSetTaxRateRepository.MapFromQuery(Q: TFDQuery): TAccSetTaxRate;
begin
  Result := TAccSetTaxRate.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.TaxRate := Q.FieldByName('tax_rate').AsCurrency;
  Result.SalesAccount := Q.FieldByName('sales_account').AsString;
  Result.SalesReturnAccount := Q.FieldByName('sales_return_account').AsString;
  Result.PurchaseAccount := Q.FieldByName('purchase_account').AsString;
  Result.PurchaseReturnAccount := Q.FieldByName('purchase_return_account').AsString;
end;

function TAccSetTaxRateRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TAccSetTaxRate) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TAccSetTaxRateRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TAccSetTaxRate>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TAccSetTaxRate>.Create(True);
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

function TAccSetTaxRateRepository.DoFindById(AId: TValue; ALock: Boolean): TAccSetTaxRate;
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

function TAccSetTaxRateRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TAccSetTaxRate;
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

procedure TAccSetTaxRateRepository.DoAdd(AModel: TAccSetTaxRate);
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

procedure TAccSetTaxRateRepository.DoAddBatch(AModels: TArray<TAccSetTaxRate>);
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

procedure TAccSetTaxRateRepository.DoUpdate(AModel: TAccSetTaxRate);
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

procedure TAccSetTaxRateRepository.DoUpdateBatch(AModels: TArray<TAccSetTaxRate>);
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

procedure TAccSetTaxRateRepository.DoDelete(AID: TValue);
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

procedure TAccSetTaxRateRepository.DoDelete(AModel: TAccSetTaxRate);
begin
  Delete(AModel.Id);
end;

procedure TAccSetTaxRateRepository.DoDeleteBatch(AModels: TArray<TAccSetTaxRate>);
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

procedure TAccSetTaxRateRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TAccSetTaxRateRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
