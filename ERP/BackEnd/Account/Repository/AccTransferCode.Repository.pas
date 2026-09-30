unit AccTransferCode.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, AccTransferCode;

type
  TAccTransferCodeRepository = class(TRepository<TAccTransferCode>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TAccTransferCode; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TAccTransferCode; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TAccTransferCode; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TAccTransferCode>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TAccTransferCode; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TAccTransferCode; override;

    procedure DoAdd(AModel: TAccTransferCode); override;
    procedure DoAddBatch(AModels: TArray<TAccTransferCode>); override;

    procedure DoUpdate(AModel: TAccTransferCode); override;
    procedure DoUpdateBatch(AModels: TArray<TAccTransferCode>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TAccTransferCode); override;
    procedure DoDeleteBatch(AModels: TArray<TAccTransferCode>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TAccTransferCodeRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TAccTransferCodeRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TAccTransferCode) +
            ' (transfer_code, description, account) ' +
            ' VALUES (:transfer_code, :description, :account)';
end;

function TAccTransferCodeRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TAccTransferCode) +
            ' SET transfer_code = :transfer_code, description = :description, account = :account ' +
            ' WHERE id = :id';
end;

function TAccTransferCodeRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TAccTransferCode) + ' WHERE';
end;

procedure TAccTransferCodeRepository.SetInsertParams(Q: TFDQuery; AModel: TAccTransferCode; AIndex: Integer);

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
    Q.ParamByName('transfer_code').AsString := AModel.TransferCode;
    Q.ParamByName('description').AsString := AModel.Description;
  end
  else
  begin
    Q.ParamByName('transfer_code').AsStrings[AIndex] := AModel.TransferCode;
    Q.ParamByName('description').AsStrings[AIndex] := AModel.Description;
  end;

  SetCode('account', AModel.Account);
end;

procedure TAccTransferCodeRepository.SetUpdateParams(Q: TFDQuery; AModel: TAccTransferCode; AIndex: Integer);

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
    Q.ParamByName('transfer_code').AsString := AModel.TransferCode;
    Q.ParamByName('description').AsString := AModel.Description;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('transfer_code').AsStrings[AIndex] := AModel.TransferCode;
    Q.ParamByName('description').AsStrings[AIndex] := AModel.Description;
  end;

  SetCode('account', AModel.Account);
end;

function TAccTransferCodeRepository.MapFromQuery(Q: TFDQuery): TAccTransferCode;
begin
  Result := TAccTransferCode.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.TransferCode := Q.FieldByName('transfer_code').AsString;
  Result.Description := Q.FieldByName('description').AsString;
  Result.Account := Q.FieldByName('account').AsString;
  Result.AccountName := Q.FieldByName('account_name').AsString;
end;

function TAccTransferCodeRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TAccTransferCode) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TAccTransferCodeRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TAccTransferCode>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TAccTransferCode>.Create(True);
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

function TAccTransferCodeRepository.DoFindById(AId: TValue; ALock: Boolean): TAccTransferCode;
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

function TAccTransferCodeRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TAccTransferCode;
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

procedure TAccTransferCodeRepository.DoAdd(AModel: TAccTransferCode);
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

procedure TAccTransferCodeRepository.DoAddBatch(AModels: TArray<TAccTransferCode>);
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

procedure TAccTransferCodeRepository.DoUpdate(AModel: TAccTransferCode);
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

procedure TAccTransferCodeRepository.DoUpdateBatch(AModels: TArray<TAccTransferCode>);
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

procedure TAccTransferCodeRepository.DoDelete(AID: TValue);
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

procedure TAccTransferCodeRepository.DoDelete(AModel: TAccTransferCode);
begin
  Delete(AModel.Id);
end;

procedure TAccTransferCodeRepository.DoDeleteBatch(AModels: TArray<TAccTransferCode>);
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

procedure TAccTransferCodeRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TAccTransferCodeRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
