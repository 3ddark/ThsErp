unit SysPermissionTemplate.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, SysPermissionTemplate;

type
  TSysPermissionTemplateRepository = class(TRepository<TSysPermissionTemplate>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TSysPermissionTemplate; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TSysPermissionTemplate; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TSysPermissionTemplate; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TSysPermissionTemplate>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TSysPermissionTemplate; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TSysPermissionTemplate; override;

    procedure DoAdd(AModel: TSysPermissionTemplate); override;
    procedure DoAddBatch(AModels: TArray<TSysPermissionTemplate>); override;

    procedure DoUpdate(AModel: TSysPermissionTemplate); override;
    procedure DoUpdateBatch(AModels: TArray<TSysPermissionTemplate>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TSysPermissionTemplate); override;
    procedure DoDeleteBatch(AModels: TArray<TSysPermissionTemplate>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TSysPermissionTemplateRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSysPermissionTemplateRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TSysPermissionTemplate) +
            ' (template_key, template_name, description, active) ' +
            ' VALUES (:template_key, :template_name, :description, :active)';
end;

function TSysPermissionTemplateRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TSysPermissionTemplate) +
            ' SET template_key = :template_key, template_name = :template_name, description = :description, active = :active ' +
            ' WHERE id = :id';
end;

function TSysPermissionTemplateRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TSysPermissionTemplate) + ' WHERE';
end;

procedure TSysPermissionTemplateRepository.SetInsertParams(Q: TFDQuery; AModel: TSysPermissionTemplate; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('template_key').AsString := AModel.TemplateKey;
    Q.ParamByName('template_name').AsString := AModel.TemplateName;
    Q.ParamByName('description').AsString := AModel.Description;
    Q.ParamByName('active').AsBoolean := AModel.Active;
  end
  else
  begin
    Q.ParamByName('template_key').AsStrings[AIndex] := AModel.TemplateKey;
    Q.ParamByName('template_name').AsStrings[AIndex] := AModel.TemplateName;
    Q.ParamByName('description').AsStrings[AIndex] := AModel.Description;
    Q.ParamByName('active').AsBooleans[AIndex] := AModel.Active;
  end;
end;

procedure TSysPermissionTemplateRepository.SetUpdateParams(Q: TFDQuery; AModel: TSysPermissionTemplate; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('id').AsLargeInt := AModel.Id;
    Q.ParamByName('template_key').AsString := AModel.TemplateKey;
    Q.ParamByName('template_name').AsString := AModel.TemplateName;
    Q.ParamByName('description').AsString := AModel.Description;
    Q.ParamByName('active').AsBoolean := AModel.Active;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('template_key').AsStrings[AIndex] := AModel.TemplateKey;
    Q.ParamByName('template_name').AsStrings[AIndex] := AModel.TemplateName;
    Q.ParamByName('description').AsStrings[AIndex] := AModel.Description;
    Q.ParamByName('active').AsBooleans[AIndex] := AModel.Active;
  end;
end;

function TSysPermissionTemplateRepository.MapFromQuery(Q: TFDQuery): TSysPermissionTemplate;
begin
  Result := TSysPermissionTemplate.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.TemplateKey := Q.FieldByName('template_key').AsString;
  Result.TemplateName := Q.FieldByName('template_name').AsString;
  Result.Description := Q.FieldByName('description').AsString;
  Result.Active := Q.FieldByName('active').AsBoolean;
end;

function TSysPermissionTemplateRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TSysPermissionTemplate) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TSysPermissionTemplateRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TSysPermissionTemplate>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TSysPermissionTemplate>.Create(True);
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

function TSysPermissionTemplateRepository.DoFindById(AId: TValue; ALock: Boolean): TSysPermissionTemplate;
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

function TSysPermissionTemplateRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TSysPermissionTemplate;
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

procedure TSysPermissionTemplateRepository.DoAdd(AModel: TSysPermissionTemplate);
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

procedure TSysPermissionTemplateRepository.DoAddBatch(AModels: TArray<TSysPermissionTemplate>);
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

procedure TSysPermissionTemplateRepository.DoUpdate(AModel: TSysPermissionTemplate);
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

procedure TSysPermissionTemplateRepository.DoUpdateBatch(AModels: TArray<TSysPermissionTemplate>);
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

procedure TSysPermissionTemplateRepository.DoDelete(AID: TValue);
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

procedure TSysPermissionTemplateRepository.DoDelete(AModel: TSysPermissionTemplate);
begin
  Delete(AModel.Id);
end;

procedure TSysPermissionTemplateRepository.DoDeleteBatch(AModels: TArray<TSysPermissionTemplate>);
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

procedure TSysPermissionTemplateRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TSysPermissionTemplateRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
