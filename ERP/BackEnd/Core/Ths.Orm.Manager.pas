unit Ths.Orm.Manager;

interface

uses
  System.SysUtils, Classes, StrUtils, System.Variants, Data.DB,
  System.Rtti, System.Generics.Collections,
  ZAbstractRODataset, ZAbstractDataset, ZDataset,
  ZAbstractConnection, ZConnection,
  Ths.Orm.Table;

type
  TEntityManager = class;
  TPermissionTypes = (prtRead, prtAdd, prtUpdate, prtDelete, prtSpecial);

  TBusinessSelectEvent = procedure(AManager: TEntityManager; AFilter: string; ALock, APermissionCheck: Boolean) of Object;
  TBusinessOperationEvent = procedure(AManager: TEntityManager; APermissionCheck: Boolean) of Object;

  TEntityManager = class
  private
    FConnection: TZConnection;

    function NewQuery: TZQuery;

    function CallCreateMethod(AClass: TClass): TThsTable;
    function CallCreateMethod2<T>: T;

    function PrepareSelectQuery(ATable: TThsTable): string;
    function PrepareSelectCustomQuery(ATable: TThsTable; AFields: TArray<TThsField>): string;
    function PrepareInsertQuery(ATable: TThsTable): string;
    function PrepareUpdateQuery(ATable: TThsTable): string;
    function PrepareUpdateCustomQuery(ATable: TThsTable; AFields: TArray<TThsField>): string;
    function PrepareDeleteQuery(ATable: TThsTable): string;

    function GetOneBase(ATable: TThsTable; AFilter: string; ALock: Boolean): Boolean;
    function GetOneCustomBase(const ATable: TThsTable; AFields: TArray<TThsField>; AFilter: string; ALock: Boolean): Boolean;
  public
    property Connection: TZConnection read FConnection;

    constructor Create(AHostName, ADatabase, AUserName, AUserPass, ALibraryPath: string; APort: Integer); virtual;
    destructor Destroy; override;

    function GetList<T: Class>(var AList: TObjectList<T>; AFilter: string; ALock: Boolean; APermissionCheck: Boolean=True): Boolean;
    function GetListCustom(AClass: TClass; var AList: TArray<TThsTable>; AFields: TArray<TThsField>; AFilter: string; ALock: Boolean; APermissionCheck: Boolean=True): Boolean;

    function GetOne(ATable: TThsTable; AFilter: string; ALock: Boolean; APermissionCheck: Boolean=True): Boolean; overload;
    function GetOneCustom(ATable: TThsTable; AFields: TArray<TThsField>; AFilter: string; ALock: Boolean; APermissionCheck: Boolean=True): Boolean; overload;
    function GetOne(ATable: TThsTable; AID: Int64; ALock: Boolean; APermissionCheck: Boolean=True): Boolean; overload;
    function GetOneCustom(ATable: TThsTable; AFields: TArray<TThsField>; AID: Int64; ALock: Boolean; APermissionCheck: Boolean=True): Boolean; overload;

    function Insert(ATable: TThsTable; APermissionCheck: Boolean=True): Boolean; virtual;
    function DoInsert(ATable: TThsTable; APermissionCheck: Boolean=True): Boolean;
    function BeforeInsertDB(ATable: TThsTable): Boolean; virtual;
    function AfterInsertDB(ATable: TThsTable): Boolean; virtual;

    function Update(ATable: TThsTable; APermissionCheck: Boolean=True): Boolean; virtual;
    function DoUpdate(ATable: TThsTable; APermissionCheck: Boolean): Boolean;
    function BeforeUpdateDB(ATable: TThsTable): Boolean; virtual;
    function AfterUpdateDB(ATable: TThsTable): Boolean; virtual;

    function CustomUpdate(ATable: TThsTable; AFields: TArray<TThsField>; APermissionCheck: Boolean=True): Boolean; virtual;
    function DoCustomUpdate(ATable: TThsTable; AFields: TArray<TThsField>; APermissionCheck: Boolean): Boolean;
    function BeforeCustomUpdateDB(ATable: TThsTable): Boolean; virtual;
    function AfterCustomUpdateDB(ATable: TThsTable): Boolean; virtual;

    function DeleteBatch(ATables: TArray<TThsTable>; APermissionCheck: Boolean=True): Boolean; virtual;
    function Delete(ATable: TThsTable; APermissionCheck: Boolean=True): Boolean; virtual;
    function DoDelete(ATable: TThsTable; APermissionCheck: Boolean): Boolean; virtual;
    function BeforeDeleteDB(ATable: TThsTable): Boolean; virtual;
    function AfterDeleteDB(ATable: TThsTable): Boolean; virtual;

    function LogicalSelect(AFilter: string; ALock, AWithBegin, APermissionCheck: Boolean; AProcBusinessSelect: TBusinessSelectEvent): Boolean; virtual;
    function LogicalInsert(AWithBegin, AWithCommit, APermissionCheck: Boolean; AProcBusinessInsert: TBusinessOperationEvent): Boolean; virtual;
    function LogicalUpdate(AWithCommit, APermissionCheck: Boolean; AProcBusinessUpdate: TBusinessOperationEvent): Boolean; virtual;
    function LogicalDelete(AWithCommit, APermissionCheck: Boolean; AProcBusinessDelete: TBusinessOperationEvent): Boolean; virtual;

    procedure Listen(ATableName: string); virtual;
    procedure Unlisten(ATableName: string); virtual;
    procedure Notify(ATableName: string); virtual;

    function IsAuthorized(ATableSourceCode: string; APermissionType: TPermissionTypes; APermissionCheck: Boolean; AShowException: Boolean=True): Boolean;

    procedure StartTrans(AConnection: TZAbstractConnection = nil);
    procedure CommitTrans(AConnection: TZAbstractConnection = nil);
    procedure RollbackTrans(AConnection: TZAbstractConnection = nil);

    function GetToday(): TDateTime;
  end;

implementation

uses Logger;

function TEntityManager.CallCreateMethod(AClass: TClass): TThsTable;
var
  AModel: TObject;

  rC: TRttiContext;
  rT: TRttiType;
  rM: TRttiMethod;
  n1: Integer;
  rPrms: TArray<TRttiParameter>;
  rParams: TArray<TValue>;
begin
  Result := nil;
  rT := rC.GetType(AClass);
  rM := rT.GetMethod('Create');
  rPrms := rM.GetParameters;
  SetLength(rParams, Length(rPrms));
  for n1 := 0 to Length(rPrms) - 1 do
    case rPrms[n1].ParamType.TypeKind of // do whatever you need to initialize parameters
      tkClass:
        rParams[n1] := TValue.From<TObject>(nil);
      tkString:
        rParams[n1] := TValue.From<string>('');
      tkUString:
        rParams[n1] := TValue.From<UnicodeString>('');
      tkInteger, tkInt64:
        rParams[n1] := TValue.From<Integer>(0);
    end;

  if rM.IsConstructor then
  begin
    AModel := rM.Invoke(rT.AsInstance.MetaclassType, rParams).AsObject;
    Result := TThsTable(AModel);
  end;
end;

function TEntityManager.CallCreateMethod2<T>: T;
var
  AModel: TObject;

  rC: TRttiContext;
  rT: TRttiType;
  rM: TRttiMethod;
  n1: Integer;
  rPrms: TArray<TRttiParameter>;
  rParams: TArray<TValue>;
begin
  rT := rC.GetType(TypeInfo(T));
  rM := rT.GetMethod('Create');
  rPrms := rM.GetParameters;
  SetLength(rParams, Length(rPrms));
  for n1 := 0 to Length(rPrms) - 1 do
    case rPrms[n1].ParamType.TypeKind of // do whatever you need to initialize parameters
      tkClass:
        rParams[n1] := TValue.From<TObject>(nil);
      tkString:
        rParams[n1] := TValue.From<string>('');
      tkUString:
        rParams[n1] := TValue.From<UnicodeString>('');
      tkInteger, tkInt64:
        rParams[n1] := TValue.From<Integer>(0);
    end;

  if rM.IsConstructor then
  begin
    Result := rM.Invoke(rT.AsInstance.MetaclassType, rParams).AsType<T>;
  end;
end;

constructor TEntityManager.Create(AHostName, ADatabase, AUserName, AUserPass, ALibraryPath: string; APort: Integer);
begin
  FConnection := TZConnection.Create(nil);

  FConnection.LibraryLocation := ALibraryPath;
  FConnection.Protocol := 'postgresql-9';
  FConnection.ClientCodepage := 'UTF8';
  FConnection.HostName := AHostName;
  FConnection.Database := ADatabase;
  FConnection.User := AUserName;
  FConnection.Password := AUserPass;
  FConnection.Port := APort;
  FConnection.LoginPrompt := False;

  with Self.NewQuery do
  try
    SQL.Text := 'SELECT pg_backend_pid()';
    Open;
    GLogger.DBConnectionPID := Fields.Fields[0].AsString;
    Close;
  finally
    Free;
  end
end;

destructor TEntityManager.Destroy;
begin
  FConnection.DisposeOf;
  inherited;
end;

function TEntityManager.GetList<T>(var AList: TObjectList<T>; AFilter: string; ALock, APermissionCheck: Boolean): Boolean;
var
  ATable: T;
  AFieldDB: TThsField;
  AField: TField;
  LQry: TZQuery;
begin
  Result := False;
  try
    AList := TObjectList<T>.Create;

    ATable := CallCreateMethod2<T>;
    if not Self.IsAuthorized((ATable as TThsTable).TableSourceCode, TPermissionTypes.prtRead, APermissionCheck) then
    begin
      ATable.DisposeOf;
      Exit;
    end;

    LQry := Self.NewQuery;
    try
      LQry.SQL.Text := Self.PrepareSelectQuery(ATable as TThsTable) + ' WHERE ' + IfThen(AFilter = '', '1=1', AFilter);
      ATable.DisposeOf;
      LQry.Prepare;
      if LQry.Prepared then
      begin
        LQry.Open;
        if LQry.RecordCount > 0 then
          Result := True;
        LQry.First;
        while not LQry.Eof do
        begin
          ATable := CallCreateMethod2<T>;
          //for AFieldDB in ATable.Fields do
          for AFieldDB in (ATable as TThsTable).Fields do
          begin
            if fpSelect in AFieldDB.FieldIslemTipleri then
            begin
              for AField in LQry.Fields do
              begin
                if AFieldDB.FieldName = AField.FieldName then
                begin
                  AFieldDB.Value := AField.Value;
                  Break;
                end;
              end;
            end;
          end;

          AList.Add(ATable);

          LQry.Next;
        end;
      end;
    finally
      LQry.DisposeOf;
    end;
  except
    on E: Exception do
    begin
      GLogger.ErrorLog(E);
    end;
  end;
end;

function TEntityManager.GetListCustom(AClass: TClass; var AList: TArray<TThsTable>; AFields: TArray<TThsField>; AFilter: string; ALock, APermissionCheck: Boolean): Boolean;
var
  n1: Integer;
  ATable: TThsTable;
  AFieldDB: TThsField;
  AField: TField;
  LQry: TZQuery;
begin
  Result := False;
  try
    ATable := CallCreateMethod(AClass) as TThsTable;

    if not Self.IsAuthorized(ATable.TableSourceCode, TPermissionTypes.prtRead, APermissionCheck) then
    begin
      ATable.DisposeOf;
      Exit;
    end;

    LQry := Self.NewQuery;
    try
      LQry.SQL.Text := Self.PrepareSelectCustomQuery(ATable, AFields) + ' WHERE ' + AFilter;
      ATable.DisposeOf;
      LQry.Prepare;
      if LQry.Prepared then
      begin
        LQry.Open;
        if LQry.RecordCount > 0 then
          Result := True;
        n1 := 0;
        SetLength(AList, n1);
        LQry.First;
        while not LQry.Eof do
        begin
          ATable := CallCreateMethod(AClass) as TThsTable;
          for AFieldDB in (ATable).Fields do
          begin
            if fpSelect in AFieldDB.FieldIslemTipleri then
            begin
              for AField in LQry.Fields do
              begin
                if AFieldDB.FieldName = AField.FieldName then
                begin
                  AFieldDB.Value := AField.Value;
                  Break;
                end;
              end;
            end;
          end;

          Inc(n1);
          SetLength(AList, n1);
          AList[n1-1] := ATable;

          LQry.Next;
        end;
      end;
    finally
      LQry.DisposeOf;
    end;
  except
    on E: Exception do
    begin
      GLogger.ErrorLog(E);
    end;
  end;
end;

function TEntityManager.GetOne(ATable: TThsTable; AFilter: string; ALock, APermissionCheck: Boolean): Boolean;
begin
  Result := Self.IsAuthorized(ATable.TableSourceCode, TPermissionTypes.prtRead, APermissionCheck);
  if not Result then
    Exit;

  Result := GetOneBase(ATable, AFilter, ALock);
end;

function TEntityManager.GetOneCustom(ATable: TThsTable; AFields: TArray<TThsField>; AFilter: string; ALock, APermissionCheck: Boolean): Boolean;
begin
  Result := Self.IsAuthorized(ATable.TableSourceCode, TPermissionTypes.prtRead, APermissionCheck);
  if not Result then
    Exit;

  Result := GetOneCustomBase(ATable, AFields, AFilter, ALock);
end;

function TEntityManager.GetOne(ATable: TThsTable; AID: Int64; ALock: Boolean; APermissionCheck: Boolean): Boolean;
begin
  Result := Self.IsAuthorized(ATable.TableSourceCode, TPermissionTypes.prtRead, APermissionCheck);
  if not Result then
    Exit;

  Result := GetOneBase(ATable, 'id=' + AID.ToString, ALock)
end;

function TEntityManager.GetOneCustom(ATable: TThsTable; AFields: TArray<TThsField>; AID: Int64; ALock, APermissionCheck: Boolean): Boolean;
begin
  Result := Self.IsAuthorized(ATable.TableSourceCode, TPermissionTypes.prtRead, APermissionCheck);
  if not Result then
    Exit;

  Result := GetOneCustomBase(ATable, AFields, 'id=' + AID.ToString, ALock);
end;

function TEntityManager.GetOneBase(ATable: TThsTable; AFilter: string; ALock: Boolean): Boolean;
var
  AFieldDB: TThsField;
  AField: TField;
  LQry: TZQuery;
begin
  Result := False;
  try
    try
      if (ATable.TableName = '') then
        Exit;
    except
      raise Exception.Create('GetOne ile doldurulacak olan ATable parametresi tanýmlý olmak zorunda!!!');
    end;

    LQry := Self.NewQuery;
    try
      if AFilter = '' then
        AFilter := '1=1';
      LQry.SQL.Text := Self.PrepareSelectQuery((ATable)) + ' WHERE ' + AFilter;
      LQry.SQL.Text := LQry.SQL.Text + IfThen(ALock, ' FOR UPDATE OF ' + ATable.TableName + ' NOWAIT;', ';');

      LQry.Prepare;
      if LQry.Prepared then
      begin
        LQry.Open;
        GLogger.RunLog(LQry.SQL.Text.Replace(sLineBreak, ''));
        if LQry.RecordCount > 1 then
          raise Exception.Create('Verilen parametre ile birden fazla kayýt bulundu!!!');

        if LQry.RecordCount = 1 then
          Result := True;
        for AFieldDB in (ATable).Fields do
        begin
          if fpSelect in AFieldDB.FieldIslemTipleri then
          begin
            for AField in LQry.Fields do
            begin
              if AFieldDB.FieldName = AField.FieldName then
              begin
                AFieldDB.Value := AField.Value;
                Break;
              end;
            end;
          end;
        end;
      end;
    finally
      LQry.DisposeOf;
    end;
  except
    on E: Exception do
    begin
      GLogger.ErrorLog(E);
    end;
  end;
end;

function TEntityManager.GetOneCustomBase(const ATable: TThsTable; AFields: TArray<TThsField>; AFilter: string; ALock: Boolean): Boolean;
var
  AFieldDB: TThsField;
  AField: TField;
  LQry: TZQuery;
begin
  Result := False;
  try
    try
      if (ATable.TableName = '') then
        Exit;
    except
      raise Exception.Create('GetOne ile doldurulacak olan ATable parametresi tanýmlý olmak zorunda!!!');
    end;

    LQry := Self.NewQuery;
    try
      if AFilter = '' then
        AFilter := '1=1';
      LQry.SQL.Text := Self.PrepareSelectCustomQuery(ATable, AFields) + ' WHERE ' + AFilter;
      LQry.SQL.Text := LQry.SQL.Text + IfThen(ALock, ' FOR UPDATE OF ' + ATable.TableName + ' NOWAIT;', ';');

      LQry.Prepare;
      if LQry.Prepared then
      begin
        LQry.Open;
        GLogger.RunLog(LQry.SQL.Text.Replace(sLineBreak, ''));
        if LQry.RecordCount > 1 then
          raise Exception.Create('Verilen parametre ile birden fazla kayýt bulundu!!!');

        if LQry.RecordCount = 1 then
          Result := True;
        for AFieldDB in (ATable).Fields do
        begin
          if fpSelect in AFieldDB.FieldIslemTipleri then
          begin
            for AField in LQry.Fields do
            begin
              if AFieldDB.FieldName = AField.FieldName then
              begin
                AFieldDB.Value := AField.Value;
                Break;
              end;
            end;
          end;
        end;
      end;
    finally
      LQry.DisposeOf;
    end;
  except
    on E: Exception do
    begin
      GLogger.ErrorLog(E);
    end;
  end;
end;

function TEntityManager.BeforeInsertDB(ATable: TThsTable): Boolean;
begin
  Result := ATable.Validate;
end;

function TEntityManager.Insert(ATable: TThsTable; APermissionCheck: Boolean): Boolean;
begin
  Result := IsAuthorized(ATable.TableSourceCode, TPermissionTypes.prtAdd, APermissionCheck);
  if not Result then
    Exit;

  if BeforeInsertDB(ATable) then
    if DoInsert(ATable, APermissionCheck) then
      AfterInsertDB(ATable);
end;

function TEntityManager.DoInsert(ATable: TThsTable; APermissionCheck: Boolean): Boolean;
var
  LQry: TZQuery;
begin
  Result := True;
  try
    LQry := Self.NewQuery;
    try
      LQry.SQL.Text := PrepareInsertQuery(ATable);
      LQry.Prepare;
      if LQry.Prepared then
      begin
        LQry.Open;
        GLogger.RunLog(LQry.SQL.Text.Replace(sLineBreak, ''));
        ATable.Id.Value := LQry.Fields.Fields[0].Value;
        LQry.Close;
      end;
    finally
      LQry.DisposeOf;
    end;
  except
    on E: Exception do
    begin
      Result := False;
      GLogger.ErrorLog(E);
    end;
  end;
end;

function TEntityManager.AfterInsertDB(ATable: TThsTable): Boolean;
begin
  GLogger.RunLog('INSERTING ' + ATable.ClassName + ' id: ' + IntToStr(ATable.Id.AsInteger));
  Result := True;
end;

function TEntityManager.BeforeUpdateDB(ATable: TThsTable): Boolean;
begin
  Result := ATable.Validate;
end;

function TEntityManager.Update(ATable: TThsTable; APermissionCheck: Boolean): Boolean;
begin
  Result := IsAuthorized(ATable.TableSourceCode, TPermissionTypes.prtUpdate, APermissionCheck);
  if not Result then
    Exit;

  if BeforeUpdateDB(ATable) then
    if DoUpdate(ATable, APermissionCheck) then
      AfterUpdateDB(ATable);
end;

function TEntityManager.DoUpdate(ATable: TThsTable; APermissionCheck: Boolean): Boolean;
var
  LQry: TZQuery;
begin
  Result := True;
  try
    LQry := Self.NewQuery;
    try
      LQry.SQL.Text := PrepareUpdateQuery(ATable);
      LQry.Prepare;
      if LQry.Prepared then
      begin
        LQry.ExecSQL;
        GLogger.RunLog(LQry.SQL.Text.Replace(sLineBreak, ''));
        LQry.Close;
      end;
    finally
      LQry.DisposeOf;
    end;
  except
    on E: Exception do
    begin
      Result := False;
      GLogger.ErrorLog(E);
    end;
  end;
end;

function TEntityManager.AfterUpdateDB(ATable: TThsTable): Boolean;
begin
  GLogger.RunLog('UPDATING ' + ATable.ClassName + ' id: ' + IntToStr(ATable.Id.AsInteger));
  Result := True;
end;

function TEntityManager.BeforeCustomUpdateDB(ATable: TThsTable): Boolean;
begin
  Result := ATable.Validate;
end;

function TEntityManager.CustomUpdate(ATable: TThsTable; AFields: TArray<TThsField>; APermissionCheck: Boolean): Boolean;
begin
  Result := IsAuthorized(ATable.TableSourceCode, TPermissionTypes.prtUpdate, APermissionCheck);
  if not Result then
    Exit;

  if BeforeCustomUpdateDB(ATable) then
    if DoCustomUpdate(ATable, AFields, APermissionCheck) then
      AfterCUstomUpdateDB(ATable);
end;

function TEntityManager.DoCustomUpdate(ATable: TThsTable; AFields: TArray<TThsField>; APermissionCheck: Boolean): Boolean;
var
  LQry: TZQuery;
begin
  Result := True;
  try
    LQry := Self.NewQuery;
    try
      LQry.SQL.Text := PrepareUpdateCustomQuery(ATable, AFields);
      LQry.Prepare;
      if LQry.Prepared then
      begin
        LQry.ExecSQL;
        GLogger.RunLog(LQry.SQL.Text.Replace(sLineBreak, ''));
        LQry.Close;
      end;
    finally
      LQry.DisposeOf;
    end;
  except
    on E: Exception do
    begin
      Result := False;
      GLogger.ErrorLog(E);
    end;
  end;
end;

function TEntityManager.AfterCustomUpdateDB(ATable: TThsTable): Boolean;
begin
  GLogger.RunLog('CUSTOM UPDATING ' + ATable.ClassName + ' id: ' + IntToStr(ATable.Id.AsInteger));
  Result := True;
end;

function TEntityManager.BeforeDeleteDB(ATable: TThsTable): Boolean;
begin
  Result := True;
end;

function TEntityManager.Delete(ATable: TThsTable; APermissionCheck: Boolean): Boolean;
begin
  Result := IsAuthorized(ATable.TableSourceCode, TPermissionTypes.prtDelete, APermissionCheck);
  if not Result then
    Exit;

  if BeforeDeleteDB(ATable) then
    if DoDelete(ATable, APermissionCheck) then
      AfterDeleteDB(ATable);
end;

function TEntityManager.DeleteBatch(ATables: TArray<TThsTable>; APermissionCheck: Boolean): Boolean;
var
  ATable: TThsTable;
  LPermissionCheck: Boolean;
begin
  LPermissionCheck := APermissionCheck;
  for ATable in ATables do
  begin
    Self.Delete(ATable, LPermissionCheck);
    if APermissionCheck then
      LPermissionCheck := False;
  end;
  Result := True;
end;

function TEntityManager.DoDelete(ATable: TThsTable; APermissionCheck: Boolean): Boolean;
begin
  with Self.NewQuery do
  try
    SQL.Text := PrepareDeleteQuery(ATable);
    ExecSQL;
    GLogger.RunLog(SQL.Text.Replace(sLineBreak, ''));
    Result := True;
  finally
    Free;
  end;
end;

function TEntityManager.AfterDeleteDB(ATable: TThsTable): Boolean;
begin
  GLogger.RunLog('DELETING ' + ATable.ClassName + ' id: ' + IntToStr(ATable.Id.AsInteger));
  Result := True;
end;

function TEntityManager.LogicalSelect(AFilter: string; ALock, AWithBegin, APermissionCheck: Boolean; AProcBusinessSelect: TBusinessSelectEvent): Boolean;
begin
  Result := False;
  try
    if not Assigned(AProcBusinessSelect) then
      raise Exception.Create('BusinessSelect event olmak zorunda!!!');

    if not ALock then
      AWithBegin := False;

    if AWithBegin then
      StartTrans;

    AProcBusinessSelect(Self, AFilter, ALock, APermissionCheck);

    Result := True;
  except
    on E: Exception do
    begin
      Self.RollbackTrans;
      GLogger.ErrorLog(E);
    end;
  end;
end;

function TEntityManager.LogicalInsert(AWithBegin, AWithCommit, APermissionCheck: Boolean; AProcBusinessInsert: TBusinessOperationEvent): Boolean;
begin
  Result := False;
  try
    if not Assigned(AProcBusinessInsert) then
      raise Exception.Create('BusinessInsert event olmak zorunda!!!');

    if AWithBegin then StartTrans;

    AProcBusinessInsert(Self, APermissionCheck);

    if AWithCommit then CommitTrans;
    Result := True;
  except
    on E: Exception do
    begin
      Self.RollbackTrans;
      GLogger.ErrorLog(E);
    end;
  end;
end;

function TEntityManager.LogicalUpdate(AWithCommit, APermissionCheck: Boolean; AProcBusinessUpdate: TBusinessOperationEvent): Boolean;
begin
  Result := False;
  try
    if not Assigned(AProcBusinessUpdate) then
      raise Exception.Create('BusinessUpdate event olmak zorunda!!!');

    AProcBusinessUpdate(Self, APermissionCheck);

    if AWithCommit then CommitTrans;
    Result := True;
  except
    on E: Exception do
    begin
      Self.RollbackTrans;
      GLogger.ErrorLog(E);
    end;
  end;
end;

function TEntityManager.LogicalDelete(AWithCommit, APermissionCheck: Boolean; AProcBusinessDelete: TBusinessOperationEvent): Boolean;
begin
  Result := False;
  try
    if not Assigned(AProcBusinessDelete) then
      raise Exception.Create('BusinessDelete event olmak zorunda!!!');

    AProcBusinessDelete(Self, APermissionCheck);

    if AWithCommit then CommitTrans;
    Result := True;
  except
    on E: Exception do
    begin
      Self.RollbackTrans;
      GLogger.ErrorLog(E);
    end;
  end;
end;

procedure TEntityManager.Listen(ATableName: string);
begin
  try
    if ATableName = '' then
      raise Exception.Create('Tablo adý olmak zorunda "LISTEN iþlemini yapamazsýn!!!"');

    with Self.NewQuery do
    try
      SQL.Text := 'listen ' + ATableName + ';';
      ExecSQL;
    finally
      Free;
    end;
    GLogger.RunLog('LISTENING ' + ATableName);
  except
    on E: Exception do
    begin
      GLogger.ErrorLog(E);
    end;
  end;
end;

procedure TEntityManager.Unlisten(ATableName: string);
begin
  try
    if ATableName = '' then
      raise Exception.Create('Tablo adý olmak zorunda "UNLISTEN iþlemini yapamazsýn!!!"');

    with Self.NewQuery do
    try
      SQL.Text := 'unlisten ' + ATableName + ';';
      ExecSQL;
    finally
      Free;
    end;
    GLogger.RunLog('UNLISTENING ' + ATableName );
  except
    on E: Exception do
    begin
      GLogger.ErrorLog(E);
    end;
  end;
end;

procedure TEntityManager.Notify(ATableName: string);
begin
  try
    if ATableName = '' then
      raise Exception.Create('Tablo adý olmak zorunda "NOTIFY iþlemini yapamazsýn!!!"');

    with Self.NewQuery do
    try
      SQL.Text := 'notify ' + ATableName + ';';
      ExecSQL;
    finally
      Free;
    end;
    GLogger.RunLog('NOTIFYING ' + ATableName );
  except
    on E: Exception do
    begin
      GLogger.ErrorLog(E);
    end;
  end;
end;

function TEntityManager.NewQuery: TZQuery;
begin
  Result := TZQuery.Create(nil);
  Result.Connection := FConnection;
end;

function TEntityManager.IsAuthorized(ATableSourceCode: string; APermissionType: TPermissionTypes; APermissionCheck, AShowException: Boolean): Boolean;
//var
//  LMessage: string;
//  LPermSourceCode: string;
//  n1: Integer;
begin
  Result := True;
  if not APermissionCheck then
    Result := True;
(*
    Result := False;
    LMessage := '';

    LPermSourceCode := ATableSourceCode;
    for n1 := 0 to GSysUserAccessRight.List.Count-1 do
    begin
      if  (TSysUserAccessRight(GSysUserAccessRight.List[n1]).SourceCode.AsString = LPermSourceCode) then
      begin
        if (APermissionType = ptRead) and (TSysUserAccessRight(GSysUserAccessRight.List[n1]).IsRead.AsBoolean) then
        begin
          Result := True;
          LMessage := 'SELECT';
          Break;
        end
        else if (APermissionType = ptAddRecord) and (TSysUserAccessRight(GSysUserAccessRight.List[n1]).IsAddRecord.AsBoolean) then
        begin
          Result := True;
          LMessage := 'INSERT';
          Break;
        end
        else if (APermissionType = ptUpdate) and (TSysUserAccessRight(GSysUserAccessRight.List[n1]).IsUpdate.AsBoolean) then
        begin
          Result := True;
          LMessage := 'UPDATE';
          Break;
        end
        else if (APermissionType = ptDelete) and (TSysUserAccessRight(GSysUserAccessRight.List[n1]).IsDelete.AsBoolean) then
        begin
          Result := True;
          LMessage := 'DELETE';
          Break;
        end
        else if (APermissionType = ptSpecial) and (TSysUserAccessRight(GSysUserAccessRight.List[n1]).IsSpecial.AsBoolean) then
        begin
          Result := True;
          LMessage := 'SPECIAL';
          Break;
        end
      end;
    end;

    LMessage := LMessage + ' ' + LPermSourceCode;

    if (not Result) and AShowException then
      raise Exception.Create(
        'Ýþlem ' + LMessage + AddLBs(2) +
        'Bu kaynaða eriþim hakkýnýz yok! : ' + TableName + ' ' + ClassName + AddLBs +
        'Bu tablo için eriþim kaynak kodu hatasý: ' + TableName + ' ' + LPermSourceCode);
*)
end;

function TEntityManager.PrepareSelectQuery(ATable: TThsTable): string;
var
  AFieldDB: TThsField;
  LFields: string;
begin
  LFields := '';
  for AFieldDB in ATable.Fields do
    if fpSelect in AFieldDB.FieldIslemTipleri then
      LFields := LFields + AFieldDB.QryName + ',';
  Result := 'SELECT ' + LeftStr(Trim(LFields), Length(LFields)-1) + ' FROM ' + ATable.SchemaName + '.' + ATable.TableName;
end;

function TEntityManager.PrepareSelectCustomQuery(ATable: TThsTable; AFields: TArray<TThsField>): string;
var
  AFieldDB: TThsField;
  LFields: string;
begin
  LFields := '';
  for AFieldDB in AFields do
    if fpSelect in AFieldDB.FieldIslemTipleri then
      LFields := LFields + AFieldDB.QryName + ',';
  Result := 'SELECT ' + LeftStr(Trim(LFields), Length(LFields)-1) + ' FROM ' + ATable.SchemaName + '.' + ATable.TableName;
end;

function TEntityManager.PrepareInsertQuery(ATable: TThsTable): string;
var
  AFieldDB: TThsField;
  LFields, LValues: string;
begin
  LFields := '';
  LValues := '';
  for AFieldDB in ATable.Fields do
    if fpInsert in AFieldDB.FieldIslemTipleri then
    begin
      LFields := LFields + AFieldDB.FieldName + ',';
      if (AFieldDB.DataType = ftString)
      or (AFieldDB.DataType = ftWideString)
      or (AFieldDB.DataType = ftMemo)
      or (AFieldDB.DataType = ftWideMemo)
      or (AFieldDB.DataType = ftFmtMemo)
      or (AFieldDB.DataType = ftGuid)
      or (AFieldDB.DataType = ftFixedChar)
      or (AFieldDB.DataType = ftFixedWideChar)
      then
        LValues := LValues + QuotedStr(AFieldDB.AsString) + ','
      else
      if (AFieldDB.DataType = ftSmallint)
      or (AFieldDB.DataType = ftSmallint)
      or (AFieldDB.DataType = ftLargeint)
      or (AFieldDB.DataType = ftWord)
      or (AFieldDB.DataType = ftLongWord)
      or (AFieldDB.DataType = ftShortint)
      or (AFieldDB.DataType = ftByte)
      then
        LValues := LValues + AFieldDB.AsString + ','
      else if (AFieldDB.DataType = ftDate) then
        LValues := LValues + DateToStr(AFieldDB.AsDate) + ','
      else if (AFieldDB.DataType = ftTime) then
        LValues := LValues + TimeToStr(AFieldDB.AsTime) + ','
      else
      if (AFieldDB.DataType = ftDateTime)
      or (AFieldDB.DataType = ftTimeStamp)
      then
        LValues := LValues + DateTimeToStr(AFieldDB.AsDateTime) + ','
      else
      if (AFieldDB.DataType = ftFloat)
      or (AFieldDB.DataType = ftBCD)
      or (AFieldDB.DataType = ftFMTBcd)
      then
        LValues := LValues + FloatToStr(AFieldDB.AsFloat) + ','
    end;

  Result := 'INSERT INTO ' + ATable.TableName + '(' + LeftStr(Trim(LFields), Length(LFields)-1) + ')' +
              'VALUES (' + LeftStr(Trim(LValues), Length(LValues)-1) + ') RETURNING id;';
end;

function TEntityManager.PrepareUpdateQuery(ATable: TThsTable): string;
var
  AFieldDB: TThsField;
  LQryText, LFields: string;
begin
  LQryText := 'INSERT INTO ' + ATable.TableName;
  LFields := '';
  for AFieldDB in ATable.Fields do
    if fpUpdate in AFieldDB.FieldIslemTipleri then
    begin
      if (AFieldDB.DataType = ftString)
      or (AFieldDB.DataType = ftWideString)
      or (AFieldDB.DataType = ftMemo)
      or (AFieldDB.DataType = ftWideMemo)
      or (AFieldDB.DataType = ftFmtMemo)
      or (AFieldDB.DataType = ftGuid)
      or (AFieldDB.DataType = ftFixedChar)
      or (AFieldDB.DataType = ftFixedWideChar)
      then
        LFields := LFields + AFieldDB.FieldName + '=' + QuotedStr(AFieldDB.AsString) + ','
      else
      if (AFieldDB.DataType = ftSmallint)
      or (AFieldDB.DataType = ftSmallint)
      or (AFieldDB.DataType = ftLargeint)
      or (AFieldDB.DataType = ftWord)
      or (AFieldDB.DataType = ftLongWord)
      or (AFieldDB.DataType = ftShortint)
      or (AFieldDB.DataType = ftByte)
      then
        LFields := LFields + AFieldDB.FieldName + '=' + AFieldDB.AsString + ','
      else if (AFieldDB.DataType = ftDate) then
        LFields := LFields + AFieldDB.FieldName + '=' + DateToStr(AFieldDB.AsDate) + ','
      else if (AFieldDB.DataType = ftTime) then
        LFields := LFields + AFieldDB.FieldName + '=' + TimeToStr(AFieldDB.AsTime) + ','
      else
      if (AFieldDB.DataType = ftDateTime)
      or (AFieldDB.DataType = ftTimeStamp)
      then
        LFields := LFields + AFieldDB.FieldName + '=' + DateTimeToStr(AFieldDB.AsDateTime) + ','
      else
      if (AFieldDB.DataType = ftFloat)
      or (AFieldDB.DataType = ftBCD)
      or (AFieldDB.DataType = ftFMTBcd)
      then
        LFields := LFields + AFieldDB.FieldName + '=' + FloatToStr(AFieldDB.AsFloat) + ','
    end;

  Result := 'UPDATE ' + ATable.TableName + ' SET ' + LeftStr(Trim(LFields), Length(LFields)-1) + ' WHERE id=' + ATable.Id.AsString + ';';
end;

function TEntityManager.PrepareUpdateCustomQuery(ATable: TThsTable; AFields: TArray<TThsField>): string;
var
  AFieldDB: TThsField;
  LQryText, LFields: string;
begin
  LQryText := 'INSERT INTO ' + ATable.TableName;
  LFields := '';
  for AFieldDB in AFields do
    if fpUpdate in AFieldDB.FieldIslemTipleri then
    begin
      if (AFieldDB.DataType = ftString)
      or (AFieldDB.DataType = ftWideString)
      or (AFieldDB.DataType = ftMemo)
      or (AFieldDB.DataType = ftWideMemo)
      or (AFieldDB.DataType = ftFmtMemo)
      or (AFieldDB.DataType = ftGuid)
      or (AFieldDB.DataType = ftFixedChar)
      or (AFieldDB.DataType = ftFixedWideChar)
      then
        LFields := LFields + AFieldDB.FieldName + '=' + QuotedStr(AFieldDB.AsString) + ','
      else
      if (AFieldDB.DataType = ftSmallint)
      or (AFieldDB.DataType = ftSmallint)
      or (AFieldDB.DataType = ftLargeint)
      or (AFieldDB.DataType = ftWord)
      or (AFieldDB.DataType = ftLongWord)
      or (AFieldDB.DataType = ftShortint)
      or (AFieldDB.DataType = ftByte)
      then
        LFields := LFields + AFieldDB.FieldName + '=' + AFieldDB.AsString + ','
      else if (AFieldDB.DataType = ftDate) then
        LFields := LFields + AFieldDB.FieldName + '=' + DateToStr(AFieldDB.AsDate) + ','
      else if (AFieldDB.DataType = ftTime) then
        LFields := LFields + AFieldDB.FieldName + '=' + TimeToStr(AFieldDB.AsTime) + ','
      else
      if (AFieldDB.DataType = ftDateTime)
      or (AFieldDB.DataType = ftTimeStamp)
      then
        LFields := LFields + AFieldDB.FieldName + '=' + DateTimeToStr(AFieldDB.AsDateTime) + ','
      else
      if (AFieldDB.DataType = ftFloat)
      or (AFieldDB.DataType = ftBCD)
      or (AFieldDB.DataType = ftFMTBcd)
      then
        LFields := LFields + AFieldDB.FieldName + '=' + FloatToStr(AFieldDB.AsFloat) + ','
    end;

  Result := 'UPDATE ' + ATable.TableName + ' SET ' + LeftStr(Trim(LFields), Length(LFields)-1) + ' WHERE id=' + ATable.Id.AsString + ';';
end;

function TEntityManager.PrepareDeleteQuery(ATable: TThsTable): string;
begin
  Result := 'DELETE FROM ' + ATable.TableName + ' WHERE id=' + ATable.Id.AsString + ';';
end;

procedure TEntityManager.StartTrans(AConnection: TZAbstractConnection);
var
  LConnection: TZAbstractConnection;
begin
  LConnection := Connection;
  if Assigned(AConnection) then
    LConnection := AConnection;
  if not LConnection.InTransaction then
    LConnection.StartTransaction;
end;

procedure TEntityManager.CommitTrans(AConnection: TZAbstractConnection);
var
  LConnection: TZAbstractConnection;
begin
  LConnection := Connection;
  if Assigned(AConnection) then
    LConnection := AConnection;
  if not LConnection.InTransaction then
    LConnection.StartTransaction;
end;

procedure TEntityManager.RollbackTrans(AConnection: TZAbstractConnection);
var
  LConnection: TZAbstractConnection;
begin
  LConnection := Connection;
  if Assigned(AConnection) then
    LConnection := AConnection;
  if not LConnection.InTransaction then
    LConnection.StartTransaction;
end;

function TEntityManager.GetToday: TDateTime;
var
  LQry: TZQuery;
begin
  Result := 0;
  LQry := Self.NewQuery;
  try
    LQry.Close;
    LQry.SQL.Text := 'SELECT CURRENT_DATE;';
    LQry.Open;
    while NOT LQry.EOF do
    begin
      Result := LQry.Fields.Fields[0].AsDateTime;
      LQry.Next;
    end;
  finally
    LQry.DisposeOf;
  end;
end;

end.
