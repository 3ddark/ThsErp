unit SysUserPermissionTemplate.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, SysUserPermissionTemplate;

type
  TSysUserPermissionTemplateRepository = class(TRepository<TSysUserPermissionTemplate>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TSysUserPermissionTemplate; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TSysUserPermissionTemplate; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TSysUserPermissionTemplate; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TSysUserPermissionTemplate>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TSysUserPermissionTemplate; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TSysUserPermissionTemplate; override;

    procedure DoAdd(AModel: TSysUserPermissionTemplate); override;
    procedure DoAddBatch(AModels: TArray<TSysUserPermissionTemplate>); override;

    procedure DoUpdate(AModel: TSysUserPermissionTemplate); override;
    procedure DoUpdateBatch(AModels: TArray<TSysUserPermissionTemplate>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TSysUserPermissionTemplate); override;
    procedure DoDeleteBatch(AModels: TArray<TSysUserPermissionTemplate>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);

    /// <summary>Hedef kullanıcının şablon atamalarını kaynak kullanıcınınkilerle değiştirir.</summary>
    procedure CopyUserTemplates(ASourceUserId, ATargetUserId: Int64);
  end;

implementation

constructor TSysUserPermissionTemplateRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSysUserPermissionTemplateRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TSysUserPermissionTemplate) +
            ' (sys_user_id, sys_permission_template_id) ' +
            ' VALUES (:sys_user_id, :sys_permission_template_id)';
end;

function TSysUserPermissionTemplateRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TSysUserPermissionTemplate) +
            ' SET sys_user_id = :sys_user_id, sys_permission_template_id = :sys_permission_template_id ' +
            ' WHERE id = :id';
end;

function TSysUserPermissionTemplateRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TSysUserPermissionTemplate) + ' WHERE';
end;

procedure TSysUserPermissionTemplateRepository.SetInsertParams(Q: TFDQuery; AModel: TSysUserPermissionTemplate; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('sys_user_id').AsLargeInt := AModel.SysUserId;
    Q.ParamByName('sys_permission_template_id').AsLargeInt := AModel.SysPermissionTemplateId;
  end
  else
  begin
    Q.ParamByName('sys_user_id').AsLargeInts[AIndex] := AModel.SysUserId;
    Q.ParamByName('sys_permission_template_id').AsLargeInts[AIndex] := AModel.SysPermissionTemplateId;
  end;
end;

procedure TSysUserPermissionTemplateRepository.SetUpdateParams(Q: TFDQuery; AModel: TSysUserPermissionTemplate; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('id').AsLargeInt := AModel.Id;
    Q.ParamByName('sys_user_id').AsLargeInt := AModel.SysUserId;
    Q.ParamByName('sys_permission_template_id').AsLargeInt := AModel.SysPermissionTemplateId;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('sys_user_id').AsLargeInts[AIndex] := AModel.SysUserId;
    Q.ParamByName('sys_permission_template_id').AsLargeInts[AIndex] := AModel.SysPermissionTemplateId;
  end;
end;

function TSysUserPermissionTemplateRepository.MapFromQuery(Q: TFDQuery): TSysUserPermissionTemplate;
begin
  Result := TSysUserPermissionTemplate.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.SysUserId := Q.FieldByName('sys_user_id').AsLargeInt;
  Result.SysPermissionTemplateId := Q.FieldByName('sys_permission_template_id').AsLargeInt;
  Result.Username := Q.FieldByName('username').AsString;
  Result.TemplateName := Q.FieldByName('template_name').AsString;
end;

function TSysUserPermissionTemplateRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TSysUserPermissionTemplate) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TSysUserPermissionTemplateRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TSysUserPermissionTemplate>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TSysUserPermissionTemplate>.Create(True);
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

function TSysUserPermissionTemplateRepository.DoFindById(AId: TValue; ALock: Boolean): TSysUserPermissionTemplate;
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

function TSysUserPermissionTemplateRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TSysUserPermissionTemplate;
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

procedure TSysUserPermissionTemplateRepository.DoAdd(AModel: TSysUserPermissionTemplate);
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

procedure TSysUserPermissionTemplateRepository.DoAddBatch(AModels: TArray<TSysUserPermissionTemplate>);
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

procedure TSysUserPermissionTemplateRepository.DoUpdate(AModel: TSysUserPermissionTemplate);
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

procedure TSysUserPermissionTemplateRepository.DoUpdateBatch(AModels: TArray<TSysUserPermissionTemplate>);
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

procedure TSysUserPermissionTemplateRepository.DoDelete(AID: TValue);
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

procedure TSysUserPermissionTemplateRepository.DoDelete(AModel: TSysUserPermissionTemplate);
begin
  Delete(AModel.Id);
end;

procedure TSysUserPermissionTemplateRepository.DoDeleteBatch(AModels: TArray<TSysUserPermissionTemplate>);
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

procedure TSysUserPermissionTemplateRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TSysUserPermissionTemplateRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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

procedure TSysUserPermissionTemplateRepository.CopyUserTemplates(ASourceUserId, ATargetUserId: Int64);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareDeleteSql + ' sys_user_id = :target_user_id';
    Q.ParamByName('target_user_id').AsLargeInt := ATargetUserId;
    LogQuery(Q, 'CopyUserTemplates.Delete');
    Q.ExecSQL;

    Q.SQL.Text := 'INSERT INTO public.' + Self.GetTableName(TSysUserPermissionTemplate) +
                  ' (sys_user_id, sys_permission_template_id) ' +
                  'SELECT :target_user_id, sys_permission_template_id FROM public.' + Self.GetTableName(TSysUserPermissionTemplate) +
                  ' WHERE sys_user_id = :source_user_id';
    Q.ParamByName('target_user_id').AsLargeInt := ATargetUserId;
    Q.ParamByName('source_user_id').AsLargeInt := ASourceUserId;
    LogQuery(Q, 'CopyUserTemplates.Insert');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

end.
