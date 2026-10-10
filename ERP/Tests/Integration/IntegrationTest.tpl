program IntegrationTest;

{$APPTYPE CONSOLE}

uses
  System.SysUtils, System.Classes, System.Rtti, System.TypInfo, System.Math, System.Variants, System.StrUtils,
  System.Generics.Collections, Winapi.Windows, Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Param,
  ConnectionManager, UnitOfWork, AppContext, UserContext, LocalizationManager, Entity,
  EntityAttributes, EntitySchemaCache, Service, SharedFormTypes, FilterCriterion,
  Ths.Language.Cache, SysGridColumn.Cache, SysUser, SysUser.Repository, Logger,
  ItSpecific in 'ItSpecific.pas',
  ItModules in 'ItModules.pas',
  {{UNITS}};

type
  TTester<T: TEntity, constructor> = class
  private
    class var FModule, FEntity: string;
    class procedure R(const AKind, AStep, AMsg: string);
    class function CloneOf(AEntity: T): T;
    class function Diff(A, B: T; AAllProps, ASkipId: Boolean): string;
    class procedure Mutate(AEntity: T; ASalt: Integer);
    class procedure FreeList(L: TList<T>);
    class function DupIds(L: TList<T>): Integer;
  public
    class procedure Run(const AModule, AEntity: string; ASvc: TCrudService<T>);
    class procedure Perm(const AModule, AEntity: string; ASvc: TCrudService<T>; AExpected: TDictionary<Integer, string>);
  end;

var
  GFilterModule, GFilterEntity: string;
  GPermMap: TDictionary<Integer, string>;
  GSkipDenied: Boolean;

function Want(const AModule, AEntity: string): Boolean;
begin
  Result := ((GFilterModule = '') or (GFilterModule = '*') or SameText(GFilterModule, AModule)) and
            ((GFilterEntity = '') or (GFilterEntity = '*') or SameText(GFilterEntity, AEntity));
end;

function ValStr(const V: TValue): string;
var
  i: Integer;
begin
  if V.IsEmpty then
    Exit('<empty>');
  case V.Kind of
    tkFloat: Result := FloatToStr(V.AsExtended);
    tkDynArray:
      begin
        Result := Format('arr[%d]', [V.GetArrayLength]);
        for i := 0 to Min(V.GetArrayLength, 4096) - 1 do
          Result := Result + IntToHex(V.GetArrayElement(i).AsOrdinal, 2);
      end;
  else
    Result := V.ToString;
  end;
end;

function ValEq(const A, B: TValue): Boolean;
begin
  if (A.Kind = tkFloat) and (B.Kind = tkFloat) and not A.IsEmpty and not B.IsEmpty then
    Exit(SameValue(A.AsExtended, B.AsExtended, 1E-6));
  Result := ValStr(A) = ValStr(B);
end;

{ TTester<T> }

class procedure TTester<T>.R(const AKind, AStep, AMsg: string);
begin
  Report(AKind, FModule, FEntity, AStep, AMsg);
end;

class function TTester<T>.CloneOf(AEntity: T): T;
var
  Ctx: TRttiContext;
  M: TRttiMethod;
begin
  M := Ctx.GetType(TClass(T)).GetMethod('Clone');
  if M = nil then
    raise Exception.Create('Clone method not found');
  Result := T(M.Invoke(TObject(AEntity), []).AsObject);
end;

class function TTester<T>.Diff(A, B: T; AAllProps, ASkipId: Boolean): string;
var
  Ctx: TRttiContext;
  P: TRttiProperty;
  Col: TColumnSchema;
  Schema: TEntitySchema;
  VA, VB: TValue;
begin
  Result := '';
  if AAllProps then
  begin
    for P in Ctx.GetType(TClass(T)).GetProperties do
    begin
      if not P.IsReadable then Continue;
      if P.PropertyType = nil then Continue;
      if P.PropertyType.TypeKind in [tkClass, tkInterface, tkMethod, tkPointer, tkProcedure, tkRecord, tkMRecord] then Continue;
      if P.Visibility in [mvPrivate, mvProtected] then Continue;
      if ASkipId and SameText(P.Name, 'Id') then Continue;
      if SameText(P.Name, 'RefCount') then Continue;
      // stok kartı resmi yalnız FindById'de yüklenir (tasarım gereği)
      if SameText(P.Name, 'ImageLoaded') or SameText(P.Name, 'Image') then Continue;
      try
        VA := P.GetValue(TObject(A));
        VB := P.GetValue(TObject(B));
      except
        Continue;
      end;
      if not ValEq(VA, VB) then
        Result := Result + Format('%s: [%s] <> [%s]; ', [P.Name, Copy(ValStr(VA), 1, 60), Copy(ValStr(VB), 1, 60)]);
    end;
  end
  else
  begin
    Schema := TEntitySchemaCache.GetSchema(TClass(T));
    for Col in Schema.Columns do
    begin
      if ASkipId and Col.IsPrimaryKey then Continue;
      VA := Col.Prop.GetValue(TObject(A));
      VB := Col.Prop.GetValue(TObject(B));
      if not ValEq(VA, VB) then
        Result := Result + Format('%s: [%s] <> [%s]; ', [Col.ColumnName, Copy(ValStr(VA), 1, 60), Copy(ValStr(VB), 1, 60)]);
    end;
  end;
end;

class procedure TTester<T>.Mutate(AEntity: T; ASalt: Integer);
var
  Schema: TEntitySchema;
  Col: TColumnSchema;
  S: string;
  MaxLen: Integer;
  Attr: TCustomAttribute;
begin
  Schema := TEntitySchemaCache.GetSchema(TClass(T));
  for Col in Schema.Columns do
  begin
    if Col.IsPrimaryKey or not Col.IsWritable then Continue;
    if not (Col.TypeKind in [tkUString, tkString, tkLString, tkWString]) then Continue;
    if SameText(Col.ColumnName, 'locale') or Col.ColumnName.Contains('currency') then Continue;
    if Col.ColumnName.EndsWith('_account') then Continue;  // acc_account(code) FK
    S := Col.Prop.GetValue(TObject(AEntity)).AsString;
    if S = '' then Continue;
    MaxLen := 1000;
    for Attr in Col.Prop.GetAttributes do
      if Attr is MaxLength then
        MaxLen := MaxLength(Attr).MaxLength;
    if Col.ColumnName.EndsWith('code') then
      S := S + IntToStr(ASalt)
    else
      S := 'IT' + IntToStr(ASalt) + S;
    if Length(S) > MaxLen then
      S := Copy(S, Length(S) - MaxLen + 1, MaxLen);
    Col.Prop.SetValue(TObject(AEntity), S);
  end;
end;

class procedure TTester<T>.FreeList(L: TList<T>);
var
  X: T;
begin
  if L = nil then Exit;
  if not (L is TObjectList<T>) or not TObjectList<T>(L).OwnsObjects then
    for X in L do
      X.Free;
  L.Free;
end;

class function TTester<T>.DupIds(L: TList<T>): Integer;
var
  D: TDictionary<Int64, Byte>;
  X: T;
begin
  Result := 0;
  D := TDictionary<Int64, Byte>.Create;
  try
    for X in L do
      if D.ContainsKey(X.Id) then
        Inc(Result)
      else
        D.Add(X.Id, 0);
  finally
    D.Free;
  end;
end;

procedure SafeRollback;
begin
  if TUnitOfWork.Instance.InTransaction then
    TUnitOfWork.Instance.Rollback;
end;

class procedure TTester<T>.Run(const AModule, AEntity: string; ASvc: TCrudService<T>);
const
  Locales: array[0..2] of string = ('tr-TR', 'en-US', 'de-DE');
var
  Q: TFDQuery;
  L: TList<T>;
  E, E2, C, X, N, RB: T;
  Ids: TList<Int64>;
  Dup, GridCount, i: Integer;
  Loc, D: string;
  IdSet: TDictionary<Int64, Byte>;
  NewId: Int64;
  UoW: TUnitOfWork;
begin
  FModule := AModule;
  FEntity := AEntity;
  UoW := TUnitOfWork.Instance;
  Ids := TList<Int64>.Create;
  try
    if ASvc.PermissionCode <= 2 then
      R('FAIL', 'permission code', Format('PermissionCode = %d (placeholder)', [ASvc.PermissionCode]));

    GridCount := -1;
    // 1) grid + find in every locale
    for Loc in Locales do
    begin
      TAppContext.Instance.CurrentUser.ActiveLanguage := Loc;
      try
        Q := ASvc.CreateQueryForUI(nil);
        try
          Q.Open;
          Dup := 0;
          IdSet := TDictionary<Int64, Byte>.Create;
          try
            if Q.FindField('id') <> nil then
              while not Q.Eof do
              begin
                if IdSet.ContainsKey(Q.FieldByName('id').AsLargeInt) then Inc(Dup)
                else IdSet.Add(Q.FieldByName('id').AsLargeInt, 0);
                Q.Next;
              end
            else
              R('WARN', 'grid ' + Loc, 'no id column in grid query');
          finally
            IdSet.Free;
          end;
          if Dup > 0 then
            R('FAIL', 'grid ' + Loc, Format('%d rows, %d duplicate ids', [Q.RecordCount, Dup]))
          else
            R('PASS', 'grid ' + Loc, Format('%d rows', [Q.RecordCount]));
          if Loc = 'tr-TR' then
            GridCount := Q.RecordCount;
        finally
          Q.Free;
        end;
      except
        on Ex: Exception do R('FAIL', 'grid ' + Loc, Ex.ClassName + ': ' + Ex.Message);
      end;

      try
        L := ASvc.BusinessFind(nil, False, False, True);
        try
          Dup := DupIds(L);
          if Dup > 0 then
            R('FAIL', 'find ' + Loc, Format('%d rows, %d duplicate ids', [L.Count, Dup]))
          else if (Loc = 'tr-TR') and (GridCount >= 0) and (GridCount <> L.Count) then
            R('WARN', 'find ' + Loc, Format('find %d rows <> grid %d rows', [L.Count, GridCount]))
          else
            R('PASS', 'find ' + Loc, Format('%d rows', [L.Count]));
          if Loc = 'tr-TR' then
            for i := 0 to Min(L.Count, 3) - 1 do
              Ids.Add(L[i].Id);

          // FindById must equal Find row
          if Loc = 'tr-TR' then
            for i := 0 to Min(L.Count, 3) - 1 do
            begin
              E := ASvc.BusinessFindById(L[i].Id, False, False, True);
              try
                if E = nil then
                  R('FAIL', 'findbyid', Format('id %d not found', [L[i].Id]))
                else
                begin
                  D := Diff(L[i], E, True, False);
                  if D <> '' then R('FAIL', 'findbyid=find', Format('id %d: %s', [L[i].Id, D]))
                  else R('PASS', 'findbyid=find', Format('id %d', [L[i].Id]));
                end;
              finally
                E.Free;
              end;
            end;
        finally
          FreeList(L);
        end;
      except
        on Ex: Exception do R('FAIL', 'find ' + Loc, Ex.ClassName + ': ' + Ex.Message);
      end;
    end;
    TAppContext.Instance.CurrentUser.ActiveLanguage := 'tr-TR';

    if Ids.Count = 0 then
    begin
      R('WARN', 'data', 'table empty - write tests skipped');
      Exit;
    end;
    if MatchText(AEntity, ['TSysViewTable', 'TStkInventorySummary']) then
    begin
      R('INFO', 'write', 'read-only entity - write tests skipped');
      Exit;
    end;

    for i := 0 to Ids.Count - 1 do
    begin
      // 2) Clone completeness + Clone must not modify Self
      try
        E := ASvc.FindById(Ids[i], False);
        E2 := ASvc.FindById(Ids[i], False);
        C := nil;
        try
          C := CloneOf(E);
          D := Diff(E, C, True, False);
          if D <> '' then R('FAIL', 'clone', Format('id %d: %s', [Ids[i], D]))
          else R('PASS', 'clone', Format('id %d', [Ids[i]]));
          D := Diff(E, E2, True, False);
          if D <> '' then R('FAIL', 'clone keeps self', D);
        finally
          C.Free;
          E.Free;
          E2.Free;
        end;
      except
        on Ex: Exception do R('FAIL', 'clone', Ex.ClassName + ': ' + Ex.Message);
      end;

      // 3) review -> lock -> update with same values -> reload equal
      try
        UoW.BeginTransaction;
        try
          X := ASvc.BusinessFindById(Ids[i], False, True, True);
          try
            if X = nil then
              R('FAIL', 'lock', Format('id %d not found with lock', [Ids[i]]))
            else
            begin
              ASvc.BusinessUpdate(X, False, False, True);
              RB := ASvc.FindById(Ids[i], False);
              try
                D := Diff(X, RB, False, False);
                if D <> '' then R('FAIL', 'update roundtrip', Format('id %d: %s', [Ids[i], D]))
                else R('PASS', 'update roundtrip', Format('id %d', [Ids[i]]));
              finally
                RB.Free;
              end;
            end;
          finally
            X.Free;
          end;
        finally
          SafeRollback;
        end;
      except
        on Ex: Exception do R('FAIL', 'update roundtrip', Format('id %d: %s: %s', [Ids[i], Ex.ClassName, Ex.Message]));
      end;
    end;

    // 4) duplicate insert (unique rules)
    E := ASvc.FindById(Ids[0], False);
    try
      try
        UoW.BeginTransaction;
        try
          N := CloneOf(E);
          try
            N.Id := 0;
            ASvc.BusinessInsert(N, False, False, True);
            R('INFO', 'insert duplicate', 'accepted (no unique rule)');
          finally
            N.Free;
          end;
        finally
          SafeRollback;
        end;
      except
        on Ex: Exception do R('INFO', 'insert duplicate', 'rejected: ' + Ex.ClassName + ': ' + Ex.Message);
      end;

      // 5) insert (mutated) -> reload equal -> update -> delete -> gone
      NewId := 0;
      try
        UoW.BeginTransaction;
        try
          N := CloneOf(E);
          try
            N.Id := 0;
            Mutate(N, 7);
            ASvc.BusinessInsert(N, False, False, True);
            NewId := N.Id;
            if NewId <= 0 then
              R('FAIL', 'insert', 'id not returned')
            else
            begin
              RB := ASvc.FindById(NewId, False);
              try
                if RB = nil then
                  R('FAIL', 'insert', 'inserted row not found by id (locale/view?)')
                else
                begin
                  D := Diff(N, RB, False, True);
                  if D <> '' then R('FAIL', 'insert roundtrip', D)
                  else R('PASS', 'insert roundtrip', Format('new id %d', [NewId]));
                  ASvc.BusinessUpdate(RB, False, False, True);
                  R('PASS', 'update new', '');
                  ASvc.BusinessDelete(RB, False, False, True);
                  X := ASvc.FindById(NewId, False);
                  if X <> nil then
                  begin
                    R('FAIL', 'delete', 'row still exists');
                    X.Free;
                  end
                  else
                    R('PASS', 'delete', '');
                end;
              finally
                RB.Free;
              end;
            end;
          finally
            N.Free;
          end;
        finally
          SafeRollback;
        end;
      except
        on Ex: Exception do
          // ham DB/FireDAC hatası = gerçek hata; uygulama istisnası = iş kuralı reddi (ör. tek kayıt, unique FK çifti)
          if Ex.ClassName.StartsWith('EPg') or Ex.ClassName.StartsWith('EFD') or (NewId > 0) then
            R('FAIL', 'insert/update/delete', Format('newid %d: %s: %s', [NewId, Ex.ClassName, Ex.Message]))
          else
            R('INFO', 'insert/update/delete', 'blocked by business rule: ' + Ex.Message);
      end;
    finally
      E.Free;
    end;
  finally
    SafeRollback;
    Ids.Free;
    ASvc.Free;
  end;
end;

class procedure TTester<T>.Perm(const AModule, AEntity: string; ASvc: TCrudService<T>; AExpected: TDictionary<Integer, string>);
const
  Types: array[0..4] of TPermissionType = (ptRead, ptAddRecord, ptUpdate, ptDelete, ptSpecial);
var
  Exp, Got: string;
  i: Integer;
  L: TList<T>;
begin
  FModule := AModule;
  FEntity := AEntity;
  try
    try
      if not AExpected.TryGetValue(ASvc.PermissionCode, Exp) then
        Exp := '00000';
      Got := '';
      for i := 0 to 4 do
        Got := Got + IfThen(ASvc.IsAuthorized(Types[i], True), '1', '0');
      if Got <> Exp then
        R('FAIL', 'perm', Format('code %d: service %s <> view %s', [ASvc.PermissionCode, Got, Exp]))
      else
        R('PASS', 'perm', Format('code %d: %s', [ASvc.PermissionCode, Got]));

      // read without right must raise
      if (Got[1] = '0') and not GSkipDenied then
      begin
        try
          L := ASvc.BusinessFind(nil, False, False, True);
          FreeList(L);
          R('FAIL', 'perm read denied', 'BusinessFind did not raise');
        except
          on Ex: Exception do R('PASS', 'perm read denied', Ex.ClassName);
        end;
      end;
    except
      on Ex: Exception do R('FAIL', 'perm', Ex.ClassName + ': ' + Ex.Message);
    end;
  finally
    ASvc.Free;
  end;
end;

procedure LoadPermMap(AUserId: Int64);
var
  Q: TFDQuery;
begin
  GPermMap.Clear;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := TUnitOfWork.Instance.Connection;
    Q.SQL.Text := 'SELECT permission_code, is_read, is_add, is_update, is_delete, is_special ' +
                  'FROM vw_sys_user_effective_permission WHERE sys_user_id = :u';
    Q.ParamByName('u').AsLargeInt := AUserId;
    Q.Open;
    while not Q.Eof do
    begin
      GPermMap.AddOrSetValue(Q.Fields[0].AsInteger,
        IfThen(Q.Fields[1].AsBoolean, '1', '0') + IfThen(Q.Fields[2].AsBoolean, '1', '0') +
        IfThen(Q.Fields[3].AsBoolean, '1', '0') + IfThen(Q.Fields[4].AsBoolean, '1', '0') +
        IfThen(Q.Fields[5].AsBoolean, '1', '0'));
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

procedure RunGeneric;
begin
{{CALLS}}
end;

procedure RunPerm;
begin
{{PERMCALLS}}
end;

var
  GConn: TFDConnection;
  Ctx: TUserContext;
  URepo: TSysUserRepository;
  Mode: string;
begin
  Mode := ParamStr(1);
  GFilterModule := ParamStr(2);
  GFilterEntity := ParamStr(3);
  OpenReport(ChangeFileExt(ParamStr(0), '-' + IfThen(Mode = '', 'all', Mode) + '.txt'));
  GPermMap := TDictionary<Integer, string>.Create;
  try
    try
      TLocalizationManager.SetLanguage('tr-TR');
      GConn := TConnectionManager.Instance.GetConnection(ContextMain, '127.0.0.1', 'ths_erp', 'postgres', 'qwe', 5432);
      TUnitOfWork.Initialize(GConn);
      TLanguageCache.Load;
      TSysGridColumnCache.LoadGlobal(GConn);
      GConn.ExecSQLScalar('SELECT set_config(''ths_erp.user_name'', :uname, false)', ['IT_TEST']);
      TAppContext.Initialize(GConn);
      Ctx := TUserContext.Create(nil, True);
      Ctx.ActiveLanguage := 'tr-TR';
      TAppContext.Instance.SetCurrentUser(Ctx);
      URepo := TSysUserRepository.Create(GConn);
      Ctx.User := URepo.FindById(TValue.From<Int64>(1), False);
      TSysGridColumnCache.LoadUser(GConn, 1);

      if (Mode = '') or (Mode = 'generic') then
        RunGeneric;

      if (Mode = '') or (Mode = 'perm') then
      begin
        // non super user (TEST, id 4)
        Ctx.User := URepo.FindById(TValue.From<Int64>(4), False);
        LoadPermMap(4);
        RunPerm;
        Ctx.User := URepo.FindById(TValue.From<Int64>(1), False);
      end;

      if (Mode = '') or (Mode = 'perm2') then
      begin
        // şablon + override senaryosu (rollback)
        TUnitOfWork.Instance.BeginTransaction;
        try
          GConn.ExecSQL('INSERT INTO sys_user_permission_template (sys_user_id, sys_permission_template_id) ' +
            'SELECT 4, id FROM sys_permission_template WHERE template_key IN (''sales'', ''production'')');
          GConn.ExecSQL('UPDATE sys_access_right a SET is_add = true, is_delete = true FROM sys_permission p ' +
            'WHERE p.id = a.sys_permission_id AND a.sys_user_id = 4 AND p.permission_code IN (1001, 1031)');
          GConn.ExecSQL('UPDATE sys_access_right a SET deny_read = true, deny_update = true FROM sys_permission p ' +
            'WHERE p.id = a.sys_permission_id AND a.sys_user_id = 4 AND p.permission_code IN (1041, 1061)');
          Report('INFO', 'perm2', '', 'setup', VarToStr(GConn.ExecSQLScalar('SELECT string_agg(template_key, '','') FROM sys_permission_template t ' +
            'JOIN sys_user_permission_template u ON u.sys_permission_template_id = t.id WHERE u.sys_user_id = 4')));
          Ctx.User := URepo.FindById(TValue.From<Int64>(4), False);
          LoadPermMap(4);
          GSkipDenied := True;
          RunPerm;
          GSkipDenied := False;
        finally
          Ctx.User := URepo.FindById(TValue.From<Int64>(1), False);
          if TUnitOfWork.Instance.InTransaction then
            TUnitOfWork.Instance.Rollback;
        end;
      end;

      if (Mode = '') or (Mode = 'specific') then
        RunSpecific(URepo);
    except
      on E: Exception do Report('FAIL', 'main', '', 'fatal', E.ClassName + ': ' + E.Message);
    end;
    if TUnitOfWork.Instance.InTransaction then
      TUnitOfWork.Instance.Rollback;
    Report('SUM', '', '', '', Format('pass=%d fail=%d warn=%d', [GPass, GFail, GWarn]));
  finally
    GPermMap.Free;
    CloseReport;
  end;
  // singleton finalization sırası (UnitOfWork / AppContext / ConnectionManager) çıkışta AV veriyor -> doğrudan çık
  ExitProcess(Ord(GFail > 0));
end.
