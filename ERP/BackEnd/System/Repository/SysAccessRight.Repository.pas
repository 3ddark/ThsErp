unit SysAccessRight.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, Service,
  FilterCriterion, UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  SysAccessRight;

type
  TSysAccessRightRepository = class(TRepository<TSysAccessRight>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TSysAccessRight; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TSysAccessRight; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TSysAccessRight; override;
    function MapEffectiveFromQuery(Q: TFDQuery): TSysAccessRight;


    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TSysAccessRight>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TSysAccessRight; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TSysAccessRight; override;

    procedure DoAdd(AModel: TSysAccessRight); override;
    procedure DoAddBatch(AModels: TArray<TSysAccessRight>); override;

    procedure DoUpdate(AModel: TSysAccessRight); override;
    procedure DoUpdateBatch(AModels: TArray<TSysAccessRight>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TSysAccessRight); override;
    procedure DoDeleteBatch(AModels: TArray<TSysAccessRight>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);

    function GetUserPermissions(AUserId: TValue): TObjectDictionary<Integer, TSysAccessRight>;
    /// <summary>Kullanıcının ilgili yetki kodundaki etkin (şablon + override) hakları. Kayıt yoksa nil.</summary>
    function GetEffectivePermission(AUserId: Int64; APermissionCode: Integer): TSysAccessRight;
    function GetReadablePermissionCodes(AUserId: Int64): TArray<Integer>;
    procedure CopyUserAccessRights(ASourceUserId, ATargetUserId: TValue);
    procedure AddPermissionToAllUser(APermissionId: TValue);
    procedure AddAllPermissionsToUser(AUserId: Int64);
  end;

implementation

uses
  SysPermission, SysUser;

constructor TSysAccessRightRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSysAccessRightRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TSysAccessRight) +
            ' (sys_permission_id, is_read, is_add, is_update, is_delete, is_special, ' +
            '  deny_read, deny_add, deny_update, deny_delete, deny_special, sys_user_id) ' +
            ' VALUES (:sys_permission_id, :is_read, :is_add, :is_update, :is_delete, :is_special, ' +
            '  :deny_read, :deny_add, :deny_update, :deny_delete, :deny_special, :sys_user_id)';
end;

function TSysAccessRightRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TSysAccessRight) +
            ' SET sys_permission_id = :sys_permission_id, is_read = :is_read, is_add = :is_add, ' +
            '     is_update = :is_update, is_delete = :is_delete, is_special = :is_special, ' +
            '     deny_read = :deny_read, deny_add = :deny_add, deny_update = :deny_update, ' +
            '     deny_delete = :deny_delete, deny_special = :deny_special, ' +
            '     sys_user_id = :sys_user_id ' +
            ' WHERE id = :id';
end;

function TSysAccessRightRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TSysAccessRight) + ' WHERE';
end;

procedure TSysAccessRightRepository.SetInsertParams(Q: TFDQuery; AModel: TSysAccessRight; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('sys_permission_id').AsLargeInt := AModel.SysPermissionId;
    Q.ParamByName('is_read').AsBoolean := AModel.IsRead;
    Q.ParamByName('is_add').AsBoolean := AModel.IsAdd;
    Q.ParamByName('is_update').AsBoolean := AModel.IsUpdate;
    Q.ParamByName('is_delete').AsBoolean := AModel.IsDelete;
    Q.ParamByName('is_special').AsBoolean := AModel.IsSpecial;
    Q.ParamByName('deny_read').AsBoolean := AModel.DenyRead;
    Q.ParamByName('deny_add').AsBoolean := AModel.DenyAdd;
    Q.ParamByName('deny_update').AsBoolean := AModel.DenyUpdate;
    Q.ParamByName('deny_delete').AsBoolean := AModel.DenyDelete;
    Q.ParamByName('deny_special').AsBoolean := AModel.DenySpecial;
    Q.ParamByName('sys_user_id').AsLargeInt := AModel.SysUserId;
  end
  else
  begin
    Q.ParamByName('sys_permission_id').AsLargeInts[AIndex] := AModel.SysPermissionId;
    Q.ParamByName('is_read').AsBooleans[AIndex] := AModel.IsRead;
    Q.ParamByName('is_add').AsBooleans[AIndex] := AModel.IsAdd;
    Q.ParamByName('is_update').AsBooleans[AIndex] := AModel.IsUpdate;
    Q.ParamByName('is_delete').AsBooleans[AIndex] := AModel.IsDelete;
    Q.ParamByName('is_special').AsBooleans[AIndex] := AModel.IsSpecial;
    Q.ParamByName('deny_read').AsBooleans[AIndex] := AModel.DenyRead;
    Q.ParamByName('deny_add').AsBooleans[AIndex] := AModel.DenyAdd;
    Q.ParamByName('deny_update').AsBooleans[AIndex] := AModel.DenyUpdate;
    Q.ParamByName('deny_delete').AsBooleans[AIndex] := AModel.DenyDelete;
    Q.ParamByName('deny_special').AsBooleans[AIndex] := AModel.DenySpecial;
    Q.ParamByName('sys_user_id').AsLargeInts[AIndex] := AModel.SysUserId;
  end;
end;

procedure TSysAccessRightRepository.SetUpdateParams(Q: TFDQuery; AModel: TSysAccessRight; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('id').AsLargeInt := AModel.Id;
    Q.ParamByName('sys_permission_id').AsLargeInt := AModel.SysPermissionId;
    Q.ParamByName('is_read').AsBoolean := AModel.IsRead;
    Q.ParamByName('is_add').AsBoolean := AModel.IsAdd;
    Q.ParamByName('is_update').AsBoolean := AModel.IsUpdate;
    Q.ParamByName('is_delete').AsBoolean := AModel.IsDelete;
    Q.ParamByName('is_special').AsBoolean := AModel.IsSpecial;
    Q.ParamByName('deny_read').AsBoolean := AModel.DenyRead;
    Q.ParamByName('deny_add').AsBoolean := AModel.DenyAdd;
    Q.ParamByName('deny_update').AsBoolean := AModel.DenyUpdate;
    Q.ParamByName('deny_delete').AsBoolean := AModel.DenyDelete;
    Q.ParamByName('deny_special').AsBoolean := AModel.DenySpecial;
    Q.ParamByName('sys_user_id').AsLargeInt := AModel.SysUserId;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('sys_permission_id').AsLargeInts[AIndex] := AModel.SysPermissionId;
    Q.ParamByName('is_read').AsBooleans[AIndex] := AModel.IsRead;
    Q.ParamByName('is_add').AsBooleans[AIndex] := AModel.IsAdd;
    Q.ParamByName('is_update').AsBooleans[AIndex] := AModel.IsUpdate;
    Q.ParamByName('is_delete').AsBooleans[AIndex] := AModel.IsDelete;
    Q.ParamByName('is_special').AsBooleans[AIndex] := AModel.IsSpecial;
    Q.ParamByName('deny_read').AsBooleans[AIndex] := AModel.DenyRead;
    Q.ParamByName('deny_add').AsBooleans[AIndex] := AModel.DenyAdd;
    Q.ParamByName('deny_update').AsBooleans[AIndex] := AModel.DenyUpdate;
    Q.ParamByName('deny_delete').AsBooleans[AIndex] := AModel.DenyDelete;
    Q.ParamByName('deny_special').AsBooleans[AIndex] := AModel.DenySpecial;
    Q.ParamByName('sys_user_id').AsLargeInts[AIndex] := AModel.SysUserId;
  end;
end;

function TSysAccessRightRepository.MapFromQuery(Q: TFDQuery): TSysAccessRight;
begin
  Result := TSysAccessRight.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.SysPermissionId := Q.FieldByName('sys_permission_id').AsLargeInt;
  Result.IsRead := Q.FieldByName('is_read').AsBoolean;
  Result.IsAdd := Q.FieldByName('is_add').AsBoolean;
  Result.IsUpdate := Q.FieldByName('is_update').AsBoolean;
  Result.IsDelete := Q.FieldByName('is_delete').AsBoolean;
  Result.IsSpecial := Q.FieldByName('is_special').AsBoolean;
  Result.DenyRead := Q.FieldByName('deny_read').AsBoolean;
  Result.DenyAdd := Q.FieldByName('deny_add').AsBoolean;
  Result.DenyUpdate := Q.FieldByName('deny_update').AsBoolean;
  Result.DenyDelete := Q.FieldByName('deny_delete').AsBoolean;
  Result.DenySpecial := Q.FieldByName('deny_special').AsBoolean;
  Result.SysUserId := Q.FieldByName('sys_user_id').AsLargeInt;
  Result.Username := Q.FieldByName('username').AsString;
  Result.PermissionName := Q.FieldByName('permission_name').AsString;
end;

function TSysAccessRightRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id', 'locale']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TSysAccessRight) + ' WHERE locale = :locale ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
  Result.ParamByName('locale').Value := TAppContext.Instance.CurrentUser.ActiveLanguage;
end;

function TSysAccessRightRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TSysAccessRight>;
var
  Q: TFDQuery;
  Item: TSysAccessRight;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TSysAccessRight>.Create(True);
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := Self.PrepareSelectFromView(AFilter, ALock, False, True);

    if Assigned(AFilter) and (AFilter.Count > 0) then
    begin
      for Criteria in AFilter do
        Q.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
    end;

    Q.ParamByName('locale').Value := TAppContext.Instance.CurrentUser.ActiveLanguage;

    LogQuery(Q, 'DoFind');
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

function TSysAccessRightRepository.DoFindById(AId: TValue; ALock: Boolean): TSysAccessRight;
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

function TSysAccessRightRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TSysAccessRight;
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

procedure TSysAccessRightRepository.DoAdd(AModel: TSysAccessRight);
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

procedure TSysAccessRightRepository.DoAddBatch(AModels: TArray<TSysAccessRight>);
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

procedure TSysAccessRightRepository.DoUpdate(AModel: TSysAccessRight);
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

procedure TSysAccessRightRepository.DoUpdateBatch(AModels: TArray<TSysAccessRight>);
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

procedure TSysAccessRightRepository.DoDelete(AID: TValue);
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

procedure TSysAccessRightRepository.DoDelete(AModel: TSysAccessRight);
begin
  Delete(AModel.Id);
end;

procedure TSysAccessRightRepository.DoDeleteBatch(AModels: TArray<TSysAccessRight>);
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

procedure TSysAccessRightRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TSysAccessRightRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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

function TSysAccessRightRepository.MapEffectiveFromQuery(Q: TFDQuery): TSysAccessRight;
begin
  Result := TSysAccessRight.Create;
  Result.SysUserId := Q.FieldByName('sys_user_id').AsLargeInt;
  Result.SysPermissionId := Q.FieldByName('sys_permission_id').AsLargeInt;
  Result.PermissionName := Q.FieldByName('permission_key').AsString;
  Result.IsRead := Q.FieldByName('is_read').AsBoolean;
  Result.IsAdd := Q.FieldByName('is_add').AsBoolean;
  Result.IsUpdate := Q.FieldByName('is_update').AsBoolean;
  Result.IsDelete := Q.FieldByName('is_delete').AsBoolean;
  Result.IsSpecial := Q.FieldByName('is_special').AsBoolean;
end;

function TSysAccessRightRepository.GetUserPermissions(AUserId: TValue): TObjectDictionary<Integer, TSysAccessRight>;
var
  Q: TFDQuery;
  Right: TSysAccessRight;
begin
  // Etkin yetkiler: şablonlar + override (is_* ek izin, deny_* engelleme)
  Result := TObjectDictionary<Integer, TSysAccessRight>.Create([doOwnsValues]);
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT * FROM public.vw_sys_user_effective_permission WHERE sys_user_id = :sys_user_id';
    Q.ParamByName('sys_user_id').AsLargeInt := AUserId.AsInt64;
    LogQuery(Q, 'GetUserPermissions');
    Q.Open;

    while not Q.Eof do
    begin
      Right := MapEffectiveFromQuery(Q);
      Result.AddOrSetValue(Q.FieldByName('permission_code').AsInteger, Right);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

function TSysAccessRightRepository.GetEffectivePermission(AUserId: Int64; APermissionCode: Integer): TSysAccessRight;
var
  Q: TFDQuery;
begin
  Result := nil;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT * FROM public.vw_sys_user_effective_permission ' +
                  ' WHERE sys_user_id = :sys_user_id AND permission_code = :permission_code';
    Q.ParamByName('sys_user_id').AsLargeInt := AUserId;
    Q.ParamByName('permission_code').AsInteger := APermissionCode;
    LogQuery(Q, 'GetEffectivePermission');
    Q.Open;

    if not Q.IsEmpty then
      Result := MapEffectiveFromQuery(Q);
  finally
    Q.Free;
  end;
end;

function TSysAccessRightRepository.GetReadablePermissionCodes(AUserId: Int64): TArray<Integer>;
var
  Q: TFDQuery;
  LCodes: TList<Integer>;
begin
  LCodes := TList<Integer>.Create;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT permission_code FROM public.vw_sys_user_effective_permission ' +
                  ' WHERE sys_user_id = :sys_user_id AND is_read';
    Q.ParamByName('sys_user_id').AsLargeInt := AUserId;
    LogQuery(Q, 'GetReadablePermissionCodes');
    Q.Open;
    while not Q.Eof do
    begin
      LCodes.Add(Q.FieldByName('permission_code').AsInteger);
      Q.Next;
    end;
    Result := LCodes.ToArray;
  finally
    Q.Free;
    LCodes.Free;
  end;
end;

procedure TSysAccessRightRepository.CopyUserAccessRights(ASourceUserId, ATargetUserId: TValue);
var
  Q: TFDQuery;
  LFilter: TFilterCriteria;
begin
  Q := TFDQuery.Create(nil);
  LFilter := TFilterCriteria.Create;
  try
    Q.Connection := Connection;

    LFilter.Add(TFilterCriterion.New('sys_user_id', '=', ATargetUserId));
    DeleteBatch(LFilter);

    Q.SQL.Text := 'INSERT INTO public.' + Self.GetTableName(TSysAccessRight) +
                  ' (sys_permission_id, is_read, is_add, is_update, is_delete, is_special, ' +
                  '  deny_read, deny_add, deny_update, deny_delete, deny_special, sys_user_id) ' +
                  'SELECT sys_permission_id, is_read, is_add, is_update, is_delete, is_special, ' +
                  '  deny_read, deny_add, deny_update, deny_delete, deny_special, :target_user_id ' +
                  'FROM public.' + Self.GetTableName(TSysAccessRight) + ' WHERE sys_user_id = :source_user_id';
    Q.ParamByName('target_user_id').AsLargeInt := ATargetUserId.AsInt64;
    Q.ParamByName('source_user_id').AsLargeInt := ASourceUserId.AsInt64;
    LogQuery(Q, 'CopyUserAccessRights');
    Q.ExecSQL;
  finally
    Q.Free;
    LFilter.Free;
  end;
end;

// Yeni kullanıcı: her yetki için tüm hakları false (is_* ve deny_*) satır; mevcut satırlara dokunmaz
procedure TSysAccessRightRepository.AddAllPermissionsToUser(AUserId: Int64);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'INSERT INTO public.' + Self.GetTableName(TSysAccessRight) +
                  ' (sys_permission_id, is_read, is_add, is_update, is_delete, is_special, ' +
                  '  deny_read, deny_add, deny_update, deny_delete, deny_special, sys_user_id) ' +
                  'SELECT p.id, false, false, false, false, false, false, false, false, false, false, :sys_user_id ' +
                  '  FROM public.' + Self.GetTableName(TSysPermission) + ' p ' +
                  'ON CONFLICT (sys_permission_id, sys_user_id) DO NOTHING';
    Q.ParamByName('sys_user_id').AsLargeInt := AUserId;
    LogQuery(Q, 'AddAllPermissionsToUser');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TSysAccessRightRepository.AddPermissionToAllUser(APermissionId: TValue);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'INSERT INTO public.' + Self.GetTableName(TSysAccessRight) + ' (sys_permission_id, is_read, is_add, is_update, is_delete, is_special, sys_user_id) ' +
                  'SELECT :sys_permission_id, false, false, false, false, false, id FROM ' + Self.GetTableName(TSysUser) +
                  ' ON CONFLICT (sys_permission_id, sys_user_id) DO NOTHING';
    Q.ParamByName('sys_permission_id').AsLargeInt := APermissionId.AsInt64;
    LogQuery(Q, 'AddPermissionToAllUser');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

end.
