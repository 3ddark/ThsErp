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
  SysMenu.Repository, SysMenu.Exception,
  SysAuditLog, SysAuditLog.Repository, SysAuditLog.Service, SysAuditLog.Exception,
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

// Menü ağacı (sys_menu): her ekranın Allowed bayrağı = kullanıcının etkin OKUMA yetkisi
// (super user hepsi; yetkisiz ekran herkese açık). Klasörler ekran açmaz.
procedure CheckMenu(const AStep: string; ASuperUser: Boolean);
var
  LSvc: TSysMenuService;
  LItems: TArray<TSysMenuItem>;
  LItem: TSysMenuItem;
  LFlags: string;
  LExpected: Boolean;
  LBad, LAllowed, LScreens: Integer;
begin
  LBad := 0;
  LAllowed := 0;
  LScreens := 0;
  try
    LSvc := TSysMenuService.Create;
    try
      LItems := LSvc.GetMenu;
    finally
      LSvc.Free;
    end;
    for LItem in LItems do
    begin
      if LItem.IsFolder then
      begin
        if (LItem.ActionName <> '') or (LItem.PermissionCode <> 0) then
        begin
          Inc(LBad);
          Report('FAIL', 'menu', '', AStep, Format('folder %d has action / permission', [LItem.MenuCode]));
        end;
        Continue;
      end;
      Inc(LScreens);
      if ASuperUser or (LItem.PermissionCode = 0) then
        LExpected := True
      else
        LExpected := GPermMap.TryGetValue(LItem.PermissionCode, LFlags) and (Copy(LFlags, 1, 1) = '1');
      if LItem.Allowed then
        Inc(LAllowed);
      if LItem.Allowed <> LExpected then
      begin
        Inc(LBad);
        Report('FAIL', 'menu', '', AStep, Format('%d %s permission %d: allowed=%s expected=%s',
          [LItem.MenuCode, LItem.ActionName, LItem.PermissionCode, BoolToStr(LItem.Allowed, True), BoolToStr(LExpected, True)]));
      end;
      if (LItem.MenuName = '') or (LItem.MenuName = LItem.MenuKey) then
      begin
        Inc(LBad);
        Report('FAIL', 'menu', '', AStep, Format('%d not translated (%s)', [LItem.MenuCode, LItem.MenuKey]));
      end;
    end;
    if LScreens = 0 then
      Report('FAIL', 'menu', '', AStep, 'no screens')
    else if LBad = 0 then
      Report('PASS', 'menu', '', AStep, Format('%d screens, %d allowed', [LScreens, LAllowed]));
  except
    on E: Exception do Report('FAIL', 'menu', '', AStep, E.ClassName + ': ' + E.Message);
  end;
end;

// Favori / son kullanılan: oturum kullanıcısına yazılır, GetMenu'da görünür (transaction + rollback)
procedure CheckMenuPrefs;
var
  LSvc: TSysMenuService;
  LBefore, LAfter: TSysMenuItem;
  LOwnFav: Boolean;

  function Find(const AItems: TArray<TSysMenuItem>; ACode: Integer): TSysMenuItem;
  begin
    Result := Default(TSysMenuItem);
    for var LItem in AItems do
      if LItem.MenuCode = ACode then
        Exit(LItem);
  end;

  procedure Check(ACondition: Boolean; const AStep, AMsg: string);
  begin
    if ACondition then
      Report('PASS', 'menu', '', AStep, AMsg)
    else
      Report('FAIL', 'menu', '', AStep, AMsg);
  end;

begin
  LSvc := TSysMenuService.Create;
  TUnitOfWork.Instance.BeginTransaction;
  try
    try
      LBefore := Find(LSvc.GetMenu, 300301);
      LSvc.SetFavorite(300301, True);
      LSvc.RegisterOpen(300301);
      LSvc.RegisterOpen(300301);
      LAfter := Find(LSvc.GetMenu, 300301);
      Check(LAfter.IsFavorite, 'favorite add', BoolToStr(LAfter.IsFavorite, True));
      Check(LAfter.OpenCount = LBefore.OpenCount + 2, 'open count', Format('%d -> %d', [LBefore.OpenCount, LAfter.OpenCount]));
      Check(LAfter.LastOpenedAt > 0, 'last opened', DateTimeToStr(LAfter.LastOpenedAt));
      LSvc.SetFavorite(300301, False);
      LAfter := Find(LSvc.GetMenu, 300301);
      Check(not LAfter.IsFavorite and (LAfter.OpenCount = LBefore.OpenCount + 2), 'favorite remove keeps count',
        Format('%s %d', [BoolToStr(LAfter.IsFavorite, True), LAfter.OpenCount]));
      try
        LSvc.SetFavorite(300300, True);
        Check(False, 'folder cannot be favorite', 'accepted');
      except
        on E: Exception do Check(True, 'folder cannot be favorite', E.Message);
      end;
      // başka kullanıcının tercihi görünmez
      LOwnFav := Find(LSvc.GetMenu, 400101).IsFavorite;
      TUnitOfWork.Instance.Connection.ExecSQL('INSERT INTO sys_user_menu (sys_user_id, sys_menu_id, is_favorite) SELECT 4, id, true FROM sys_menu ' +
        'WHERE menu_code = 400101 ON CONFLICT (sys_user_id, sys_menu_id) DO UPDATE SET is_favorite = true');
      LAfter := Find(LSvc.GetMenu, 400101);
      Check(LAfter.IsFavorite = LOwnFav, 'other user preference hidden',
        BoolToStr(LAfter.IsFavorite, True));
    except
      on E: Exception do Report('FAIL', 'menu', '', 'preferences', E.ClassName + ': ' + E.Message);
    end;
  finally
    if TUnitOfWork.Instance.InTransaction then
      TUnitOfWork.Instance.Rollback;
    LSvc.Free;
  end;
end;

// Menü bakım ekranı kuralları (servis, transaction + rollback)
procedure CheckMenuAdmin;
var
  LSvc: TSysMenuService;
  LMenu: TSysMenu;
  LNew: TSysMenu;
  LItems: TArray<TSysMenuItem>;
  LItem: TSysMenuItem;

  function Find(ACode: Integer): TSysMenuItem;
  begin
    Result := Default(TSysMenuItem);
    for var I in LItems do
      if I.MenuCode = ACode then
        Exit(I);
  end;

  function Load(ACode: Integer): TSysMenu;
  var
    LFilter: TFilterCriteria;
  begin
    LFilter := TFilterCriteria.Create;
    try
      LFilter.Add(TFilterCriterion.New('menu_code', '=', TValue.From<Integer>(ACode)));
      Result := LSvc.FindOne(LFilter, False);
    finally
      LFilter.Free;
    end;
  end;

  function Trans(AMenu: TSysMenu; const ALocale: string): TSysMenuTranslation;
  begin
    Result := nil;
    for var T in AMenu.Translations do
      if Assigned(T.SysLanguage) and SameText(T.SysLanguage.Locale, ALocale) then
        Exit(T);
  end;

  procedure Check(ACondition: Boolean; const AStep, AMsg: string);
  begin
    if ACondition then
      Report('PASS', 'menu', 'TSysMenu', AStep, AMsg)
    else
      Report('FAIL', 'menu', 'TSysMenu', AStep, AMsg);
  end;

  // AProc bir ESysMenuException alt sınıfı fırlatmalı
  procedure Expect(AClass: ExceptClass; const AStep: string; AProc: TProc);
  begin
    try
      AProc();
      Check(False, AStep, 'accepted');
    except
      on E: Exception do
        Check(E is AClass, AStep, E.ClassName + ': ' + E.Message);
    end;
    // servis hata alınca açık transaction'ı geri alır: sonraki adımlar yine rollback edilecek transaction'da
    if not TUnitOfWork.Instance.InTransaction then
      TUnitOfWork.Instance.BeginTransaction;
  end;

begin
  LSvc := TSysMenuService.Create;
  TUnitOfWork.Instance.BeginTransaction;
  try
    try
      // ad + anahtar kelime (tr-TR) -> ağaçta yeni ad ve kelime
      LMenu := Load(300301);
      try
        Trans(LMenu, 'tr-TR').MenuName := 'IT Müşteri Çekleri';
        Trans(LMenu, 'tr-TR').Keywords := 'itkelime çek';
        LSvc.BusinessUpdate(LMenu, False, False, False);
      finally
        LMenu.Free;
      end;
      LItems := LSvc.GetMenu;
      LItem := Find(300301);
      Check((LItem.MenuName = 'IT Müşteri Çekleri') and (Pos('itkelime', LItem.Keywords) > 0), 'update name + keywords',
        LItem.MenuName + ' / ' + LItem.Keywords);

      // değiştirilemez alanlar
      LMenu := Load(300301);
      try
        LMenu.MenuCode := 300309;
        Expect(ESysMenuExceptionImmutable, 'code immutable', procedure begin LSvc.BusinessUpdate(LMenu, False, False, False); end);
        LMenu.MenuCode := 300301;
        LMenu.ActionName := 'actfin_own_cheques_x';
        Expect(ESysMenuExceptionImmutable, 'action immutable', procedure begin LSvc.BusinessUpdate(LMenu, False, False, False); end);
        LMenu.ActionName := 'actfin_customer_cheques';
        Expect(ESysMenuExceptionNoDelete, 'delete refused', procedure begin LSvc.BusinessDelete(LMenu, False, False, False); end);
      finally
        LMenu.Free;
      end;

      // klasörü pasif yapmak: satır pasif (alt ekranlar ağaçta gizlenir, action kapanır)
      LMenu := Load(300300);
      try
        LMenu.IsActive := False;
        LSvc.BusinessUpdate(LMenu, False, False, False);
      finally
        LMenu.Free;
      end;
      LItems := LSvc.GetMenu;
      Check(not Find(300300).IsActive and not Find(300301).IsActive and Find(300201).IsActive, 'folder passive hides children',
        'effective flags');

      // boş ad -> çeviri silinir, görünüm anahtara düşer
      LMenu := Load(300302);
      try
        Trans(LMenu, 'tr-TR').MenuName := '';
        LSvc.BusinessUpdate(LMenu, False, False, False);
      finally
        LMenu.Free;
      end;
      LItems := LSvc.GetMenu;
      Check(Find(300302).MenuName = 'finance.own-cheques', 'empty name falls back to key', Find(300302).MenuName);

      // yeni satır kuralları
      LNew := TSysMenu.Create;
      try
        LNew.MenuCode := 300306;
        LNew.MenuKey := 'it.folder-with-action';
        LNew.ActionName := '';
        Expect(ESysMenuExceptionFolderRule, 'screen needs action', procedure begin LSvc.BusinessInsert(LNew, False, False, False); end);
        LNew.MenuCode := 300700;
        LNew.ActionName := 'act_it_x';
        Expect(ESysMenuExceptionFolderRule, 'folder has no action', procedure begin LSvc.BusinessInsert(LNew, False, False, False); end);
        LNew.MenuCode := 390101;
        Expect(ESysMenuExceptionParentMissing, 'parent missing', procedure begin LSvc.BusinessInsert(LNew, False, False, False); end);
        LNew.MenuCode := 12345;
        Expect(ESysMenuExceptionCodeRange, 'code range', procedure begin LSvc.BusinessInsert(LNew, False, False, False); end);
        LNew.MenuCode := 300306;
        LNew.ActionName := 'actfin_cheque_notes';
        Expect(ESysMenuExceptionActionUnique, 'action unique', procedure begin LSvc.BusinessInsert(LNew, False, False, False); end);
        LNew.ActionName := 'act_it_new_screen';
        LNew.MenuKey := 'finance.customer-cheques';
        Expect(ESysMenuExceptionKeyUnique, 'key unique', procedure begin LSvc.BusinessInsert(LNew, False, False, False); end);
        LNew.MenuKey := 'it.new-screen';
        LNew.Translations := TObjectList<TSysMenuTranslation>.Create(True);
        var T := TSysMenuTranslation.Create;
        T.SysLanguage := TSysLanguage.Create;
        T.SysLanguage.Locale := 'tr-TR';
        T.MenuName := 'IT Yeni Ekran';
        LNew.Translations.Add(T);
        LSvc.BusinessInsert(LNew, False, False, False);
        LItems := LSvc.GetMenu;
        Check((Find(300306).MenuName = 'IT Yeni Ekran') and (Find(300306).ParentCode = 300300), 'insert screen',
          Format('%s parent %d', [Find(300306).MenuName, Find(300306).ParentCode]));
      finally
        LNew.Free;
      end;
    except
      on E: Exception do Report('FAIL', 'menu', 'TSysMenu', 'admin', E.ClassName + ': ' + E.Message);
    end;
  finally
    if TUnitOfWork.Instance.InTransaction then
      TUnitOfWork.Instance.Rollback;
    LSvc.Free;
  end;
end;

// İşlem geçmişi: tetikleyici -> audit_outbox -> audit_flush() -> ths_audit (postgres_fdw). Transaction + rollback:
// yerel kuyruk ve uzak (ths_audit) satırlar birlikte geri alınır.
procedure CheckAuditLog;
var
  LAudit: TSysAuditLogService;
  LRegionSvc: TSysRegionService;
  LRegion: TSysRegion;
  LRepo: TSysAuditLogRepository;
  LRes: TAuditFlushResult;
  LList: TList<TSysAuditLog>;
  LFilter: TFilterCriteria;
  LRowId: Int64;
  LEntry: TSysAuditLog;
  LExpected: Boolean;
  LUserRepo: TSysUserRepository;

  procedure Check(ACondition: Boolean; const AStep, AMsg: string);
  begin
    if ACondition then
      Report('PASS', 'audit', 'TSysAuditLog', AStep, AMsg)
    else
      Report('FAIL', 'audit', 'TSysAuditLog', AStep, AMsg);
  end;

  function Scalar(const ASql: string): string;
  begin
    Result := VarToStr(TUnitOfWork.Instance.Connection.ExecSQLScalar(ASql));
  end;

  function OutboxRows: string;
  begin
    Result := Scalar(Format('SELECT string_agg(action || '':'' || COALESCE(app_user, ''-'') || '':'' || ' +
      'COALESCE((SELECT string_agg(k, '','' ORDER BY k) FROM jsonb_object_keys(COALESCE(new_data, old_data)) k), ''''), '' '' ORDER BY id) ' +
      'FROM audit_outbox WHERE table_name = ''sys_region'' AND row_id = %d', [LRowId]));
  end;

begin
  LAudit := TSysAuditLogService.Create;
  LRegionSvc := TSysRegionService.Create;
  LRepo := TSysAuditLogRepository(LAudit.UoW.GetRepository<TSysAuditLog, TSysAuditLogRepository>);
  LUserRepo := TSysUserRepository.Create(TUnitOfWork.Instance.Connection);
  LRowId := 0;
  try
    try
      Check(LAudit.IsAudited('sys_region') and not LAudit.IsAudited('stk_inventory') and not LAudit.IsAudited('audit_outbox'),
        'audited tables', 'sys_region yes, stk_inventory / audit_outbox no');
      Check(LAudit.DbFamily = Scalar('SELECT regexp_replace(current_database(), ''_?[0-9]{4}$'', '''')'), 'db family', LAudit.DbFamily);
      Check(LAudit.ActivePeriod = StrToIntDef(Scalar('SELECT active_period FROM sys_application_setting ORDER BY id LIMIT 1'), -1),
        'active period', IntToStr(LAudit.ActivePeriod));

      TUnitOfWork.Instance.BeginTransaction;
      LRes := LAudit.Flush;
      Check(LRes.Moved = 0, 'flush skipped in open transaction', IntToStr(LRes.Moved));

      LRegion := TSysRegion.Create;
      try
        LRegion.RegionName := 'IT AUDIT ' + FormatDateTime('hhnnsszzz', Now);
        LRegionSvc.BusinessInsert(LRegion, False, False, True);
        LRowId := LRegion.Id;
        LRegion.RegionName := LRegion.RegionName + ' 2';
        LRegionSvc.BusinessUpdate(LRegion, False, False, True);
        LRegionSvc.BusinessUpdate(LRegion, False, False, True);   // değişiklik yok -> satır yok
        LRegionSvc.BusinessDelete(LRegion, False, False, True);
      finally
        LRegion.Free;
      end;
      Check(OutboxRows = 'I:IT_TEST:id,region_name U:IT_TEST:region_name D:IT_TEST:id,region_name', 'outbox rows (I / U diff / D, no-op skipped)',
        OutboxRows);

      LRes := LRepo.Flush(2, 50);   // küçük paketler: döngü
      Check((LRes.Moved >= 3) and (LRes.ErrorMessage = ''), 'flush', Format('%d %s', [LRes.Moved, LRes.ErrorMessage]));
      Check(Scalar('SELECT count(*) FROM audit_outbox') = '0', 'outbox empty after flush', Scalar('SELECT count(*) FROM audit_outbox'));

      LFilter := TFilterCriteria.Create;
      try
        LFilter.Add(TFilterCriterion.New('db_family', '=', TValue.From<string>(LAudit.DbFamily)));
        LFilter.Add(TFilterCriterion.New('table_name', '=', TValue.From<string>('sys_region')));
        LFilter.Add(TFilterCriterion.New('record_no', '=', TValue.From<Int64>(LRowId)));
        LList := LAudit.BusinessFind(LFilter, False, False, True);
        try
          Check(LList.Count = 3, 'remote rows', IntToStr(LList.Count));
          if LList.Count = 3 then
          begin
            Check((LList[0].Action = 'I') and (LList[1].Action = 'U') and (LList[2].Action = 'D'), 'remote order',
              LList[0].Action + LList[1].Action + LList[2].Action);
            LEntry := LList[1];
            Check((LEntry.DbName = Scalar('SELECT current_database()')) and (LEntry.PeriodYear = LAudit.ActivePeriod)
              and (LEntry.AppUser = 'IT_TEST') and (LEntry.ChangedColumns = 'region_name')
              and (Pos(' 2"', LEntry.NewData) > 0) and (LEntry.OldData <> ''),
              'remote update row', Format('%s %d %s [%s] %s -> %s', [LEntry.DbName, LEntry.PeriodYear, LEntry.AppUser,
              LEntry.ChangedColumns, LEntry.OldData, LEntry.NewData]));
            Check((LList[0].OldData = '') and (LList[2].NewData = ''), 'insert / delete payload', 'I old empty, D new empty');
            Check(TSysAuditLog.ActionText('U') <> 'U', 'action text', TSysAuditLog.ActionText('U'));
            LEntry := LAudit.BusinessFindById(LList[2].Id, False, False, True);
            try
              Check(Assigned(LEntry) and (LEntry.Action = 'D') and (LEntry.RecordNo = LRowId), 'find by id', '');
            finally
              LEntry.Free;
            end;
          end;
        finally
          if not (LList is TObjectList<TSysAuditLog>) or not TObjectList<TSysAuditLog>(LList).OwnsObjects then
            for LEntry in LList do
              LEntry.Free;
          LList.Free;
        end;
      finally
        LFilter.Free;
      end;

      // yeniden aktarım (aynı kaynak satırı) uzakta çift kayıt üretmez
      TUnitOfWork.Instance.Connection.ExecSQL(Format('INSERT INTO audit_outbox (id, table_schema, table_name, row_id, action, changed_at, app_user, new_data) ' +
        'OVERRIDING SYSTEM VALUE ' +
        'SELECT source_id, table_schema, table_name, record_no, action, changed_at, app_user, new_data::jsonb ' +
        'FROM vw_sys_audit_log WHERE db_family = %s AND table_name = ''sys_region'' AND record_no = %d AND action = ''I''',
        [QuotedStr(LAudit.DbFamily), LRowId]));
      LRes := LRepo.Flush(100, 1);
      Check((LRes.Moved = 0) and (Scalar(Format('SELECT count(*) FROM vw_sys_audit_log WHERE db_family = %s AND table_name = ''sys_region'' AND record_no = %d',
        [QuotedStr(LAudit.DbFamily), LRowId])) = '3'), 'idempotent re-flush', IntToStr(LRes.Moved));

      try
        LEntry := TSysAuditLog.Create;
        try
          LAudit.BusinessInsert(LEntry, False, False, True);
        finally
          LEntry.Free;
        end;
        Check(False, 'read-only insert', 'accepted');
      except
        on E: ESysAuditLogExceptionReadOnly do Check(True, 'read-only insert', E.Message);
      end;
    except
      on E: Exception do Report('FAIL', 'audit', 'TSysAuditLog', 'flow', E.ClassName + ': ' + E.Message);
    end;
  finally
    if TUnitOfWork.Instance.InTransaction then
      TUnitOfWork.Instance.Rollback;
  end;

  try
    // rollback uzak satırları da geri aldı (postgres_fdw uzak transaction'ı yerel ile biter)
    if LRowId > 0 then
      Check(Scalar(Format('SELECT count(*) FROM vw_sys_audit_log WHERE table_name = ''sys_region'' AND record_no = %d', [LRowId])) = '0',
        'remote rolled back with local transaction', '');

    // yetki: TEST kullanıcısının okuma hakkı = etkin yetki görünümü
    TAppContext.Instance.CurrentUser.User := LUserRepo.FindById(TValue.From<Int64>(4), False);
    LExpected := Scalar('SELECT COALESCE(bool_or(is_read), false)::int FROM vw_sys_user_effective_permission WHERE sys_user_id = 4 AND permission_code = 1112') = '1';
    Check(LAudit.IsAuthorized(ptRead, True) = LExpected, 'TEST user read = effective permission', BoolToStr(LExpected, True));
    try
      LList := LAudit.BusinessFind(nil, False, False, True);
      LList.Free;
      Check(LExpected, 'TEST user list', 'allowed');
    except
      on E: Exception do Check(not LExpected, 'TEST user list', E.ClassName);
    end;
  finally
    TAppContext.Instance.CurrentUser.User := LUserRepo.FindById(TValue.From<Int64>(1), False);
    LUserRepo.Free;
    LRegionSvc.Free;
    LAudit.Free;
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
      GConn := TConnectionManager.Instance.GetConnection(ContextMain, '127.0.0.1', 'ths_erp', 'postgres', 'qwe', {{PORT}});
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
        CheckMenu('super user', True);
        CheckMenuPrefs;
        CheckMenuAdmin;
        // non super user (TEST, id 4)
        Ctx.User := URepo.FindById(TValue.From<Int64>(4), False);
        LoadPermMap(4);
        CheckMenu('TEST user', False);
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
          CheckMenu('TEST user, templates + overrides', False);
          GSkipDenied := True;
          RunPerm;
          GSkipDenied := False;
        finally
          Ctx.User := URepo.FindById(TValue.From<Int64>(1), False);
          if TUnitOfWork.Instance.InTransaction then
            TUnitOfWork.Instance.Rollback;
        end;
      end;

      if (Mode = '') or (Mode = 'specific') or (Mode = 'audit') then
        CheckAuditLog;

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
