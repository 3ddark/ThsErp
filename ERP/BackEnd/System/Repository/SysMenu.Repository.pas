unit SysMenu.Repository;

interface

{$I Ths.inc}

uses
  System.SysUtils, Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Param,
  Logger, SysMenu;

type
  // Menü ağacı (vw_sys_menu, locale'li) + kullanıcının menü tercihleri (sys_user_menu)
  TSysMenuRepository = class
  private
    FConnection: TFDConnection;
    procedure Exec(Q: TFDQuery; const AOperation: string);
  public
    constructor Create(AConnection: TFDConnection);
    // Aktif satırlar, kod sırasıyla (üst klasör her zaman altındakilerden önce gelir); AUserId'nin favori / son açılma bilgisiyle
    function GetItems(const ALocale: string; AUserId: Int64): TArray<TSysMenuItem>;
    // Ekran satırı yoksa 0
    function GetScreenId(AMenuCode: Integer): Int64;
    procedure SetFavorite(AUserId, AMenuId: Int64; AValue: Boolean);
    procedure RegisterOpen(AUserId, AMenuId: Int64);
  end;

implementation

constructor TSysMenuRepository.Create(AConnection: TFDConnection);
begin
  inherited Create;
  if AConnection = nil then
    raise Exception.Create('Connection Required');
  FConnection := AConnection;
end;

procedure TSysMenuRepository.Exec(Q: TFDQuery; const AOperation: string);
begin
  {$IF Defined(DEBUG) or Defined(FULL_LOG_SQL)}
  GLogger.LogSQL(Q.SQL.Text, Self.ClassName + '.' + AOperation);
  {$IFEND}
  Q.ExecSQL;
end;

function TSysMenuRepository.GetScreenId(AMenuCode: Integer): Int64;
var
  Q: TFDQuery;
begin
  Result := 0;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConnection;
    Q.SQL.Text := 'SELECT id FROM public.sys_menu WHERE menu_code = :code AND action_name IS NOT NULL';
    Q.ParamByName('code').AsInteger := AMenuCode;
    {$IF Defined(DEBUG) or Defined(FULL_LOG_SQL)}
    GLogger.LogSQL(Q.SQL.Text, Self.ClassName + '.GetScreenId');
    {$IFEND}
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
    Q.Connection := FConnection;
    Q.SQL.Text :=
      'INSERT INTO public.sys_user_menu (sys_user_id, sys_menu_id, is_favorite) VALUES (:user_id, :menu_id, :fav) ' +
      'ON CONFLICT (sys_user_id, sys_menu_id) DO UPDATE SET is_favorite = EXCLUDED.is_favorite';
    Q.ParamByName('user_id').AsLargeInt := AUserId;
    Q.ParamByName('menu_id').AsLargeInt := AMenuId;
    Q.ParamByName('fav').AsBoolean := AValue;
    Exec(Q, 'SetFavorite');
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
    Q.Connection := FConnection;
    Q.SQL.Text :=
      'INSERT INTO public.sys_user_menu (sys_user_id, sys_menu_id, open_count, last_opened_at) ' +
      'VALUES (:user_id, :menu_id, 1, LOCALTIMESTAMP(0)) ' +
      'ON CONFLICT (sys_user_id, sys_menu_id) DO UPDATE SET open_count = sys_user_menu.open_count + 1, ' +
      '  last_opened_at = LOCALTIMESTAMP(0)';
    Q.ParamByName('user_id').AsLargeInt := AUserId;
    Q.ParamByName('menu_id').AsLargeInt := AMenuId;
    Exec(Q, 'RegisterOpen');
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
    Q.Connection := FConnection;
    Q.SQL.Text :=
      'SELECT m.id, m.menu_code, m.parent_code, m.menu_key, m.action_name, m.permission_code, m.menu_name, m.keywords, ' +
      '       COALESCE(um.is_favorite, false) AS is_favorite, COALESCE(um.open_count, 0) AS open_count, um.last_opened_at ' +
      '  FROM public.vw_sys_menu m ' +
      '  LEFT JOIN public.sys_user_menu um ON um.sys_menu_id = m.id AND um.sys_user_id = :user_id ' +
      ' WHERE m.locale = :locale AND m.is_active ORDER BY m.menu_code';
    Q.ParamByName('locale').DataType := ftWideString;
    Q.ParamByName('locale').AsWideString := ALocale;
    Q.ParamByName('user_id').AsLargeInt := AUserId;
    {$IF Defined(DEBUG) or Defined(FULL_LOG_SQL)}
    GLogger.LogSQL(Q.SQL.Text, Self.ClassName + '.GetItems');
    {$IFEND}
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
