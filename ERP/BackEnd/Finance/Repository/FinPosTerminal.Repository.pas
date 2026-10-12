unit FinPosTerminal.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, FinPosTerminal;

type
  TFinPosTerminalRepository = class(TRepository<TFinPosTerminal>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TFinPosTerminal; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TFinPosTerminal; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TFinPosTerminal; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TFinPosTerminal>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TFinPosTerminal; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TFinPosTerminal; override;

    procedure DoAdd(AModel: TFinPosTerminal); override;
    procedure DoAddBatch(AModels: TArray<TFinPosTerminal>); override;

    procedure DoUpdate(AModel: TFinPosTerminal); override;
    procedure DoUpdateBatch(AModels: TArray<TFinPosTerminal>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TFinPosTerminal); override;
    procedure DoDeleteBatch(AModels: TArray<TFinPosTerminal>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
    function TransactionCount(APosId: Int64): Integer;
    function GetDefaultCurrency: string;
  end;

implementation

constructor TFinPosTerminalRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TFinPosTerminalRepository.TransactionCount(APosId: Int64): Integer;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT count(*) AS cnt FROM public.fin_pos_transaction WHERE fin_pos_terminal_id = :id';
    Q.ParamByName('id').AsLargeInt := APosId;
    LogQuery(Q, 'TransactionCount');
    Q.Open;
    Result := Q.FieldByName('cnt').AsInteger;
  finally
    Q.Free;
  end;
end;

function TFinPosTerminalRepository.GetDefaultCurrency: string;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT public.fn_default_currency() AS currency';
    LogQuery(Q, 'GetDefaultCurrency');
    Q.Open;
    Result := Q.FieldByName('currency').AsString;
  finally
    Q.Free;
  end;
end;

function TFinPosTerminalRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TFinPosTerminal) +
            ' (pos_name, acc_bank_id, terminal_no, commission_rate, blocked_days, currency, acc_account_code, is_active, notes) ' +
            ' VALUES (:pos_name, :acc_bank_id, :terminal_no, :commission_rate, :blocked_days, :currency, :acc_account_code, :is_active, :notes)';
end;

function TFinPosTerminalRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TFinPosTerminal) +
            ' SET pos_name = :pos_name, acc_bank_id = :acc_bank_id, terminal_no = :terminal_no, commission_rate = :commission_rate, blocked_days = :blocked_days, currency = :currency, acc_account_code = :acc_account_code, is_active = :is_active, notes = :notes ' +
            ' WHERE id = :id';
end;

function TFinPosTerminalRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TFinPosTerminal) + ' WHERE';
end;

procedure TFinPosTerminalRepository.SetInsertParams(Q: TFDQuery; AModel: TFinPosTerminal; AIndex: Integer);

begin
  if AIndex < 0 then
  begin
    Q.ParamByName('pos_name').AsWideString := AModel.PosName;
    Q.ParamByName('terminal_no').AsWideString := AModel.TerminalNo;
    Q.ParamByName('commission_rate').AsBCD := AModel.CommissionRate;
    Q.ParamByName('blocked_days').AsSmallInt := AModel.BlockedDays;
    Q.ParamByName('currency').AsWideString := AModel.Currency;
    Q.ParamByName('acc_account_code').AsWideString := AModel.AccAccountCode;
    Q.ParamByName('is_active').AsBoolean := AModel.IsActive;
    Q.ParamByName('notes').AsWideString := AModel.Notes;
  end
  else
  begin
    Q.ParamByName('pos_name').AsWideStrings[AIndex] := AModel.PosName;
    Q.ParamByName('terminal_no').AsWideStrings[AIndex] := AModel.TerminalNo;
    Q.ParamByName('commission_rate').AsBCDs[AIndex] := AModel.CommissionRate;
    Q.ParamByName('blocked_days').AsSmallInts[AIndex] := AModel.BlockedDays;
    Q.ParamByName('currency').AsWideStrings[AIndex] := AModel.Currency;
    Q.ParamByName('acc_account_code').AsWideStrings[AIndex] := AModel.AccAccountCode;
    Q.ParamByName('is_active').AsBooleans[AIndex] := AModel.IsActive;
    Q.ParamByName('notes').AsWideStrings[AIndex] := AModel.Notes;
  end;

  SetNullableParam(Q.ParamByName('acc_bank_id'), ftLargeint, AModel.AccBankId, AIndex);
end;

procedure TFinPosTerminalRepository.SetUpdateParams(Q: TFDQuery; AModel: TFinPosTerminal; AIndex: Integer);

begin
  if AIndex < 0 then
  begin
    Q.ParamByName('id').AsLargeInt := AModel.Id;
    Q.ParamByName('pos_name').AsWideString := AModel.PosName;
    Q.ParamByName('terminal_no').AsWideString := AModel.TerminalNo;
    Q.ParamByName('commission_rate').AsBCD := AModel.CommissionRate;
    Q.ParamByName('blocked_days').AsSmallInt := AModel.BlockedDays;
    Q.ParamByName('currency').AsWideString := AModel.Currency;
    Q.ParamByName('acc_account_code').AsWideString := AModel.AccAccountCode;
    Q.ParamByName('is_active').AsBoolean := AModel.IsActive;
    Q.ParamByName('notes').AsWideString := AModel.Notes;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('pos_name').AsWideStrings[AIndex] := AModel.PosName;
    Q.ParamByName('terminal_no').AsWideStrings[AIndex] := AModel.TerminalNo;
    Q.ParamByName('commission_rate').AsBCDs[AIndex] := AModel.CommissionRate;
    Q.ParamByName('blocked_days').AsSmallInts[AIndex] := AModel.BlockedDays;
    Q.ParamByName('currency').AsWideStrings[AIndex] := AModel.Currency;
    Q.ParamByName('acc_account_code').AsWideStrings[AIndex] := AModel.AccAccountCode;
    Q.ParamByName('is_active').AsBooleans[AIndex] := AModel.IsActive;
    Q.ParamByName('notes').AsWideStrings[AIndex] := AModel.Notes;
  end;

  SetNullableParam(Q.ParamByName('acc_bank_id'), ftLargeint, AModel.AccBankId, AIndex);
end;

function TFinPosTerminalRepository.MapFromQuery(Q: TFDQuery): TFinPosTerminal;
begin
  Result := TFinPosTerminal.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.PosName := Q.FieldByName('pos_name').AsString;
  Result.AccBankId := Q.FieldByName('acc_bank_id').AsLargeInt;
  Result.TerminalNo := Q.FieldByName('terminal_no').AsString;
  Result.CommissionRate := Q.FieldByName('commission_rate').AsCurrency;
  Result.BlockedDays := Q.FieldByName('blocked_days').AsInteger;
  Result.Currency := Q.FieldByName('currency').AsString;
  Result.AccAccountCode := Q.FieldByName('acc_account_code').AsString;
  Result.IsActive := Q.FieldByName('is_active').AsBoolean;
  Result.Notes := Q.FieldByName('notes').AsString;
  Result.BankName := Q.FieldByName('bank_name').AsString;
  Result.AccountName := Q.FieldByName('account_name').AsString;
end;

function TFinPosTerminalRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TFinPosTerminal) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TFinPosTerminalRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TFinPosTerminal>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TFinPosTerminal>.Create(True);
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

function TFinPosTerminalRepository.DoFindById(AId: TValue; ALock: Boolean): TFinPosTerminal;
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

function TFinPosTerminalRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TFinPosTerminal;
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

procedure TFinPosTerminalRepository.DoAdd(AModel: TFinPosTerminal);
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

procedure TFinPosTerminalRepository.DoAddBatch(AModels: TArray<TFinPosTerminal>);
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

procedure TFinPosTerminalRepository.DoUpdate(AModel: TFinPosTerminal);
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

procedure TFinPosTerminalRepository.DoUpdateBatch(AModels: TArray<TFinPosTerminal>);
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

procedure TFinPosTerminalRepository.DoDelete(AID: TValue);
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

procedure TFinPosTerminalRepository.DoDelete(AModel: TFinPosTerminal);
begin
  Delete(AModel.Id);
end;

procedure TFinPosTerminalRepository.DoDeleteBatch(AModels: TArray<TFinPosTerminal>);
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

procedure TFinPosTerminalRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TFinPosTerminalRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
