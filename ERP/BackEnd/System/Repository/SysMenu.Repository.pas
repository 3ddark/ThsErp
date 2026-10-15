unit SysMenu.Repository;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Classes, System.Generics.Collections, System.Rtti, Data.DB,
  FireDAC.Comp.Client, FireDAC.Stan.Param,
  Entity, Repository, FilterCriterion, AppContext, Logger,
  SysMenu, SysLanguage;

type
  // sys_menu: bakım ekranı (CRUD, okuma vw_sys_menu locale'li) + menü ağacı okuması + kullanıcının menü tercihleri (sys_user_menu)
  TSysMenuRepository = class(TRepository<TSysMenu>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;
    procedure SetInsertParams(Q: TFDQuery; AModel: TSysMenu; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TSysMenu; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TSysMenu; override;
    procedure LoadTranslations(AModel: TSysMenu);
    procedure SaveTranslations(AModel: TSysMenu);

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;
    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TSysMenu>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TSysMenu; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TSysMenu; override;
    procedure DoAdd(AModel: TSysMenu); override;
    procedure DoAddBatch(AModels: TArray<TSysMenu>); override;
    procedure DoUpdate(AModel: TSysMenu); override;
    procedure DoUpdateBatch(AModels: TArray<TSysMenu>); override;
    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TSysMenu); override;
    procedure DoDeleteBatch(AModels: TArray<TSysMenu>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);

    // Menü ağacı: tüm satırlar (pasifler dahil, IsActive), kod sırasıyla; AUserId'nin favori / son açılma bilgisiyle
    function GetItems(const ALocale: string; AUserId: Int64): TArray<TSysMenuItem>;
    // Ekran satırı yoksa 0
    function GetScreenId(AMenuCode: Integer): Int64;
    procedure SetFavorite(AUserId, AMenuId: Int64; AValue: Boolean);
    procedure RegisterOpen(AUserId, AMenuId: Int64);
  end;

implementation

uses
  Ths.Language.Cache;

constructor TSysMenuRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSysMenuRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TSysMenu) +
            ' (menu_code, menu_key, action_name, sys_permission_id, is_active) ' +
            ' VALUES (:menu_code, :menu_key, :action_name, :sys_permission_id, :is_active)';
end;

function TSysMenuRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TSysMenu) +
            ' SET menu_code = :menu_code, menu_key = :menu_key, action_name = :action_name, ' +
            '     sys_permission_id = :sys_permission_id, is_active = :is_active WHERE id = :id';
end;

function TSysMenuRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TSysMenu) + ' WHERE';
end;

procedure TSysMenuRepository.SetInsertParams(Q: TFDQuery; AModel: TSysMenu; AIndex: Integer);
begin
  Q.ParamByName('menu_key').DataType := ftWideString;
  Q.ParamByName('action_name').DataType := ftWideString;
  if AIndex < 0 then
  begin
    Q.ParamByName('menu_code').AsInteger := AModel.MenuCode;
    Q.ParamByName('menu_key').AsWideString := AModel.MenuKey;
    Q.ParamByName('action_name').AsWideString := AModel.ActionName;
    Q.ParamByName('is_active').AsBoolean := AModel.IsActive;
  end
  else
  begin
    Q.ParamByName('menu_code').AsIntegers[AIndex] := AModel.MenuCode;
    Q.ParamByName('menu_key').AsWideStrings[AIndex] := AModel.MenuKey;
    Q.ParamByName('action_name').AsWideStrings[AIndex] := AModel.ActionName;
    Q.ParamByName('is_active').AsBooleans[AIndex] := AModel.IsActive;
  end;
  SetNullableParam(Q.ParamByName('sys_permission_id'), ftLargeint, AModel.SysPermissionId, AIndex);
end;

procedure TSysMenuRepository.SetUpdateParams(Q: TFDQuery; AModel: TSysMenu; AIndex: Integer);
begin
  SetInsertParams(Q, AModel, AIndex);
  if AIndex < 0 then
    Q.ParamByName('id').AsLargeInt := AModel.Id
  else
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
end;

function TSysMenuRepository.MapFromQuery(Q: TFDQuery): TSysMenu;
begin
  Result := TSysMenu.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.MenuCode := Q.FieldByName('menu_code').AsInteger;
  Result.MenuKey := Q.FieldByName('menu_key').AsWideString;
  Result.ActionName := Q.FieldByName('action_name').AsWideString;
  Result.SysPermissionId := Q.FieldByName('sys_permission_id').AsLargeInt;
  Result.IsActive := Q.FieldByName('is_active').AsBoolean;
  Result.ParentCode := Q.FieldByName('parent_code').AsInteger;
  if Assigned(Q.FindField('permission_code')) then
    Result.PermissionCode := Q.FieldByName('permission_code').AsInteger;
  if Assigned(Q.FindField('permission_name')) then
    Result.PermissionName := Q.FieldByName('permission_name').AsWideString;
  if Assigned(Q.FindField('menu_name')) then
    Result.MenuName := Q.FieldByName('menu_name').AsWideString;
  if Assigned(Q.FindField('parent_path')) then
    Result.ParentPath := Q.FieldByName('parent_path').AsWideString;
end;

procedure TSysMenuRepository.LoadTranslations(AModel: TSysMenu);
var
  Q: TFDQuery;
  LTrans: TSysMenuTranslation;
begin
  if AModel = nil then
    Exit;
  if Assigned(AModel.Translations) then
    AModel.Translations.Clear
  else
    AModel.Translations := TObjectList<TSysMenuTranslation>.Create(True);

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text :=
      'SELECT t.sys_menu_id, t.sys_language_id, t.menu_name, t.keywords, l.locale, l.native_name ' +
      '  FROM public.sys_menu_translation t ' +
      '  LEFT JOIN public.sys_language l ON l.id = t.sys_language_id ' +
      ' WHERE t.sys_menu_id = :sys_menu_id';
    Q.ParamByName('sys_menu_id').AsLargeInt := AModel.Id;
    LogQuery(Q, 'LoadTranslations');
    Q.Open;
    while not Q.Eof do
    begin
      LTrans := TSysMenuTranslation.Create;
      LTrans.SysMenuId := Q.FieldByName('sys_menu_id').AsLargeInt;
      LTrans.SysLanguageId := Q.FieldByName('sys_language_id').AsLargeInt;
      LTrans.MenuName := Q.FieldByName('menu_name').AsWideString;
      LTrans.Keywords := Q.FieldByName('keywords').AsWideString;
      LTrans.SysLanguage := TSysLanguage.Create;
      LTrans.SysLanguage.Id := LTrans.SysLanguageId;
      LTrans.SysLanguage.Locale := Q.FieldByName('locale').AsWideString;
      LTrans.SysLanguage.NativeName := Q.FieldByName('native_name').AsWideString;
      AModel.Translations.Add(LTrans);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

// Adı boş bırakılan dilin çeviri satırı silinir (görünümde menu_key'e düşer)
procedure TSysMenuRepository.SaveTranslations(AModel: TSysMenu);
var
  Q, D: TFDQuery;
  LTrans: TSysMenuTranslation;
begin
  if (AModel = nil) or (AModel.Translations = nil) or (AModel.Translations.Count = 0) then
    Exit;

  Q := TFDQuery.Create(nil);
  D := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text :=
      'INSERT INTO public.sys_menu_translation (sys_menu_id, sys_language_id, menu_name, keywords) ' +
      ' VALUES (:sys_menu_id, :sys_language_id, :menu_name, :keywords) ' +
      ' ON CONFLICT (sys_menu_id, sys_language_id) DO UPDATE ' +
      ' SET menu_name = EXCLUDED.menu_name, keywords = EXCLUDED.keywords';
    D.Connection := Connection;
    D.SQL.Text := 'DELETE FROM public.sys_menu_translation WHERE sys_menu_id = :sys_menu_id AND sys_language_id = :sys_language_id';

    for LTrans in AModel.Translations do
    begin
      if (LTrans.SysLanguageId = 0) and Assigned(LTrans.SysLanguage) and (LTrans.SysLanguage.Locale <> '') then
        LTrans.SysLanguageId := TLanguageCache.GetIdByLocale(LTrans.SysLanguage.Locale);
      if LTrans.SysLanguageId = 0 then
      begin
        GLogger.Warning('SysMenu.SaveTranslations: locale could not be resolved');
        Continue;
      end;
      LTrans.SysMenuId := AModel.Id;

      if Trim(LTrans.MenuName) = '' then
      begin
        D.ParamByName('sys_menu_id').AsLargeInt := LTrans.SysMenuId;
        D.ParamByName('sys_language_id').AsLargeInt := LTrans.SysLanguageId;
        LogQuery(D, 'SaveTranslations');
        D.ExecSQL;
        Continue;
      end;

      Q.ParamByName('sys_menu_id').AsLargeInt := LTrans.SysMenuId;
      Q.ParamByName('sys_language_id').AsLargeInt := LTrans.SysLanguageId;
      Q.ParamByName('menu_name').DataType := ftWideString;
      Q.ParamByName('menu_name').AsWideString := Trim(LTrans.MenuName);
      Q.ParamByName('keywords').DataType := ftWideString;
      if Trim(LTrans.Keywords) = '' then
        Q.ParamByName('keywords').Clear
      else
        Q.ParamByName('keywords').AsWideString := Trim(LTrans.Keywords);
      LogQuery(Q, 'SaveTranslations');
      Q.ExecSQL;
    end;
  finally
    D.Free;
    Q.Free;
  end;
end;

function TSysMenuRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + Self.BuildSelectColumns(['id', 'locale']) + ' FROM ' + Self.GetFullViewName(TSysMenu) +
    ' WHERE locale = :locale ';
  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
  Result.ParamByName('locale').Value := TAppContext.Instance.CurrentUser.ActiveLanguage;
end;

function TSysMenuRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TSysMenu>;
var
  Q: TFDQuery;
  LItem: TSysMenu;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TSysMenu>.Create(True);
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := Self.PrepareSelectFromView(AFilter, ALock, False, True);
    if Assigned(AFilter) then
      for Criteria in AFilter do
        Q.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
    Q.ParamByName('locale').Value := TAppContext.Instance.CurrentUser.ActiveLanguage;
    LogQuery(Q, 'DoFind');
    Q.Open;
    while not Q.Eof do
    begin
      LItem := MapFromQuery(Q);
      LoadTranslations(LItem);
      Result.Add(LItem);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

function TSysMenuRepository.DoFindById(AId: TValue; ALock: Boolean): TSysMenu;
var
  Q: TFDQuery;
  LFilter: TFilterCriteria;
begin
  Result := nil;
  Q := TFDQuery.Create(nil);
  LFilter := TFilterCriteria.Create;
  try
    Q.Connection := Connection;
    LFilter.Add(TFilterCriterion.New('id', '=', AId));
    Q.SQL.Text := Self.PrepareSelectFromView(LFilter, ALock, True, True);
    Q.ParamByName('id').AsLargeInt := AId.AsInt64;
    Q.ParamByName('locale').Value := TAppContext.Instance.CurrentUser.ActiveLanguage;
    LogQuery(Q, 'DoFindById');
    Q.Open;
    if not Q.IsEmpty then
    begin
      Result := MapFromQuery(Q);
      LoadTranslations(Result);
    end;
  finally
    Q.Free;
    LFilter.Free;
  end;
end;

function TSysMenuRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TSysMenu;
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
    begin
      Result := MapFromQuery(Q);
      LoadTranslations(Result);
    end;
  finally
    Q.Free;
  end;
end;

procedure TSysMenuRepository.DoAdd(AModel: TSysMenu);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareAddSql + ' RETURNING id';
    SetInsertParams(Q, AModel);
    ApplyNullPolicy(Q);
    LogQuery(Q, 'DoAdd');
    Q.Open;
    AModel.Id := Q.FieldByName('id').AsLargeInt;
  finally
    Q.Free;
  end;
  SaveTranslations(AModel);
end;

procedure TSysMenuRepository.DoAddBatch(AModels: TArray<TSysMenu>);
var
  I: Integer;
begin
  for I := 0 to High(AModels) do
    DoAdd(AModels[I]);
end;

procedure TSysMenuRepository.DoUpdate(AModel: TSysMenu);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareUpdateSql;
    SetUpdateParams(Q, AModel);
    ApplyNullPolicy(Q);
    LogQuery(Q, 'DoUpdate');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
  SaveTranslations(AModel);
end;

procedure TSysMenuRepository.DoUpdateBatch(AModels: TArray<TSysMenu>);
var
  I: Integer;
begin
  for I := 0 to High(AModels) do
    DoUpdate(AModels[I]);
end;

procedure TSysMenuRepository.DoDelete(AID: TValue);
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

procedure TSysMenuRepository.DoDelete(AModel: TSysMenu);
begin
  DoDelete(TValue.From<Int64>(AModel.Id));
end;

procedure TSysMenuRepository.DoDeleteBatch(AModels: TArray<TSysMenu>);
var
  I: Integer;
begin
  for I := 0 to High(AModels) do
    DoDelete(AModels[I]);
end;

procedure TSysMenuRepository.DoDeleteBatch(AIDs: TArray<TValue>);
var
  I: Integer;
begin
  for I := 0 to High(AIDs) do
    DoDelete(AIDs[I]);
end;

procedure TSysMenuRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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

{ menü ağacı + kullanıcı tercihleri }

function TSysMenuRepository.GetScreenId(AMenuCode: Integer): Int64;
var
  Q: TFDQuery;
begin
  Result := 0;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT id FROM public.sys_menu WHERE menu_code = :code AND action_name IS NOT NULL';
    Q.ParamByName('code').AsInteger := AMenuCode;
    LogQuery(Q, 'GetScreenId');
    Q.Open;
    if not Q.Eof then
      Result := Q.Fields[0].AsLargeInt;
  finally
    Q.Free;
  end;
end;

procedure TSysMenuRepository.SetFavorite(AUserId, AMenuId: Int64; AValue: Boolean);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text :=
      'INSERT INTO public.sys_user_menu (sys_user_id, sys_menu_id, is_favorite) VALUES (:user_id, :menu_id, :fav) ' +
      'ON CONFLICT (sys_user_id, sys_menu_id) DO UPDATE SET is_favorite = EXCLUDED.is_favorite';
    Q.ParamByName('user_id').AsLargeInt := AUserId;
    Q.ParamByName('menu_id').AsLargeInt := AMenuId;
    Q.ParamByName('fav').AsBoolean := AValue;
    LogQuery(Q, 'SetFavorite');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TSysMenuRepository.RegisterOpen(AUserId, AMenuId: Int64);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text :=
      'INSERT INTO public.sys_user_menu (sys_user_id, sys_menu_id, open_count, last_opened_at) ' +
      'VALUES (:user_id, :menu_id, 1, LOCALTIMESTAMP(0)) ' +
      'ON CONFLICT (sys_user_id, sys_menu_id) DO UPDATE SET open_count = sys_user_menu.open_count + 1, ' +
      '  last_opened_at = LOCALTIMESTAMP(0)';
    Q.ParamByName('user_id').AsLargeInt := AUserId;
    Q.ParamByName('menu_id').AsLargeInt := AMenuId;
    LogQuery(Q, 'RegisterOpen');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

function TSysMenuRepository.GetItems(const ALocale: string; AUserId: Int64): TArray<TSysMenuItem>;
var
  Q: TFDQuery;
  LItem: TSysMenuItem;
begin
  Result := [];
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text :=
      'SELECT m.id, m.menu_code, m.parent_code, m.menu_key, m.action_name, m.permission_code, m.menu_name, m.keywords, ' +
      '       m.is_active, COALESCE(um.is_favorite, false) AS is_favorite, COALESCE(um.open_count, 0) AS open_count, ' +
      '       um.last_opened_at ' +
      '  FROM public.vw_sys_menu m ' +
      '  LEFT JOIN public.sys_user_menu um ON um.sys_menu_id = m.id AND um.sys_user_id = :user_id ' +
      ' WHERE m.locale = :locale ORDER BY m.menu_code';
    Q.ParamByName('locale').DataType := ftWideString;
    Q.ParamByName('locale').AsWideString := ALocale;
    Q.ParamByName('user_id').AsLargeInt := AUserId;
    LogQuery(Q, 'GetItems');
    Q.Open;
    while not Q.Eof do
    begin
      LItem := Default(TSysMenuItem);
      LItem.Id := Q.FieldByName('id').AsLargeInt;
      LItem.MenuCode := Q.FieldByName('menu_code').AsInteger;
      LItem.ParentCode := Q.FieldByName('parent_code').AsInteger;
      LItem.MenuKey := Q.FieldByName('menu_key').AsString;
      LItem.ActionName := Q.FieldByName('action_name').AsString;
      LItem.PermissionCode := Q.FieldByName('permission_code').AsInteger;
      LItem.MenuName := Q.FieldByName('menu_name').AsString;
      LItem.Keywords := Q.FieldByName('keywords').AsString;
      LItem.IsActive := Q.FieldByName('is_active').AsBoolean;
      LItem.IsFavorite := Q.FieldByName('is_favorite').AsBoolean;
      LItem.OpenCount := Q.FieldByName('open_count').AsInteger;
      if Q.FieldByName('last_opened_at').IsNull then
        LItem.LastOpenedAt := 0
      else
        LItem.LastOpenedAt := Q.FieldByName('last_opened_at').AsDateTime;
      Result := Result + [LItem];
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

end.
