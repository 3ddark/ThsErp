unit SysUser.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections, System.Rtti,
  FireDAC.Comp.Client, FireDAC.Stan.Param, SharedFormTypes, AppContext, Entity,
  Repository, FilterCriterion, SysUser;

type
  TSysUserRepository = class(TRepository<TSysUser>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TSysUser; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TSysUser; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TSysUser; override;
  public
    constructor Create(AConnection: TFDConnection);

    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean = False): TList<TSysUser>; override;
    function FindById(AId: TValue; ALock: Boolean = False): TSysUser; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TSysUser; override;

    procedure Add(AModel: TSysUser); override;
    procedure AddBatch(AModels: TArray<TSysUser>); override;

    procedure Update(AModel: TSysUser); override;
    procedure UpdateBatch(AModels: TArray<TSysUser>); override;

    procedure Delete(AID: Int64); override;
    procedure Delete(AModel: TSysUser); override;
    procedure DeleteBatch(AModels: TArray<TSysUser>); override;
    procedure DeleteBatch(AIDs: TArray<Int64>); override;
    procedure DeleteBatch(AFilter: TFilterCriteria); override;
  end;

implementation

uses
  EmpPerson, EmpUnit, EmpSection;

constructor TSysUserRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSysUserRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TSysUser) +
            ' (username, user_password, active, manager, super_user, ip_address, mac_address, person_id) ' +
            ' VALUES (:username, :user_password, :active, :manager, :super_user, :ip_address, :mac_address, :person_id)';
end;

function TSysUserRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TSysUser) +
            ' SET username = :username, user_password = :user_password, active = :active, ' +
            '     manager = :manager, super_user = :super_user, ip_address = :ip_address, ' +
            '     mac_address = :mac_address, person_id = :person_id ' +
            ' WHERE id = :id';
end;

function TSysUserRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TSysUser) + ' WHERE';
end;

procedure TSysUserRepository.SetInsertParams(Q: TFDQuery; AModel: TSysUser; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('username').AsString := AModel.Username;
    Q.ParamByName('user_password').AsString := AModel.UserPassword;
    Q.ParamByName('active').AsBoolean := AModel.Active;
    Q.ParamByName('manager').AsBoolean := AModel.Manager;
    Q.ParamByName('super_user').AsBoolean := AModel.SuperUser;
    Q.ParamByName('ip_address').AsString := AModel.IpAddress;
    Q.ParamByName('mac_address').AsString := AModel.MacAddress;
    Q.ParamByName('person_id').AsLargeInt := AModel.PersonId;
  end
  else
  begin
    Q.ParamByName('username').AsStrings[AIndex] := AModel.Username;
    Q.ParamByName('user_password').AsStrings[AIndex] := AModel.UserPassword;
    Q.ParamByName('active').AsBooleans[AIndex] := AModel.Active;
    Q.ParamByName('manager').AsBooleans[AIndex] := AModel.Manager;
    Q.ParamByName('super_user').AsBooleans[AIndex] := AModel.SuperUser;
    Q.ParamByName('ip_address').AsStrings[AIndex] := AModel.IpAddress;
    Q.ParamByName('mac_address').AsStrings[AIndex] := AModel.MacAddress;
    Q.ParamByName('person_id').AsLargeInts[AIndex] := AModel.PersonId;
  end;
end;

procedure TSysUserRepository.SetUpdateParams(Q: TFDQuery; AModel: TSysUser; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('id').AsLargeInt            := AModel.Id;
    Q.ParamByName('username').AsString := AModel.Username;
    Q.ParamByName('user_password').AsString := AModel.UserPassword;
    Q.ParamByName('active').AsBoolean := AModel.Active;
    Q.ParamByName('manager').AsBoolean := AModel.Manager;
    Q.ParamByName('super_user').AsBoolean := AModel.SuperUser;
    Q.ParamByName('ip_address').AsString := AModel.IpAddress;
    Q.ParamByName('mac_address').AsString := AModel.MacAddress;
    Q.ParamByName('person_id').AsLargeInt := AModel.PersonId;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex]            := AModel.Id;
    Q.ParamByName('username').AsStrings[AIndex] := AModel.Username;
    Q.ParamByName('user_password').AsStrings[AIndex] := AModel.UserPassword;
    Q.ParamByName('active').AsBooleans[AIndex] := AModel.Active;
    Q.ParamByName('manager').AsBooleans[AIndex] := AModel.Manager;
    Q.ParamByName('super_user').AsBooleans[AIndex] := AModel.SuperUser;
    Q.ParamByName('ip_address').AsStrings[AIndex] := AModel.IpAddress;
    Q.ParamByName('mac_address').AsStrings[AIndex] := AModel.MacAddress;
    Q.ParamByName('person_id').AsLargeInts[AIndex] := AModel.PersonId;
  end;
end;

function TSysUserRepository.MapFromQuery(Q: TFDQuery): TSysUser;
begin
  Result := TSysUser.Create;
  Result.Id           := Q.FieldByName('id').AsLargeInt;
  Result.Username     := Q.FieldByName('username').AsString;
  Result.UserPassword := Q.FieldByName('user_password').AsString;
  Result.Active       := Q.FieldByName('active').AsBoolean;
  Result.Manager      := Q.FieldByName('manager').AsBoolean;
  Result.SuperUser    := Q.FieldByName('super_user').AsBoolean;
  Result.IpAddress    := Q.FieldByName('ip_address').AsString;
  Result.MacAddress   := Q.FieldByName('mac_address').AsString;
  Result.PersonId     := Q.FieldByName('person_id').AsLargeInt;
end;

function TSysUserRepository.FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT * FROM ' + Self.GetFullViewName(TSysUser) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TSysUserRepository.Find(AFilter: TFilterCriteria; ALock: Boolean): TList<TSysUser>;
var
  Q: TFDQuery;
  Item: TSysUser;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TSysUser>.Create(True);
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

function TSysUserRepository.FindById(AId: TValue; ALock: Boolean): TSysUser;
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

function TSysUserRepository.FindOne(AFilter: TFilterCriteria; ALock: Boolean): TSysUser;
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

procedure TSysUserRepository.Add(AModel: TSysUser);
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

procedure TSysUserRepository.AddBatch(AModels: TArray<TSysUser>);
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

procedure TSysUserRepository.Update(AModel: TSysUser);
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

procedure TSysUserRepository.UpdateBatch(AModels: TArray<TSysUser>);
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

procedure TSysUserRepository.Delete(AID: Int64);
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

procedure TSysUserRepository.Delete(AModel: TSysUser);
begin
  Delete(AModel.Id);
end;

procedure TSysUserRepository.DeleteBatch(AModels: TArray<TSysUser>);
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

procedure TSysUserRepository.DeleteBatch(AIDs: TArray<Int64>);
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

procedure TSysUserRepository.DeleteBatch(AFilter: TFilterCriteria);
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
