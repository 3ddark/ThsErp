unit AccExchangeRate.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, AccExchangeRate;

type
  TAccExchangeRateRepository = class(TRepository<TAccExchangeRate>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TAccExchangeRate; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TAccExchangeRate; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TAccExchangeRate; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TAccExchangeRate>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TAccExchangeRate; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TAccExchangeRate; override;

    procedure DoAdd(AModel: TAccExchangeRate); override;
    procedure DoAddBatch(AModels: TArray<TAccExchangeRate>); override;

    procedure DoUpdate(AModel: TAccExchangeRate); override;
    procedure DoUpdateBatch(AModels: TArray<TAccExchangeRate>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TAccExchangeRate); override;
    procedure DoDeleteBatch(AModels: TArray<TAccExchangeRate>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
    // O gün için (herhangi kaynaktan) kur var mı
    function HasRateOn(ADate: TDate): Boolean;
    // TCMB kuru: yoksa eklenir, TCMB kaynaklıysa güncellenir, elle girilmiş (MANUAL) satıra dokunulmaz;
    // sys_currency'de tanımlı olmayan döviz atlanır. Yazıldıysa True.
    function UpsertTcmb(ADate: TDate; const ACurrency: string; AForexBuying, AForexSelling, ABanknoteBuying,
      ABanknoteSelling: Double): Boolean;
    // 1 ACurrency = ? ana para (fn_exchange_rate: o güne kadarki son döviz alış kuru); yoksa 0
    function GetRate(const ACurrency: string; ADate: TDate): Double;
  end;

implementation

constructor TAccExchangeRateRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TAccExchangeRateRepository.HasRateOn(ADate: TDate): Boolean;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT EXISTS (SELECT 1 FROM public.acc_exchange_rate WHERE rate_date = :rate_date) AS v';
    Q.ParamByName('rate_date').DataType := ftDate;
    Q.ParamByName('rate_date').AsDate := ADate;
    LogQuery(Q, 'HasRateOn');
    Q.Open;
    Result := Q.FieldByName('v').AsBoolean;
  finally
    Q.Free;
  end;
end;

function TAccExchangeRateRepository.UpsertTcmb(ADate: TDate; const ACurrency: string; AForexBuying, AForexSelling,
  ABanknoteBuying, ABanknoteSelling: Double): Boolean;
var
  Q: TFDQuery;

  procedure SetRate(const AName: string; AValue: Double);
  begin
    Q.ParamByName(AName).DataType := ftFloat;
    if AValue > 0 then
      Q.ParamByName(AName).AsFloat := AValue
    else
      Q.ParamByName(AName).Clear;
  end;

begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text :=
      'INSERT INTO public.acc_exchange_rate (rate_date, currency, rate, forex_selling, banknote_buying, banknote_selling, source) ' +
      'SELECT :rate_date, c.currency, round(:rate::numeric, 6), round(:forex_selling::numeric, 6), ' +
      '       round(:banknote_buying::numeric, 6), round(:banknote_selling::numeric, 6), ''TCMB'' ' +
      '  FROM public.sys_currency c WHERE c.currency = :currency ' +
      'ON CONFLICT (rate_date, currency) DO UPDATE SET rate = EXCLUDED.rate, forex_selling = EXCLUDED.forex_selling, ' +
      '       banknote_buying = EXCLUDED.banknote_buying, banknote_selling = EXCLUDED.banknote_selling ' +
      ' WHERE acc_exchange_rate.source = ''TCMB''';
    Q.ParamByName('rate_date').DataType := ftDate;
    Q.ParamByName('rate_date').AsDate := ADate;
    Q.ParamByName('currency').DataType := ftWideString;
    Q.ParamByName('currency').AsWideString := ACurrency;
    SetRate('rate', AForexBuying);
    SetRate('forex_selling', AForexSelling);
    SetRate('banknote_buying', ABanknoteBuying);
    SetRate('banknote_selling', ABanknoteSelling);
    LogQuery(Q, 'UpsertTcmb');
    Q.ExecSQL;
    Result := Q.RowsAffected > 0;
  finally
    Q.Free;
  end;
end;

function TAccExchangeRateRepository.GetRate(const ACurrency: string; ADate: TDate): Double;
var
  Q: TFDQuery;
begin
  Result := 0;
  if (Trim(ACurrency) = '') or (ADate <= 0) then
    Exit;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT public.fn_exchange_rate(:currency, :rate_date)::float8 AS v';
    Q.ParamByName('currency').DataType := ftWideString;
    Q.ParamByName('currency').AsWideString := ACurrency;
    Q.ParamByName('rate_date').DataType := ftDate;
    Q.ParamByName('rate_date').AsDate := ADate;
    LogQuery(Q, 'GetRate');
    Q.Open;
    if not Q.FieldByName('v').IsNull then
      Result := Q.FieldByName('v').AsFloat;
  finally
    Q.Free;
  end;
end;

function TAccExchangeRateRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TAccExchangeRate) +
            ' (rate_date, currency, rate, forex_selling, banknote_buying, banknote_selling, source) ' +
            ' VALUES (:rate_date, :currency, :rate, :forex_selling, :banknote_buying, :banknote_selling, :source)';
end;

function TAccExchangeRateRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TAccExchangeRate) +
            ' SET rate_date = :rate_date, currency = :currency, rate = :rate, forex_selling = :forex_selling, ' +
            '     banknote_buying = :banknote_buying, banknote_selling = :banknote_selling, source = :source ' +
            ' WHERE id = :id';
end;

function TAccExchangeRateRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TAccExchangeRate) + ' WHERE';
end;

procedure TAccExchangeRateRepository.SetInsertParams(Q: TFDQuery; AModel: TAccExchangeRate; AIndex: Integer);

  procedure SetDate(const AName: string; AValue: TDate);
  begin
    Q.ParamByName(AName).DataType := ftDate;
    if AValue > 0 then
    begin
      if AIndex < 0 then
        Q.ParamByName(AName).AsDate := AValue
      else
        Q.ParamByName(AName).AsDates[AIndex] := AValue;
    end
    else if AIndex < 0 then
      Q.ParamByName(AName).Clear
    else
      Q.ParamByName(AName).Clear(AIndex);
  end;


  // Kod ile bağlanan FK: boş değer NULL gönderilir
  procedure SetCode(const AName, AValue: string);
  begin
    Q.ParamByName(AName).DataType := ftWideString;
    if AValue <> '' then
    begin
      if AIndex < 0 then
        Q.ParamByName(AName).AsWideString := AValue
      else
        Q.ParamByName(AName).AsWideStrings[AIndex] := AValue;
    end
    else if AIndex < 0 then
      Q.ParamByName(AName).Clear
    else
      Q.ParamByName(AName).Clear(AIndex);
  end;

begin
  if AIndex < 0 then
  begin
    Q.ParamByName('rate').AsBCD := AModel.Rate;
    Q.ParamByName('forex_selling').AsBCD := AModel.ForexSelling;
    Q.ParamByName('banknote_buying').AsBCD := AModel.BanknoteBuying;
    Q.ParamByName('banknote_selling').AsBCD := AModel.BanknoteSelling;
    Q.ParamByName('source').AsWideString := AModel.Source;
  end
  else
  begin
    Q.ParamByName('rate').AsBCDs[AIndex] := AModel.Rate;
    Q.ParamByName('forex_selling').AsBCDs[AIndex] := AModel.ForexSelling;
    Q.ParamByName('banknote_buying').AsBCDs[AIndex] := AModel.BanknoteBuying;
    Q.ParamByName('banknote_selling').AsBCDs[AIndex] := AModel.BanknoteSelling;
    Q.ParamByName('source').AsWideStrings[AIndex] := AModel.Source;
  end;

  SetDate('rate_date', AModel.RateDate);
  SetCode('currency', AModel.Currency);
end;

procedure TAccExchangeRateRepository.SetUpdateParams(Q: TFDQuery; AModel: TAccExchangeRate; AIndex: Integer);

  procedure SetDate(const AName: string; AValue: TDate);
  begin
    Q.ParamByName(AName).DataType := ftDate;
    if AValue > 0 then
    begin
      if AIndex < 0 then
        Q.ParamByName(AName).AsDate := AValue
      else
        Q.ParamByName(AName).AsDates[AIndex] := AValue;
    end
    else if AIndex < 0 then
      Q.ParamByName(AName).Clear
    else
      Q.ParamByName(AName).Clear(AIndex);
  end;


  // Kod ile bağlanan FK: boş değer NULL gönderilir
  procedure SetCode(const AName, AValue: string);
  begin
    Q.ParamByName(AName).DataType := ftWideString;
    if AValue <> '' then
    begin
      if AIndex < 0 then
        Q.ParamByName(AName).AsWideString := AValue
      else
        Q.ParamByName(AName).AsWideStrings[AIndex] := AValue;
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
    Q.ParamByName('rate').AsBCD := AModel.Rate;
    Q.ParamByName('forex_selling').AsBCD := AModel.ForexSelling;
    Q.ParamByName('banknote_buying').AsBCD := AModel.BanknoteBuying;
    Q.ParamByName('banknote_selling').AsBCD := AModel.BanknoteSelling;
    Q.ParamByName('source').AsWideString := AModel.Source;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('rate').AsBCDs[AIndex] := AModel.Rate;
    Q.ParamByName('forex_selling').AsBCDs[AIndex] := AModel.ForexSelling;
    Q.ParamByName('banknote_buying').AsBCDs[AIndex] := AModel.BanknoteBuying;
    Q.ParamByName('banknote_selling').AsBCDs[AIndex] := AModel.BanknoteSelling;
    Q.ParamByName('source').AsWideStrings[AIndex] := AModel.Source;
  end;

  SetDate('rate_date', AModel.RateDate);
  SetCode('currency', AModel.Currency);
end;

function TAccExchangeRateRepository.MapFromQuery(Q: TFDQuery): TAccExchangeRate;
begin
  Result := TAccExchangeRate.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  if Q.FieldByName('rate_date').IsNull then
    Result.RateDate := 0
  else
    Result.RateDate := Q.FieldByName('rate_date').AsDateTime;
  Result.Currency := Q.FieldByName('currency').AsString;
  Result.Rate := Q.FieldByName('rate').AsCurrency;
  Result.ForexSelling := Q.FieldByName('forex_selling').AsCurrency;
  Result.BanknoteBuying := Q.FieldByName('banknote_buying').AsCurrency;
  Result.BanknoteSelling := Q.FieldByName('banknote_selling').AsCurrency;
  Result.Source := Q.FieldByName('source').AsString;
end;

function TAccExchangeRateRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TAccExchangeRate) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TAccExchangeRateRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TAccExchangeRate>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TAccExchangeRate>.Create(True);
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

function TAccExchangeRateRepository.DoFindById(AId: TValue; ALock: Boolean): TAccExchangeRate;
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

function TAccExchangeRateRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TAccExchangeRate;
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

procedure TAccExchangeRateRepository.DoAdd(AModel: TAccExchangeRate);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareAddSql + ' RETURNING id';
    SetInsertParams(Q, AModel);
    ApplyNullPolicy(Q);
    LogQuery(Q, 'DoAdd');
    Q.Open;
    AModel.Id := Q.FieldByName('id').AsLargeInt;
  finally
    Q.Free;
  end;
end;

procedure TAccExchangeRateRepository.DoAddBatch(AModels: TArray<TAccExchangeRate>);
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

    ApplyNullPolicy(Q);

    LogQuery(Q, 'DoAddBatch');
    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TAccExchangeRateRepository.DoUpdate(AModel: TAccExchangeRate);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareUpdateSql;
    SetUpdateParams(Q, AModel);
    ApplyNullPolicy(Q);
    LogQuery(Q, 'DoUpdate');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TAccExchangeRateRepository.DoUpdateBatch(AModels: TArray<TAccExchangeRate>);
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

    ApplyNullPolicy(Q);

    LogQuery(Q, 'DoUpdateBatch');
    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TAccExchangeRateRepository.DoDelete(AID: TValue);
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

procedure TAccExchangeRateRepository.DoDelete(AModel: TAccExchangeRate);
begin
  Delete(AModel.Id);
end;

procedure TAccExchangeRateRepository.DoDeleteBatch(AModels: TArray<TAccExchangeRate>);
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

procedure TAccExchangeRateRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TAccExchangeRateRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
