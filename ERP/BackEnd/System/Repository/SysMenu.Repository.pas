unit SysMenu.Repository;

interface

{$I Ths.inc}

uses
  System.SysUtils, Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Param,
  Logger, SysMenu;

type
  // Menü ağacı: yalnız okuma (vw_sys_menu, locale'li)
  TSysMenuRepository = class
  private
    FConnection: TFDConnection;
  public
    constructor Create(AConnection: TFDConnection);
    // Aktif satırlar, kod sırasıyla (üst klasör her zaman altındakilerden önce gelir)
    function GetItems(const ALocale: string): TArray<TSysMenuItem>;
  end;

implementation

constructor TSysMenuRepository.Create(AConnection: TFDConnection);
begin
  inherited Create;
  if AConnection = nil then
    raise Exception.Create('Connection Required');
  FConnection := AConnection;
end;

function TSysMenuRepository.GetItems(const ALocale: string): TArray<TSysMenuItem>;
var
  Q: TFDQuery;
  LItem: TSysMenuItem;
begin
  Result := [];
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConnection;
    Q.SQL.Text :=
      'SELECT id, menu_code, parent_code, menu_key, action_name, permission_code, menu_name, keywords ' +
      '  FROM public.vw_sys_menu WHERE locale = :locale AND is_active ORDER BY menu_code';
    Q.ParamByName('locale').DataType := ftWideString;
    Q.ParamByName('locale').AsWideString := ALocale;
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
      Result := Result + [LItem];
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

end.
