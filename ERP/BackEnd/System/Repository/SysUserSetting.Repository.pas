unit SysUserSetting.Repository;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Param,
  Logger;

type
  // sys_user_setting: kullanıcı bazında anahtar / değer
  TSysUserSettingRepository = class
  private
    FConnection: TFDConnection;
    procedure Log(Q: TFDQuery; const AOperation: string);
  public
    constructor Create(AConnection: TFDConnection);
    // AKeyPrefix ile başlayan tüm ayarlar (boş = hepsi)
    function GetValues(AUserId: Int64; const AKeyPrefix: string): TDictionary<string, string>;
    procedure SetValue(AUserId: Int64; const AKey, AValue: string);
  end;

implementation

constructor TSysUserSettingRepository.Create(AConnection: TFDConnection);
begin
  inherited Create;
  if AConnection = nil then
    raise Exception.Create('Connection Required');
  FConnection := AConnection;
end;

procedure TSysUserSettingRepository.Log(Q: TFDQuery; const AOperation: string);
begin
  {$IF Defined(DEBUG) or Defined(FULL_LOG_SQL)}
  GLogger.LogSQL(Q.SQL.Text, Self.ClassName + '.' + AOperation);
  {$IFEND}
end;

function TSysUserSettingRepository.GetValues(AUserId: Int64; const AKeyPrefix: string): TDictionary<string, string>;
var
  Q: TFDQuery;
begin
  Result := TDictionary<string, string>.Create;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConnection;
    Q.SQL.Text := 'SELECT setting_key, setting_value FROM public.sys_user_setting ' +
      'WHERE sys_user_id = :user_id AND setting_key LIKE :prefix';
    Q.ParamByName('user_id').AsLargeInt := AUserId;
    Q.ParamByName('prefix').DataType := ftWideString;
    Q.ParamByName('prefix').AsWideString := AKeyPrefix + '%';
    Log(Q, 'GetValues');
    Q.Open;
    while not Q.Eof do
    begin
      Result.AddOrSetValue(Q.Fields[0].AsWideString, Q.Fields[1].AsWideString);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

procedure TSysUserSettingRepository.SetValue(AUserId: Int64; const AKey, AValue: string);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConnection;
    Q.SQL.Text := 'INSERT INTO public.sys_user_setting (sys_user_id, setting_key, setting_value) ' +
      'VALUES (:user_id, :key, :value) ' +
      'ON CONFLICT (sys_user_id, setting_key) DO UPDATE SET setting_value = EXCLUDED.setting_value';
    Q.ParamByName('user_id').AsLargeInt := AUserId;
    Q.ParamByName('key').DataType := ftWideString;
    Q.ParamByName('key').AsWideString := AKey;
    Q.ParamByName('value').DataType := ftWideString;
    Q.ParamByName('value').AsWideString := AValue;
    Log(Q, 'SetValue');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

end.
