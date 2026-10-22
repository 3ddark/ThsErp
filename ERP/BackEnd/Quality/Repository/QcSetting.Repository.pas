unit QcSetting.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, QcSetting;

type
  TQcSettingRepository = class(TRepository<TQcSetting>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TQcSetting; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TQcSetting; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TQcSetting; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TQcSetting>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TQcSetting; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TQcSetting; override;

    procedure DoAdd(AModel: TQcSetting); override;
    procedure DoAddBatch(AModels: TArray<TQcSetting>); override;

    procedure DoUpdate(AModel: TQcSetting); override;
    procedure DoUpdateBatch(AModels: TArray<TQcSetting>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TQcSetting); override;
    procedure DoDeleteBatch(AModels: TArray<TQcSetting>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
    // Firma (sys_application_setting) kaydı; 0 = yok
    function CompanyId: Int64;
    // Modül açık mı (ayar yoksa kapalı)
    function IsEnabled: Boolean;
  end;

implementation

constructor TQcSettingRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;


function TQcSettingRepository.CompanyId: Int64;
var
  Q: TFDQuery;
begin
  Result := 0;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT min(id) FROM public.sys_application_setting';

    LogQuery(Q, 'CompanyId');
    Q.Open;
    if not Q.IsEmpty then
      Result := Q.Fields[0].AsLargeInt;
  finally
    Q.Free;
  end;
end;


function TQcSettingRepository.IsEnabled: Boolean;
var
  Q: TFDQuery;
begin
  Result := False;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT COALESCE(bool_or(is_enabled), false) FROM public.qc_setting';

    LogQuery(Q, 'IsEnabled');
    Q.Open;
    if not Q.IsEmpty then
      Result := Q.Fields[0].AsBoolean;
  finally
    Q.Free;
  end;
end;

function TQcSettingRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TQcSetting) +
            ' (sys_application_setting_id, is_enabled, reject_stk_warehouse_id, description) ' +
            ' VALUES (:sys_application_setting_id, :is_enabled, :reject_stk_warehouse_id, :description)';
end;

function TQcSettingRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TQcSetting) +
            ' SET sys_application_setting_id = :sys_application_setting_id, is_enabled = :is_enabled, reject_stk_warehouse_id = :reject_stk_warehouse_id, description = :description ' +
            ' WHERE id = :id';
end;

function TQcSettingRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TQcSetting) + ' WHERE';
end;

procedure TQcSettingRepository.SetInsertParams(Q: TFDQuery; AModel: TQcSetting; AIndex: Integer);

begin
  if AIndex < 0 then
  begin
    Q.ParamByName('is_enabled').AsBoolean := AModel.IsEnabled;
    Q.ParamByName('description').AsWideString := AModel.Description;
  end
  else
  begin
    Q.ParamByName('is_enabled').AsBooleans[AIndex] := AModel.IsEnabled;
    Q.ParamByName('description').AsWideStrings[AIndex] := AModel.Description;
  end;

  SetNullableParam(Q.ParamByName('sys_application_setting_id'), ftLargeint, AModel.SysApplicationSettingId, AIndex);
  SetNullableParam(Q.ParamByName('reject_stk_warehouse_id'), ftLargeint, AModel.RejectStkWarehouseId, AIndex);
end;

procedure TQcSettingRepository.SetUpdateParams(Q: TFDQuery; AModel: TQcSetting; AIndex: Integer);

begin
  if AIndex < 0 then
  begin
    Q.ParamByName('id').AsLargeInt := AModel.Id;
    Q.ParamByName('is_enabled').AsBoolean := AModel.IsEnabled;
    Q.ParamByName('description').AsWideString := AModel.Description;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('is_enabled').AsBooleans[AIndex] := AModel.IsEnabled;
    Q.ParamByName('description').AsWideStrings[AIndex] := AModel.Description;
  end;

  SetNullableParam(Q.ParamByName('sys_application_setting_id'), ftLargeint, AModel.SysApplicationSettingId, AIndex);
  SetNullableParam(Q.ParamByName('reject_stk_warehouse_id'), ftLargeint, AModel.RejectStkWarehouseId, AIndex);
end;

function TQcSettingRepository.MapFromQuery(Q: TFDQuery): TQcSetting;
begin
  Result := TQcSetting.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.SysApplicationSettingId := Q.FieldByName('sys_application_setting_id').AsLargeInt;
  Result.IsEnabled := Q.FieldByName('is_enabled').AsBoolean;
  Result.RejectStkWarehouseId := Q.FieldByName('reject_stk_warehouse_id').AsLargeInt;
  Result.Description := Q.FieldByName('description').AsString;
  Result.CompanyTitle := Q.FieldByName('company_title').AsString;
  Result.RejectWarehouseName := Q.FieldByName('reject_warehouse_name').AsString;
end;

function TQcSettingRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TQcSetting) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TQcSettingRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TQcSetting>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TQcSetting>.Create(True);
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

function TQcSettingRepository.DoFindById(AId: TValue; ALock: Boolean): TQcSetting;
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

function TQcSettingRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TQcSetting;
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

procedure TQcSettingRepository.DoAdd(AModel: TQcSetting);
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

procedure TQcSettingRepository.DoAddBatch(AModels: TArray<TQcSetting>);
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

procedure TQcSettingRepository.DoUpdate(AModel: TQcSetting);
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

procedure TQcSettingRepository.DoUpdateBatch(AModels: TArray<TQcSetting>);
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

procedure TQcSettingRepository.DoDelete(AID: TValue);
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

procedure TQcSettingRepository.DoDelete(AModel: TQcSetting);
begin
  Delete(AModel.Id);
end;

procedure TQcSettingRepository.DoDeleteBatch(AModels: TArray<TQcSetting>);
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

procedure TQcSettingRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TQcSettingRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
