unit SysLanguage.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections, System.Rtti,
  FireDAC.Comp.Client, FireDAC.Stan.Param, SharedFormTypes, AppContext, Entity,
  Repository, FilterCriterion, SysLanguage;

type
  TSysLanguageRepository = class(TRepository<TSysLanguage>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TSysLanguage; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TSysLanguage; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TSysLanguage; override;
  public
    constructor Create(AConnection: TFDConnection);

    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean = False): TList<TSysLanguage>; override;
    function FindById(AId: TValue; ALock: Boolean = False): TSysLanguage; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TSysLanguage; override;

    procedure Add(AModel: TSysLanguage); override;
    procedure AddBatch(AModels: TArray<TSysLanguage>); override;

    procedure Update(AModel: TSysLanguage); override;
    procedure UpdateBatch(AModels: TArray<TSysLanguage>); override;

    procedure Delete(AID: Int64); override;
    procedure Delete(AModel: TSysLanguage); override;
    procedure DeleteBatch(AModels: TArray<TSysLanguage>); override;
    procedure DeleteBatch(AIDs: TArray<Int64>); override;
    procedure DeleteBatch(AFilter: TFilterCriteria); override;
  end;

implementation

constructor TSysLanguageRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSysLanguageRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TSysLanguage) +
            ' (locale, native_name) ' +
            ' VALUES (:locale, :native_name)';
end;

function TSysLanguageRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TSysLanguage) +
            ' SET locale = :locale, native_name = :native_name ' +
            ' WHERE id = :id';
end;

function TSysLanguageRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TSysLanguage) + ' WHERE';
end;

procedure TSysLanguageRepository.SetInsertParams(Q: TFDQuery; AModel: TSysLanguage; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('locale').AsString := AModel.Locale;
    Q.ParamByName('native_name').AsString := AModel.NativeName;
  end
  else
  begin
    Q.ParamByName('locale').AsStrings[AIndex] := AModel.Locale;
    Q.ParamByName('native_name').AsStrings[AIndex] := AModel.NativeName;
  end;
end;

procedure TSysLanguageRepository.SetUpdateParams(Q: TFDQuery; AModel: TSysLanguage; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('id').AsLargeInt            := AModel.Id;
    Q.ParamByName('locale').AsString := AModel.Locale;
    Q.ParamByName('native_name').AsString := AModel.NativeName;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex]            := AModel.Id;
    Q.ParamByName('locale').AsStrings[AIndex] := AModel.Locale;
    Q.ParamByName('native_name').AsStrings[AIndex] := AModel.NativeName;
  end;
end;

function TSysLanguageRepository.MapFromQuery(Q: TFDQuery): TSysLanguage;
begin
  Result := TSysLanguage.Create;
  Result.Id           := Q.FieldByName('id').AsLargeInt;
  Result.Locale     := Q.FieldByName('locale').AsString;
  Result.NativeName := Q.FieldByName('native_name').AsString;
end;

function TSysLanguageRepository.FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT * FROM ' + Self.GetFullViewName(TSysLanguage) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TSysLanguageRepository.Find(AFilter: TFilterCriteria; ALock: Boolean): TList<TSysLanguage>;
var
  Q: TFDQuery;
  Item: TSysLanguage;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TSysLanguage>.Create(True);
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := Self.PrepareSelectFromView(AFilter, ALock);

    if Assigned(AFilter) and (AFilter.Count > 0) then
    begin
      for Criteria in AFilter do
        Q.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
    end;

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

function TSysLanguageRepository.FindById(AId: TValue; ALock: Boolean): TSysLanguage;
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
    Q.SQL.Text := Self.PrepareSelectFromView(Criteria, ALock, True);

    Q.ParamByName('id').AsLargeInt := AId.AsInt64;
    Q.Open;

    if not Q.IsEmpty then
      Result := MapFromQuery(Q);
  finally
    Q.Free;
    Criteria.Free;
  end;
end;

function TSysLanguageRepository.FindOne(AFilter: TFilterCriteria; ALock: Boolean): TSysLanguage;
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
    Q.SQL.Text := Self.PrepareSelectFromView(AFilter, ALock, True);

    for Criteria in AFilter do
      Q.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
    Q.Open;

    if not Q.IsEmpty then
      Result := MapFromQuery(Q);
  finally
    Q.Free;
  end;
end;

procedure TSysLanguageRepository.Add(AModel: TSysLanguage);
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

procedure TSysLanguageRepository.AddBatch(AModels: TArray<TSysLanguage>);
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

procedure TSysLanguageRepository.Update(AModel: TSysLanguage);
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

procedure TSysLanguageRepository.UpdateBatch(AModels: TArray<TSysLanguage>);
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

procedure TSysLanguageRepository.Delete(AID: Int64);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareDeleteSql + ' id = :id';
    Q.ParamByName('id').AsLargeInt := AID;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TSysLanguageRepository.Delete(AModel: TSysLanguage);
begin
  Delete(AModel.Id);
end;

procedure TSysLanguageRepository.DeleteBatch(AModels: TArray<TSysLanguage>);
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

procedure TSysLanguageRepository.DeleteBatch(AIDs: TArray<Int64>);
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
      Q.ParamByName('id').AsLargeInts[I] := AIDs[I];

    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TSysLanguageRepository.DeleteBatch(AFilter: TFilterCriteria);
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

end.
