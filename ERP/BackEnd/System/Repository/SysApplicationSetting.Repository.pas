unit SysApplicationSetting.Repository;

interface

uses
  SysUtils, Classes, Types, Data.DB, System.Generics.Collections, System.Rtti,
  FireDAC.Stan.Param, FireDAC.Comp.Client, Entity, Repository,
  SysApplicationSetting, FilterCriterion;

type
  TSysApplicationSettingRepository = class(TRepository<TSysApplicationSetting>)
  protected
    function PrepareSelectSql: string;
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetCommonParams(Q: TFDQuery; AModel: TSysApplicationSetting);
    function MapFromQuery(Q: TFDQuery): TSysApplicationSetting; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TSysApplicationSetting>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TSysApplicationSetting; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TSysApplicationSetting; override;

    procedure DoAdd(AModel: TSysApplicationSetting); override;
    procedure DoAddBatch(AModels: TArray<TSysApplicationSetting>); override;

    procedure DoUpdate(AModel: TSysApplicationSetting); override;
    procedure DoUpdateBatch(AModels: TArray<TSysApplicationSetting>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TSysApplicationSetting); override;
    procedure DoDeleteBatch(AModels: TArray<TSysApplicationSetting>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

const
  // Tablo tek kayıt tutar. logo bu formda düzenlenmediği için yazılmaz.
  SELECT_COLUMNS =
    'id, company_title, phone, fax, tax_authority, tax_no, active_period, ' +
    'mail_host, mail_user, mail_password, mail_smtp_port, ' +
    'grid_color_1, grid_color_2, grid_color_active, crypt_key, ' +
    'sms_host, sms_user, sms_password, sms_title, app_version, app_currency, ' +
    'sys_address_id, CAST(other_settings AS text) AS other_settings, ' +
    'taxpayer_name, taxpayer_surname, taxpayer_type';

constructor TSysApplicationSettingRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSysApplicationSettingRepository.PrepareSelectSql: string;
begin
  Result := 'SELECT ' + SELECT_COLUMNS + ' FROM public.' + Self.GetTableName(TSysApplicationSetting) + ' WHERE 1=1 ';
end;

function TSysApplicationSettingRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TSysApplicationSetting) +
            ' (company_title, phone, fax, tax_authority, tax_no, active_period, ' +
            '  mail_host, mail_user, mail_password, mail_smtp_port, ' +
            '  grid_color_1, grid_color_2, grid_color_active, crypt_key, ' +
            '  sms_host, sms_user, sms_password, sms_title, app_version, app_currency, ' +
            '  sys_address_id, other_settings, taxpayer_name, taxpayer_surname, taxpayer_type) ' +
            ' VALUES (:company_title, :phone, :fax, :tax_authority, :tax_no, :active_period, ' +
            '  :mail_host, :mail_user, :mail_password, :mail_smtp_port, ' +
            '  :grid_color_1, :grid_color_2, :grid_color_active, :crypt_key, ' +
            '  :sms_host, :sms_user, :sms_password, :sms_title, :app_version, NULLIF(:app_currency, ''''), ' +
            '  :sys_address_id, CAST(NULLIF(:other_settings, '''') AS jsonb), :taxpayer_name, :taxpayer_surname, :taxpayer_type)';
end;

function TSysApplicationSettingRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TSysApplicationSetting) +
            ' SET company_title = :company_title, phone = :phone, fax = :fax, ' +
            '     tax_authority = :tax_authority, tax_no = :tax_no, active_period = :active_period, ' +
            '     mail_host = :mail_host, mail_user = :mail_user, mail_password = :mail_password, ' +
            '     mail_smtp_port = :mail_smtp_port, grid_color_1 = :grid_color_1, ' +
            '     grid_color_2 = :grid_color_2, grid_color_active = :grid_color_active, ' +
            '     crypt_key = :crypt_key, sms_host = :sms_host, sms_user = :sms_user, ' +
            '     sms_password = :sms_password, sms_title = :sms_title, app_version = :app_version, ' +
            '     app_currency = NULLIF(:app_currency, ''''), sys_address_id = :sys_address_id, ' +
            '     other_settings = CAST(NULLIF(:other_settings, '''') AS jsonb), ' +
            '     taxpayer_name = :taxpayer_name, taxpayer_surname = :taxpayer_surname, ' +
            '     taxpayer_type = :taxpayer_type ' +
            ' WHERE id = :id';
end;

function TSysApplicationSettingRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TSysApplicationSetting) + ' WHERE';
end;

procedure TSysApplicationSettingRepository.SetCommonParams(Q: TFDQuery; AModel: TSysApplicationSetting);
begin
  Q.ParamByName('company_title').AsString := AModel.CompanyTitle;
  Q.ParamByName('phone').AsString := AModel.Phone;
  Q.ParamByName('fax').AsString := AModel.Fax;
  Q.ParamByName('tax_authority').AsString := AModel.TaxAuthority;
  Q.ParamByName('tax_no').AsString := AModel.TaxNo;
  Q.ParamByName('active_period').AsSmallInt := AModel.ActivePeriod;
  Q.ParamByName('mail_host').AsString := AModel.MailHost;
  Q.ParamByName('mail_user').AsString := AModel.MailUser;
  Q.ParamByName('mail_password').AsString := AModel.MailPassword;
  SetNullableParam(Q.ParamByName('mail_smtp_port'), ftInteger, AModel.MailSmtpPort);
  Q.ParamByName('grid_color_1').AsInteger := AModel.GridColor1;
  Q.ParamByName('grid_color_2').AsInteger := AModel.GridColor2;
  Q.ParamByName('grid_color_active').AsInteger := AModel.GridColorActive;
  Q.ParamByName('crypt_key').AsString := AModel.CryptKey;
  Q.ParamByName('sms_host').AsString := AModel.SmsHost;
  Q.ParamByName('sms_user').AsString := AModel.SmsUser;
  Q.ParamByName('sms_password').AsString := AModel.SmsPassword;
  Q.ParamByName('sms_title').AsString := AModel.SmsTitle;
  Q.ParamByName('app_version').AsString := AModel.AppVersion;
  Q.ParamByName('app_currency').AsString := AModel.AppCurrency;
  SetNullableParam(Q.ParamByName('sys_address_id'), ftLargeint, AModel.SysAddressId);
  Q.ParamByName('other_settings').AsString := AModel.OtherSettings;
  Q.ParamByName('taxpayer_name').AsString := AModel.TaxpayerName;
  Q.ParamByName('taxpayer_surname').AsString := AModel.TaxpayerSurname;
  Q.ParamByName('taxpayer_type').AsString := AModel.Taxpayertype;
end;

function TSysApplicationSettingRepository.MapFromQuery(Q: TFDQuery): TSysApplicationSetting;
begin
  Result := TSysApplicationSetting.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.CompanyTitle := Q.FieldByName('company_title').AsString;
  Result.Phone := Q.FieldByName('phone').AsString;
  Result.Fax := Q.FieldByName('fax').AsString;
  Result.TaxAuthority := Q.FieldByName('tax_authority').AsString;
  Result.TaxNo := Q.FieldByName('tax_no').AsString;
  Result.ActivePeriod := Q.FieldByName('active_period').AsInteger;
  Result.MailHost := Q.FieldByName('mail_host').AsString;
  Result.MailUser := Q.FieldByName('mail_user').AsString;
  Result.MailPassword := Q.FieldByName('mail_password').AsString;
  Result.MailSmtpPort := Q.FieldByName('mail_smtp_port').AsInteger;
  Result.GridColor1 := Q.FieldByName('grid_color_1').AsInteger;
  Result.GridColor2 := Q.FieldByName('grid_color_2').AsInteger;
  Result.GridColorActive := Q.FieldByName('grid_color_active').AsInteger;
  Result.CryptKey := Q.FieldByName('crypt_key').AsString;
  Result.SmsHost := Q.FieldByName('sms_host').AsString;
  Result.SmsUser := Q.FieldByName('sms_user').AsString;
  Result.SmsPassword := Q.FieldByName('sms_password').AsString;
  Result.SmsTitle := Q.FieldByName('sms_title').AsString;
  Result.AppVersion := Q.FieldByName('app_version').AsString;
  Result.AppCurrency := Q.FieldByName('app_currency').AsString;
  Result.SysAddressId := Q.FieldByName('sys_address_id').AsLargeInt;
  Result.OtherSettings := Q.FieldByName('other_settings').AsString;
  Result.TaxpayerName := Q.FieldByName('taxpayer_name').AsString;
  Result.TaxpayerSurname := Q.FieldByName('taxpayer_surname').AsString;
  Result.Taxpayertype := Q.FieldByName('taxpayer_type').AsString;
end;

function TSysApplicationSettingRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
begin
  // Bu tablo için view yok; doğrudan tablodan okunur.
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := PrepareSelectSql;

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TSysApplicationSettingRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TSysApplicationSetting>;
var
  Q: TFDQuery;
begin
  Result := TObjectList<TSysApplicationSetting>.Create(True);
  Q := DoFindAllGridQuery(AFilter);
  try
    Q.SQL.Text := Q.SQL.Text + ' ORDER BY id';
    if ALock then
      Q.SQL.Text := Q.SQL.Text + ' FOR UPDATE NOWAIT';
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

function TSysApplicationSettingRepository.DoFindById(AId: TValue; ALock: Boolean): TSysApplicationSetting;
var
  Q: TFDQuery;
begin
  Result := nil;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareSelectSql + ' AND id = :id';
    if ALock then
      Q.SQL.Text := Q.SQL.Text + ' FOR UPDATE NOWAIT';
    Q.ParamByName('id').AsLargeInt := AId.AsInt64;
    LogQuery(Q, 'DoFindById');
    Q.Open;

    if not Q.IsEmpty then
      Result := MapFromQuery(Q);
  finally
    Q.Free;
  end;
end;

function TSysApplicationSettingRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TSysApplicationSetting;
var
  Q: TFDQuery;
begin
  // Filtre boş olabilir: tablo tek kayıt tuttuğu için ilk kayıt döner.
  Result := nil;
  Q := DoFindAllGridQuery(AFilter);
  try
    Q.SQL.Text := Q.SQL.Text + ' ORDER BY id LIMIT 1';
    if ALock then
      Q.SQL.Text := Q.SQL.Text + ' FOR UPDATE NOWAIT';
    LogQuery(Q, 'DoFindOne');
    Q.Open;

    if not Q.IsEmpty then
      Result := MapFromQuery(Q);
  finally
    Q.Free;
  end;
end;

procedure TSysApplicationSettingRepository.DoAdd(AModel: TSysApplicationSetting);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareAddSql + ' RETURNING id';
    SetCommonParams(Q, AModel);
    LogQuery(Q, 'DoAdd');
    Q.Open;
    AModel.Id := Q.FieldByName('id').AsLargeInt;
  finally
    Q.Free;
  end;
end;

procedure TSysApplicationSettingRepository.DoAddBatch(AModels: TArray<TSysApplicationSetting>);
var
  LModel: TSysApplicationSetting;
begin
  for LModel in AModels do
    DoAdd(LModel);
end;

procedure TSysApplicationSettingRepository.DoUpdate(AModel: TSysApplicationSetting);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareUpdateSql;
    SetCommonParams(Q, AModel);
    Q.ParamByName('id').AsLargeInt := AModel.Id;
    LogQuery(Q, 'DoUpdate');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TSysApplicationSettingRepository.DoUpdateBatch(AModels: TArray<TSysApplicationSetting>);
var
  LModel: TSysApplicationSetting;
begin
  for LModel in AModels do
    DoUpdate(LModel);
end;

procedure TSysApplicationSettingRepository.DoDelete(AID: TValue);
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

procedure TSysApplicationSettingRepository.DoDelete(AModel: TSysApplicationSetting);
begin
  DoDelete(TValue.From<Int64>(AModel.Id));
end;

procedure TSysApplicationSettingRepository.DoDeleteBatch(AModels: TArray<TSysApplicationSetting>);
var
  LModel: TSysApplicationSetting;
begin
  for LModel in AModels do
    DoDelete(LModel);
end;

procedure TSysApplicationSettingRepository.DoDeleteBatch(AIDs: TArray<TValue>);
var
  LId: TValue;
begin
  for LId in AIDs do
    DoDelete(LId);
end;

procedure TSysApplicationSettingRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
