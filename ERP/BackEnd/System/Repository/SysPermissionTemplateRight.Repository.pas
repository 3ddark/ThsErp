unit SysPermissionTemplateRight.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, SysPermissionTemplateRight;

type
  TSysPermissionTemplateRightRepository = class(TRepository<TSysPermissionTemplateRight>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TSysPermissionTemplateRight; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TSysPermissionTemplateRight; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TSysPermissionTemplateRight; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TSysPermissionTemplateRight>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TSysPermissionTemplateRight; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TSysPermissionTemplateRight; override;

    procedure DoAdd(AModel: TSysPermissionTemplateRight); override;
    procedure DoAddBatch(AModels: TArray<TSysPermissionTemplateRight>); override;

    procedure DoUpdate(AModel: TSysPermissionTemplateRight); override;
    procedure DoUpdateBatch(AModels: TArray<TSysPermissionTemplateRight>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TSysPermissionTemplateRight); override;
    procedure DoDeleteBatch(AModels: TArray<TSysPermissionTemplateRight>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);

    /// <summary>Şablonda tanımlı olmayan tüm yetkileri (bayraklar kapalı) şablona ekler.</summary>
    function AddMissingPermissions(ATemplateId: Int64): Integer;
    /// <summary>Şablondaki tüm yetkilerin bayraklarını topluca ayarlar.</summary>
    procedure SetAllFlags(ATemplateId: Int64; AValue: Boolean);
  end;

implementation

constructor TSysPermissionTemplateRightRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSysPermissionTemplateRightRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TSysPermissionTemplateRight) +
            ' (sys_permission_template_id, sys_permission_id, is_read, is_add, is_update, is_delete, is_special) ' +
            ' VALUES (:sys_permission_template_id, :sys_permission_id, :is_read, :is_add, :is_update, :is_delete, :is_special)';
end;

function TSysPermissionTemplateRightRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TSysPermissionTemplateRight) +
            ' SET sys_permission_template_id = :sys_permission_template_id, sys_permission_id = :sys_permission_id, is_read = :is_read, is_add = :is_add, is_update = :is_update, is_delete = :is_delete, is_special = :is_special ' +
            ' WHERE id = :id';
end;

function TSysPermissionTemplateRightRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TSysPermissionTemplateRight) + ' WHERE';
end;

procedure TSysPermissionTemplateRightRepository.SetInsertParams(Q: TFDQuery; AModel: TSysPermissionTemplateRight; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('sys_permission_template_id').AsLargeInt := AModel.SysPermissionTemplateId;
    Q.ParamByName('sys_permission_id').AsLargeInt := AModel.SysPermissionId;
    Q.ParamByName('is_read').AsBoolean := AModel.IsRead;
    Q.ParamByName('is_add').AsBoolean := AModel.IsAdd;
    Q.ParamByName('is_update').AsBoolean := AModel.IsUpdate;
    Q.ParamByName('is_delete').AsBoolean := AModel.IsDelete;
    Q.ParamByName('is_special').AsBoolean := AModel.IsSpecial;
  end
  else
  begin
    Q.ParamByName('sys_permission_template_id').AsLargeInts[AIndex] := AModel.SysPermissionTemplateId;
    Q.ParamByName('sys_permission_id').AsLargeInts[AIndex] := AModel.SysPermissionId;
    Q.ParamByName('is_read').AsBooleans[AIndex] := AModel.IsRead;
    Q.ParamByName('is_add').AsBooleans[AIndex] := AModel.IsAdd;
    Q.ParamByName('is_update').AsBooleans[AIndex] := AModel.IsUpdate;
    Q.ParamByName('is_delete').AsBooleans[AIndex] := AModel.IsDelete;
    Q.ParamByName('is_special').AsBooleans[AIndex] := AModel.IsSpecial;
  end;
end;

procedure TSysPermissionTemplateRightRepository.SetUpdateParams(Q: TFDQuery; AModel: TSysPermissionTemplateRight; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('id').AsLargeInt := AModel.Id;
    Q.ParamByName('sys_permission_template_id').AsLargeInt := AModel.SysPermissionTemplateId;
    Q.ParamByName('sys_permission_id').AsLargeInt := AModel.SysPermissionId;
    Q.ParamByName('is_read').AsBoolean := AModel.IsRead;
    Q.ParamByName('is_add').AsBoolean := AModel.IsAdd;
    Q.ParamByName('is_update').AsBoolean := AModel.IsUpdate;
    Q.ParamByName('is_delete').AsBoolean := AModel.IsDelete;
    Q.ParamByName('is_special').AsBoolean := AModel.IsSpecial;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('sys_permission_template_id').AsLargeInts[AIndex] := AModel.SysPermissionTemplateId;
    Q.ParamByName('sys_permission_id').AsLargeInts[AIndex] := AModel.SysPermissionId;
    Q.ParamByName('is_read').AsBooleans[AIndex] := AModel.IsRead;
    Q.ParamByName('is_add').AsBooleans[AIndex] := AModel.IsAdd;
    Q.ParamByName('is_update').AsBooleans[AIndex] := AModel.IsUpdate;
    Q.ParamByName('is_delete').AsBooleans[AIndex] := AModel.IsDelete;
    Q.ParamByName('is_special').AsBooleans[AIndex] := AModel.IsSpecial;
  end;
end;

function TSysPermissionTemplateRightRepository.MapFromQuery(Q: TFDQuery): TSysPermissionTemplateRight;
begin
  Result := TSysPermissionTemplateRight.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.SysPermissionTemplateId := Q.FieldByName('sys_permission_template_id').AsLargeInt;
  Result.SysPermissionId := Q.FieldByName('sys_permission_id').AsLargeInt;
  Result.IsRead := Q.FieldByName('is_read').AsBoolean;
  Result.IsAdd := Q.FieldByName('is_add').AsBoolean;
  Result.IsUpdate := Q.FieldByName('is_update').AsBoolean;
  Result.IsDelete := Q.FieldByName('is_delete').AsBoolean;
  Result.IsSpecial := Q.FieldByName('is_special').AsBoolean;
  Result.TemplateName := Q.FieldByName('template_name').AsString;
  Result.PermissionName := Q.FieldByName('permission_name').AsString;
end;

function TSysPermissionTemplateRightRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id', 'locale']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TSysPermissionTemplateRight) + ' WHERE locale = :locale ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
  Result.ParamByName('locale').Value := TAppContext.Instance.CurrentUser.ActiveLanguage;
end;

function TSysPermissionTemplateRightRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TSysPermissionTemplateRight>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TSysPermissionTemplateRight>.Create(True);
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := Self.PrepareSelectFromView(AFilter, ALock, False, True);

    if Assigned(AFilter) and (AFilter.Count > 0) then
      for Criteria in AFilter do
        Q.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
    Q.ParamByName('locale').Value := TAppContext.Instance.CurrentUser.ActiveLanguage;

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

function TSysPermissionTemplateRightRepository.DoFindById(AId: TValue; ALock: Boolean): TSysPermissionTemplateRight;
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
    Q.SQL.Text := Self.PrepareSelectFromView(Criteria, ALock, True, True);

    Q.ParamByName('id').AsLargeInt := AId.AsInt64;
    Q.ParamByName('locale').Value := TAppContext.Instance.CurrentUser.ActiveLanguage;
    LogQuery(Q, 'DoFindById');
    Q.Open;

    if not Q.IsEmpty then
      Result := MapFromQuery(Q);
  finally
    Q.Free;
    Criteria.Free;
  end;
end;

function TSysPermissionTemplateRightRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TSysPermissionTemplateRight;
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
    Q.SQL.Text := Self.PrepareSelectFromView(AFilter, ALock, True, True);

    for Criteria in AFilter do
      Q.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
    Q.ParamByName('locale').Value := TAppContext.Instance.CurrentUser.ActiveLanguage;
    LogQuery(Q, 'DoFindOne');
    Q.Open;

    if not Q.IsEmpty then
      Result := MapFromQuery(Q);
  finally
    Q.Free;
  end;
end;

procedure TSysPermissionTemplateRightRepository.DoAdd(AModel: TSysPermissionTemplateRight);
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

procedure TSysPermissionTemplateRightRepository.DoAddBatch(AModels: TArray<TSysPermissionTemplateRight>);
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

    LogQuery(Q, 'DoAddBatch');
    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TSysPermissionTemplateRightRepository.DoUpdate(AModel: TSysPermissionTemplateRight);
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

procedure TSysPermissionTemplateRightRepository.DoUpdateBatch(AModels: TArray<TSysPermissionTemplateRight>);
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

    LogQuery(Q, 'DoUpdateBatch');
    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TSysPermissionTemplateRightRepository.DoDelete(AID: TValue);
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

procedure TSysPermissionTemplateRightRepository.DoDelete(AModel: TSysPermissionTemplateRight);
begin
  Delete(AModel.Id);
end;

procedure TSysPermissionTemplateRightRepository.DoDeleteBatch(AModels: TArray<TSysPermissionTemplateRight>);
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

    LogQuery(Q, 'DoDeleteBatch');
    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TSysPermissionTemplateRightRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

    LogQuery(Q, 'DoDeleteBatch');
    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TSysPermissionTemplateRightRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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

function TSysPermissionTemplateRightRepository.AddMissingPermissions(ATemplateId: Int64): Integer;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'INSERT INTO public.' + Self.GetTableName(TSysPermissionTemplateRight) +
                  ' (sys_permission_template_id, sys_permission_id) ' +
                  'SELECT :template_id, p.id FROM public.sys_permission p ' +
                  'ON CONFLICT (sys_permission_template_id, sys_permission_id) DO NOTHING';
    Q.ParamByName('template_id').AsLargeInt := ATemplateId;
    LogQuery(Q, 'AddMissingPermissions');
    Q.ExecSQL;
    Result := Q.RowsAffected;
  finally
    Q.Free;
  end;
end;

procedure TSysPermissionTemplateRightRepository.SetAllFlags(ATemplateId: Int64; AValue: Boolean);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'UPDATE public.' + Self.GetTableName(TSysPermissionTemplateRight) +
                  ' SET is_read = :v, is_add = :v, is_update = :v, is_delete = :v, is_special = :v ' +
                  ' WHERE sys_permission_template_id = :template_id';
    Q.ParamByName('v').AsBoolean := AValue;
    Q.ParamByName('template_id').AsLargeInt := ATemplateId;
    LogQuery(Q, 'SetAllFlags');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

end.
