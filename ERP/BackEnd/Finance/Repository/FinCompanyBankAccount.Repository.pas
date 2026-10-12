unit FinCompanyBankAccount.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, FinCompanyBankAccount;

type
  TFinCompanyBankAccountRepository = class(TRepository<TFinCompanyBankAccount>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TFinCompanyBankAccount; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TFinCompanyBankAccount; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TFinCompanyBankAccount; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TFinCompanyBankAccount>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TFinCompanyBankAccount; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TFinCompanyBankAccount; override;

    procedure DoAdd(AModel: TFinCompanyBankAccount); override;
    procedure DoAddBatch(AModels: TArray<TFinCompanyBankAccount>); override;

    procedure DoUpdate(AModel: TFinCompanyBankAccount); override;
    procedure DoUpdateBatch(AModels: TArray<TFinCompanyBankAccount>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TFinCompanyBankAccount); override;
    procedure DoDeleteBatch(AModels: TArray<TFinCompanyBankAccount>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
    function UsageCount(AAccountId: Int64): Integer;
    function GetPrintLines(AUsage: SmallInt): TArray<string>;
    function GetDefaultCurrency: string;
  end;

implementation

constructor TFinCompanyBankAccountRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

// Hesabı kullanan çek / senet sayısı
function TFinCompanyBankAccountRepository.UsageCount(AAccountId: Int64): Integer;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT count(*) AS cnt FROM public.fin_cheque_note WHERE fin_company_bank_account_id = :id';
    Q.ParamByName('id').AsLargeInt := AAccountId;
    LogQuery(Q, 'UsageCount');
    Q.Open;
    Result := Q.FieldByName('cnt').AsInteger;
  finally
    Q.Free;
  end;
end;

// AUsage: 1 çek, 2 senet, 3 çıktı (FIN_BANK_USAGE_*)
function TFinCompanyBankAccountRepository.GetPrintLines(AUsage: SmallInt): TArray<string>;
var
  Q: TFDQuery;
  LFlag: string;
begin
  Result := [];
  case AUsage of
    1: LFlag := 'show_on_cheque';
    2: LFlag := 'show_on_note';
  else
    LFlag := 'show_on_print';
  end;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT print_text FROM ' + Self.GetFullViewName(TFinCompanyBankAccount) +
                  ' WHERE is_active AND ' + LFlag + ' ORDER BY sort_order, id';
    LogQuery(Q, 'GetPrintLines');
    Q.Open;
    while not Q.Eof do
    begin
      Result := Result + [Q.FieldByName('print_text').AsString];
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

function TFinCompanyBankAccountRepository.GetDefaultCurrency: string;
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

function TFinCompanyBankAccountRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TFinCompanyBankAccount) +
            ' (acc_bank_id, branch_code, branch_name, sys_city_id, account_no, iban, currency, account_holder, show_on_cheque, show_on_note, show_on_print, sort_order, is_active, description) ' +
            ' VALUES (:acc_bank_id, :branch_code, :branch_name, :sys_city_id, :account_no, :iban, :currency, :account_holder, :show_on_cheque, :show_on_note, :show_on_print, :sort_order, :is_active, :description)';
end;

function TFinCompanyBankAccountRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TFinCompanyBankAccount) +
            ' SET acc_bank_id = :acc_bank_id, branch_code = :branch_code, branch_name = :branch_name, sys_city_id = :sys_city_id, account_no = :account_no, iban = :iban, currency = :currency, account_holder = :account_holder, show_on_cheque = :show_on_cheque, show_on_note = :show_on_note, show_on_print = :show_on_print, sort_order = :sort_order, is_active = :is_active, description = :description ' +
            ' WHERE id = :id';
end;

function TFinCompanyBankAccountRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TFinCompanyBankAccount) + ' WHERE';
end;

procedure TFinCompanyBankAccountRepository.SetInsertParams(Q: TFDQuery; AModel: TFinCompanyBankAccount; AIndex: Integer);

begin
  if AIndex < 0 then
  begin
    Q.ParamByName('branch_code').AsWideString := AModel.BranchCode;
    Q.ParamByName('branch_name').AsWideString := AModel.BranchName;
    Q.ParamByName('account_no').AsWideString := AModel.AccountNo;
    Q.ParamByName('iban').AsWideString := AModel.Iban;
    Q.ParamByName('currency').AsWideString := AModel.Currency;
    Q.ParamByName('account_holder').AsWideString := AModel.AccountHolder;
    Q.ParamByName('show_on_cheque').AsBoolean := AModel.ShowOnCheque;
    Q.ParamByName('show_on_note').AsBoolean := AModel.ShowOnNote;
    Q.ParamByName('show_on_print').AsBoolean := AModel.ShowOnPrint;
    Q.ParamByName('sort_order').AsSmallInt := AModel.SortOrder;
    Q.ParamByName('is_active').AsBoolean := AModel.IsActive;
    Q.ParamByName('description').AsWideString := AModel.Description;
  end
  else
  begin
    Q.ParamByName('branch_code').AsWideStrings[AIndex] := AModel.BranchCode;
    Q.ParamByName('branch_name').AsWideStrings[AIndex] := AModel.BranchName;
    Q.ParamByName('account_no').AsWideStrings[AIndex] := AModel.AccountNo;
    Q.ParamByName('iban').AsWideStrings[AIndex] := AModel.Iban;
    Q.ParamByName('currency').AsWideStrings[AIndex] := AModel.Currency;
    Q.ParamByName('account_holder').AsWideStrings[AIndex] := AModel.AccountHolder;
    Q.ParamByName('show_on_cheque').AsBooleans[AIndex] := AModel.ShowOnCheque;
    Q.ParamByName('show_on_note').AsBooleans[AIndex] := AModel.ShowOnNote;
    Q.ParamByName('show_on_print').AsBooleans[AIndex] := AModel.ShowOnPrint;
    Q.ParamByName('sort_order').AsSmallInts[AIndex] := AModel.SortOrder;
    Q.ParamByName('is_active').AsBooleans[AIndex] := AModel.IsActive;
    Q.ParamByName('description').AsWideStrings[AIndex] := AModel.Description;
  end;

  SetNullableParam(Q.ParamByName('acc_bank_id'), ftLargeint, AModel.AccBankId, AIndex);
  SetNullableParam(Q.ParamByName('sys_city_id'), ftLargeint, AModel.SysCityId, AIndex);
end;

procedure TFinCompanyBankAccountRepository.SetUpdateParams(Q: TFDQuery; AModel: TFinCompanyBankAccount; AIndex: Integer);

begin
  if AIndex < 0 then
  begin
    Q.ParamByName('id').AsLargeInt := AModel.Id;
    Q.ParamByName('branch_code').AsWideString := AModel.BranchCode;
    Q.ParamByName('branch_name').AsWideString := AModel.BranchName;
    Q.ParamByName('account_no').AsWideString := AModel.AccountNo;
    Q.ParamByName('iban').AsWideString := AModel.Iban;
    Q.ParamByName('currency').AsWideString := AModel.Currency;
    Q.ParamByName('account_holder').AsWideString := AModel.AccountHolder;
    Q.ParamByName('show_on_cheque').AsBoolean := AModel.ShowOnCheque;
    Q.ParamByName('show_on_note').AsBoolean := AModel.ShowOnNote;
    Q.ParamByName('show_on_print').AsBoolean := AModel.ShowOnPrint;
    Q.ParamByName('sort_order').AsSmallInt := AModel.SortOrder;
    Q.ParamByName('is_active').AsBoolean := AModel.IsActive;
    Q.ParamByName('description').AsWideString := AModel.Description;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('branch_code').AsWideStrings[AIndex] := AModel.BranchCode;
    Q.ParamByName('branch_name').AsWideStrings[AIndex] := AModel.BranchName;
    Q.ParamByName('account_no').AsWideStrings[AIndex] := AModel.AccountNo;
    Q.ParamByName('iban').AsWideStrings[AIndex] := AModel.Iban;
    Q.ParamByName('currency').AsWideStrings[AIndex] := AModel.Currency;
    Q.ParamByName('account_holder').AsWideStrings[AIndex] := AModel.AccountHolder;
    Q.ParamByName('show_on_cheque').AsBooleans[AIndex] := AModel.ShowOnCheque;
    Q.ParamByName('show_on_note').AsBooleans[AIndex] := AModel.ShowOnNote;
    Q.ParamByName('show_on_print').AsBooleans[AIndex] := AModel.ShowOnPrint;
    Q.ParamByName('sort_order').AsSmallInts[AIndex] := AModel.SortOrder;
    Q.ParamByName('is_active').AsBooleans[AIndex] := AModel.IsActive;
    Q.ParamByName('description').AsWideStrings[AIndex] := AModel.Description;
  end;

  SetNullableParam(Q.ParamByName('acc_bank_id'), ftLargeint, AModel.AccBankId, AIndex);
  SetNullableParam(Q.ParamByName('sys_city_id'), ftLargeint, AModel.SysCityId, AIndex);
end;

function TFinCompanyBankAccountRepository.MapFromQuery(Q: TFDQuery): TFinCompanyBankAccount;
begin
  Result := TFinCompanyBankAccount.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.AccBankId := Q.FieldByName('acc_bank_id').AsLargeInt;
  Result.BranchCode := Q.FieldByName('branch_code').AsString;
  Result.BranchName := Q.FieldByName('branch_name').AsString;
  Result.SysCityId := Q.FieldByName('sys_city_id').AsLargeInt;
  Result.AccountNo := Q.FieldByName('account_no').AsString;
  Result.Iban := Q.FieldByName('iban').AsString;
  Result.Currency := Q.FieldByName('currency').AsString;
  Result.AccountHolder := Q.FieldByName('account_holder').AsString;
  Result.ShowOnCheque := Q.FieldByName('show_on_cheque').AsBoolean;
  Result.ShowOnNote := Q.FieldByName('show_on_note').AsBoolean;
  Result.ShowOnPrint := Q.FieldByName('show_on_print').AsBoolean;
  Result.SortOrder := Q.FieldByName('sort_order').AsInteger;
  Result.IsActive := Q.FieldByName('is_active').AsBoolean;
  Result.Description := Q.FieldByName('description').AsString;
  Result.BankName := Q.FieldByName('bank_name').AsString;
  Result.CityName := Q.FieldByName('city_name').AsString;
  Result.PrintText := Q.FieldByName('print_text').AsString;
end;

function TFinCompanyBankAccountRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TFinCompanyBankAccount) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TFinCompanyBankAccountRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TFinCompanyBankAccount>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TFinCompanyBankAccount>.Create(True);
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

function TFinCompanyBankAccountRepository.DoFindById(AId: TValue; ALock: Boolean): TFinCompanyBankAccount;
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

function TFinCompanyBankAccountRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TFinCompanyBankAccount;
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

procedure TFinCompanyBankAccountRepository.DoAdd(AModel: TFinCompanyBankAccount);
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

procedure TFinCompanyBankAccountRepository.DoAddBatch(AModels: TArray<TFinCompanyBankAccount>);
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

procedure TFinCompanyBankAccountRepository.DoUpdate(AModel: TFinCompanyBankAccount);
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

procedure TFinCompanyBankAccountRepository.DoUpdateBatch(AModels: TArray<TFinCompanyBankAccount>);
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

procedure TFinCompanyBankAccountRepository.DoDelete(AID: TValue);
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

procedure TFinCompanyBankAccountRepository.DoDelete(AModel: TFinCompanyBankAccount);
begin
  Delete(AModel.Id);
end;

procedure TFinCompanyBankAccountRepository.DoDeleteBatch(AModels: TArray<TFinCompanyBankAccount>);
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

procedure TFinCompanyBankAccountRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TFinCompanyBankAccountRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
