unit EInvDiib.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, EInvDiib;

type
  TEInvDiibRepository = class(TRepository<TEInvDiib>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TEInvDiib; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TEInvDiib; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TEInvDiib; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TEInvDiib>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TEInvDiib; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TEInvDiib; override;

    procedure DoAdd(AModel: TEInvDiib); override;
    procedure DoAddBatch(AModels: TArray<TEInvDiib>); override;

    procedure DoUpdate(AModel: TEInvDiib); override;
    procedure DoUpdateBatch(AModels: TArray<TEInvDiib>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TEInvDiib); override;
    procedure DoDeleteBatch(AModels: TArray<TEInvDiib>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
    function DocumentNoExists(const ADocumentNo: string; AExcludeId: Int64): Boolean;
    function UsedLineCount(AId: Int64): Integer;
  end;

implementation

constructor TEInvDiibRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TEInvDiibRepository.DocumentNoExists(const ADocumentNo: string; AExcludeId: Int64): Boolean;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT 1 FROM public.einv_diib WHERE document_no = :document_no AND id <> :id';
    Q.ParamByName('document_no').AsWideString := ADocumentNo;
    Q.ParamByName('id').AsLargeInt := AExcludeId;
    LogQuery(Q, 'DocumentNoExists');
    Q.Open;
    Result := not Q.IsEmpty;
  finally
    Q.Free;
  end;
end;

// Belgenin faturalarda kullanılan satır sayısı
function TEInvDiibRepository.UsedLineCount(AId: Int64): Integer;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT count(*) AS cnt FROM public.sls_invoice_detail d ' +
                  '  JOIN public.einv_diib_line l ON l.id IN (d.seller_einv_diib_line_id, d.buyer_einv_diib_line_id) ' +
                  ' WHERE l.einv_diib_id = :id';
    Q.ParamByName('id').AsLargeInt := AId;
    LogQuery(Q, 'UsedLineCount');
    Q.Open;
    Result := Q.FieldByName('cnt').AsInteger;
  finally
    Q.Free;
  end;
end;

function TEInvDiibRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TEInvDiib) +
            ' (document_no, holder_type, acc_account_id, issue_date, valid_until, description, is_active) ' +
            ' VALUES (:document_no, :holder_type, :acc_account_id, :issue_date, :valid_until, :description, :is_active)';
end;

function TEInvDiibRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TEInvDiib) +
            ' SET document_no = :document_no, holder_type = :holder_type, acc_account_id = :acc_account_id, issue_date = :issue_date, valid_until = :valid_until, description = :description, is_active = :is_active ' +
            ' WHERE id = :id';
end;

function TEInvDiibRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TEInvDiib) + ' WHERE';
end;

procedure TEInvDiibRepository.SetInsertParams(Q: TFDQuery; AModel: TEInvDiib; AIndex: Integer);

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

begin
  if AIndex < 0 then
  begin
    Q.ParamByName('document_no').AsWideString := AModel.DocumentNo;
    Q.ParamByName('holder_type').AsSmallInt := AModel.HolderType;
    Q.ParamByName('description').AsWideString := AModel.Description;
    Q.ParamByName('is_active').AsBoolean := AModel.IsActive;
  end
  else
  begin
    Q.ParamByName('document_no').AsWideStrings[AIndex] := AModel.DocumentNo;
    Q.ParamByName('holder_type').AsSmallInts[AIndex] := AModel.HolderType;
    Q.ParamByName('description').AsWideStrings[AIndex] := AModel.Description;
    Q.ParamByName('is_active').AsBooleans[AIndex] := AModel.IsActive;
  end;

  SetNullableParam(Q.ParamByName('acc_account_id'), ftLargeint, AModel.AccAccountId, AIndex);
  SetDate('issue_date', AModel.IssueDate);
  SetDate('valid_until', AModel.ValidUntil);
end;

procedure TEInvDiibRepository.SetUpdateParams(Q: TFDQuery; AModel: TEInvDiib; AIndex: Integer);

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

begin
  if AIndex < 0 then
  begin
    Q.ParamByName('id').AsLargeInt := AModel.Id;
    Q.ParamByName('document_no').AsWideString := AModel.DocumentNo;
    Q.ParamByName('holder_type').AsSmallInt := AModel.HolderType;
    Q.ParamByName('description').AsWideString := AModel.Description;
    Q.ParamByName('is_active').AsBoolean := AModel.IsActive;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('document_no').AsWideStrings[AIndex] := AModel.DocumentNo;
    Q.ParamByName('holder_type').AsSmallInts[AIndex] := AModel.HolderType;
    Q.ParamByName('description').AsWideStrings[AIndex] := AModel.Description;
    Q.ParamByName('is_active').AsBooleans[AIndex] := AModel.IsActive;
  end;

  SetNullableParam(Q.ParamByName('acc_account_id'), ftLargeint, AModel.AccAccountId, AIndex);
  SetDate('issue_date', AModel.IssueDate);
  SetDate('valid_until', AModel.ValidUntil);
end;

function TEInvDiibRepository.MapFromQuery(Q: TFDQuery): TEInvDiib;
begin
  Result := TEInvDiib.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.DocumentNo := Q.FieldByName('document_no').AsString;
  Result.HolderType := Q.FieldByName('holder_type').AsInteger;
  Result.AccAccountId := Q.FieldByName('acc_account_id').AsLargeInt;
  if Q.FieldByName('issue_date').IsNull then
    Result.IssueDate := 0
  else
    Result.IssueDate := Q.FieldByName('issue_date').AsDateTime;
  if Q.FieldByName('valid_until').IsNull then
    Result.ValidUntil := 0
  else
    Result.ValidUntil := Q.FieldByName('valid_until').AsDateTime;
  Result.Description := Q.FieldByName('description').AsString;
  Result.IsActive := Q.FieldByName('is_active').AsBoolean;
  Result.AccountCode := Q.FieldByName('account_code').AsString;
  Result.AccountName := Q.FieldByName('account_name').AsString;
end;

function TEInvDiibRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TEInvDiib) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TEInvDiibRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TEInvDiib>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TEInvDiib>.Create(True);
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

function TEInvDiibRepository.DoFindById(AId: TValue; ALock: Boolean): TEInvDiib;
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

function TEInvDiibRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TEInvDiib;
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

procedure TEInvDiibRepository.DoAdd(AModel: TEInvDiib);
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

procedure TEInvDiibRepository.DoAddBatch(AModels: TArray<TEInvDiib>);
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

procedure TEInvDiibRepository.DoUpdate(AModel: TEInvDiib);
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

procedure TEInvDiibRepository.DoUpdateBatch(AModels: TArray<TEInvDiib>);
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

procedure TEInvDiibRepository.DoDelete(AID: TValue);
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

procedure TEInvDiibRepository.DoDelete(AModel: TEInvDiib);
begin
  Delete(AModel.Id);
end;

procedure TEInvDiibRepository.DoDeleteBatch(AModels: TArray<TEInvDiib>);
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

procedure TEInvDiibRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TEInvDiibRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
