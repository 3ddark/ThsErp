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


    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TList<TSysAccessRight>; override;
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
    procedure CopyUserAccessRights(ASourceUserId, ATargetUserId: TValue);
    procedure AddPermissionToAllUser(APermissionId: TValue);
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
            ' (permission_id, is_read, is_add, is_update, is_delete, is_special, user_id) ' +
            ' VALUES (:permission_id, :is_read, :is_add, :is_update, :is_delete, :is_special, :user_id)';
end;

function TSysAccessRightRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TSysAccessRight) +
            ' SET permission_id = :permission_id, is_read = :is_read, is_add = :is_add, ' +
            '     is_update = :is_update, is_delete = :is_delete, is_special = :is_special, ' +
            '     user_id = :user_id ' +
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
    Q.ParamByName('permission_id').AsLargeInt := AModel.PermissionId;
    Q.ParamByName('is_read').AsBoolean        := AModel.IsRead;
    Q.ParamByName('is_add').AsBoolean         := AModel.IsAdd;
    Q.ParamByName('is_update').AsBoolean      := AModel.IsUpdate;
    Q.ParamByName('is_delete').AsBoolean      := AModel.IsDelete;
    Q.ParamByName('is_special').AsBoolean     := AModel.IsSpecial;
    Q.ParamByName('user_id').AsLargeInt       := AModel.UserId;
  end
  else
  begin
    Q.ParamByName('permission_id').AsLargeInts[AIndex] := AModel.PermissionId;
    Q.ParamByName('is_read').AsBooleans[AIndex]        := AModel.IsRead;
    Q.ParamByName('is_add').AsBooleans[AIndex]         := AModel.IsAdd;
    Q.ParamByName('is_update').AsBooleans[AIndex]      := AModel.IsUpdate;
    Q.ParamByName('is_delete').AsBooleans[AIndex]      := AModel.IsDelete;
    Q.ParamByName('is_special').AsBooleans[AIndex]     := AModel.IsSpecial;
    Q.ParamByName('user_id').AsLargeInts[AIndex]       := AModel.UserId;
  end;
end;

procedure TSysAccessRightRepository.SetUpdateParams(Q: TFDQuery; AModel: TSysAccessRight; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('id').AsLargeInt            := AModel.Id;
    Q.ParamByName('permission_id').AsLargeInt := AModel.PermissionId;
    Q.ParamByName('is_read').AsBoolean        := AModel.IsRead;
    Q.ParamByName('is_add').AsBoolean         := AModel.IsAdd;
    Q.ParamByName('is_update').AsBoolean      := AModel.IsUpdate;
    Q.ParamByName('is_delete').AsBoolean      := AModel.IsDelete;
    Q.ParamByName('is_special').AsBoolean     := AModel.IsSpecial;
    Q.ParamByName('user_id').AsLargeInt       := AModel.UserId;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex]            := AModel.Id;
    Q.ParamByName('permission_id').AsLargeInts[AIndex] := AModel.PermissionId;
    Q.ParamByName('is_read').AsBooleans[AIndex]        := AModel.IsRead;
    Q.ParamByName('is_add').AsBooleans[AIndex]         := AModel.IsAdd;
    Q.ParamByName('is_update').AsBooleans[AIndex]      := AModel.IsUpdate;
    Q.ParamByName('is_delete').AsBooleans[AIndex]      := AModel.IsDelete;
    Q.ParamByName('is_special').AsBooleans[AIndex]     := AModel.IsSpecial;
    Q.ParamByName('user_id').AsLargeInts[AIndex]       := AModel.UserId;
  end;
end;

function TSysAccessRightRepository.MapFromQuery(Q: TFDQuery): TSysAccessRight;
begin
  Result := TSysAccessRight.Create;
  Result.Id           := Q.FieldByName('id').AsLargeInt;
  Result.PermissionId := Q.FieldByName('permission_id').AsLargeInt;
  Result.IsRead       := Q.FieldByName('is_read').AsBoolean;
  Result.IsAdd        := Q.FieldByName('is_add').AsBoolean;
  Result.IsUpdate     := Q.FieldByName('is_update').AsBoolean;
  Result.IsDelete     := Q.FieldByName('is_delete').AsBoolean;
  Result.IsSpecial    := Q.FieldByName('is_special').AsBoolean;
  Result.UserId       := Q.FieldByName('user_id').AsLargeInt;
end;

function TSysAccessRightRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT * FROM ' + Self.GetFullViewName(TSysAccessRight) + ' WHERE locale = :locale ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
  Result.ParamByName('locale').Value := TAppContext.Instance.CurrentUser.ActiveLanguage;
end;

function TSysAccessRightRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TList<TSysAccessRight>;
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

    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

function TSysAccessRightRepository.GetUserPermissions(AUserId: TValue): TObjectDictionary<Integer, TSysAccessRight>;
var
  Q: TFDQuery;
  Right: TSysAccessRight;
begin
  Result := TObjectDictionary<Integer, TSysAccessRight>.Create();
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT * FROM ' + Self.GetFullViewName(TSysAccessRight) + ' WHERE locale = :locale and user_id = :user_id';
    Q.ParamByName('user_id').AsLargeInt := AUserId.AsInt64;
    Q.ParamByName('locale').AsString := TAppContext.Instance.CurrentUser.ActiveLanguage;
    Q.Open;

    Q.First;
    while not Q.Eof do
    begin
      Right := MapFromQuery(Q);
      Result.Add(Q.FieldByName('permission_code').AsInteger, Right);
      Q.Next;
    end;
  finally
    Q.Free;
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

    LFilter.Add(TFilterCriterion.New('user_id', '=', ATargetUserId));
    DeleteBatch(LFilter);

    Q.SQL.Text := 'INSERT INTO public.' + Self.GetTableName(TSysAccessRight) + ' (permission_id, is_read, is_add, is_update, is_delete, is_special, user_id) ' +
                  'SELECT permission_id, is_read, is_add, is_update, is_delete, is_special, :target_user_id ' +
                  'FROM public.' + Self.GetTableName(TSysAccessRight) + ' WHERE user_id = :source_user_id';
    Q.ParamByName('target_user_id').AsLargeInt := ATargetUserId.AsInt64;
    Q.ParamByName('source_user_id').AsLargeInt := ASourceUserId.AsInt64;
    Q.ExecSQL;
  finally
    Q.Free;
    LFilter.Free;
  end;
end;

procedure TSysAccessRightRepository.AddPermissionToAllUser(APermissionId: TValue);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'INSERT INTO public.' + Self.GetTableName(TSysAccessRight) + ' (permission_id, is_read, is_add, is_update, is_delete, is_special, user_id) ' +
                  'SELECT :permission_id, false, false, false, false, false, id FROM ' + Self.GetTableName(TSysUser) +
                  ' WHERE active ' +
                  'ON CONFLICT (permission_id, user_id) DO UPDATE SET permission_id = EXCLUDED.permission_id';
    Q.ParamByName('permission_id').AsLargeInt := APermissionId.AsInt64;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

end.
