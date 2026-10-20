unit AccAccount.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, AccAccount;

type
  TAccAccountRepository = class(TRepository<TAccAccount>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TAccAccount; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TAccAccount; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TAccAccount; override;

    // 1:1 detay tabloları (acc_account_taxpayer, acc_account_contact) ana kayıtla birlikte yazılır
    procedure SaveDetails(AModel: TAccAccount);

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TAccAccount>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TAccAccount; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TAccAccount; override;

    procedure DoAdd(AModel: TAccAccount); override;
    procedure DoAddBatch(AModels: TArray<TAccAccount>); override;

    procedure DoUpdate(AModel: TAccAccount); override;
    procedure DoUpdateBatch(AModels: TArray<TAccAccount>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TAccAccount); override;
    procedure DoDeleteBatch(AModels: TArray<TAccAccount>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);

    // Hesap kodu seçimi (kart), hesap planına (acc_account_plan.level = ana kodun seviye sayısı) göre. AParentCode '' =
    // birinci seviye. Sonuçlar satır satır tek metin (ComboBox.Items.Text):
    // AParentCode'un bir alt seviyesindeki, planda altına hesap açılabilen hesaplar: "kod - ad"
    function ListParentAccounts(const AParentCode: string): string;
    // Açılabilecek boş kodlar (sıralı): birinci seviyede planda olup açılmamış ana kodlar, alt seviyede (plan izin
    // veriyorsa) 001-999
    function ListFreeCodes(const AParentCode: string): string;
    // Ana kodun plandaki seviye sayısı; planda yoksa 0
    function PlanLevelOf(const ARootCode: string): Integer;
    function AccountExists(const ACode: string): Boolean;
    // ACode'un altında hesap var mı (ACode-...)
    function HasChildAccounts(const ACode: string): Boolean;
    function CodeOf(AId: Int64): string;
  end;

implementation

constructor TAccAccountRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TAccAccountRepository.ListParentAccounts(const AParentCode: string): string;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    // AParentCode yalnız rakam ve '-' içerir (servis kodu doğrular); regex içinde güvenli
    // seviye = (length(code) + 1) / 4: 120 -> 1, 120-001 -> 2, 120-001-001 -> 3
    Q.SQL.Text := 'SELECT string_agg(a.code || '' - '' || a.name, E''\n'' ORDER BY a.code) AS items ' +
                  '  FROM public.acc_account a JOIN public.acc_account_plan p ON p.code = left(a.code, 3) ' +
                  ' WHERE a.code ~ (CASE WHEN :parent = '''' THEN ''^[0-9]{3}$'' ELSE ''^'' || :parent || ''-[0-9]{3}$'' END) ' +
                  '   AND p.level > (length(a.code) + 1) / 4';
    Q.ParamByName('parent').AsWideString := AParentCode;
    LogQuery(Q, 'ListParentAccounts');
    Q.Open;
    Result := Q.FieldByName('items').AsString;
  finally
    Q.Free;
  end;
end;

function TAccAccountRepository.ListFreeCodes(const AParentCode: string): string;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT string_agg(s.code, E''\n'' ORDER BY s.code) AS items ' +
                  '  FROM (SELECT p.code FROM public.acc_account_plan p WHERE :parent = '''' ' +
                  '        UNION ALL ' +
                  '        SELECT :parent || ''-'' || lpad(n::text, 3, ''0'') FROM generate_series(1, 999) n ' +
                  '         WHERE :parent <> '''' AND EXISTS (SELECT 1 FROM public.acc_account_plan p ' +
                  '                 WHERE p.code = left(:parent, 3) AND p.level > (length(:parent) + 1) / 4)) s ' +
                  ' WHERE NOT EXISTS (SELECT 1 FROM public.acc_account a WHERE a.code = s.code)';
    Q.ParamByName('parent').AsWideString := AParentCode;
    LogQuery(Q, 'ListFreeCodes');
    Q.Open;
    Result := Q.FieldByName('items').AsString;
  finally
    Q.Free;
  end;
end;

function TAccAccountRepository.PlanLevelOf(const ARootCode: string): Integer;
var
  Q: TFDQuery;
begin
  Result := 0;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT level FROM public.acc_account_plan WHERE code = :code';
    Q.ParamByName('code').AsWideString := ARootCode;
    LogQuery(Q, 'PlanLevelOf');
    Q.Open;
    if not Q.IsEmpty then
      Result := Q.FieldByName('level').AsInteger;
  finally
    Q.Free;
  end;
end;

function TAccAccountRepository.AccountExists(const ACode: string): Boolean;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT EXISTS (SELECT 1 FROM public.acc_account WHERE code = :code) AS found';
    Q.ParamByName('code').AsWideString := ACode;
    LogQuery(Q, 'AccountExists');
    Q.Open;
    Result := Q.FieldByName('found').AsBoolean;
  finally
    Q.Free;
  end;
end;

function TAccAccountRepository.HasChildAccounts(const ACode: string): Boolean;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT EXISTS (SELECT 1 FROM public.acc_account WHERE left(code, length(:code) + 1) = :code || ''-'') AS has_child';
    Q.ParamByName('code').AsWideString := ACode;
    LogQuery(Q, 'HasChildAccounts');
    Q.Open;
    Result := Q.FieldByName('has_child').AsBoolean;
  finally
    Q.Free;
  end;
end;

function TAccAccountRepository.CodeOf(AId: Int64): string;
var
  Q: TFDQuery;
begin
  Result := '';
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT code FROM public.acc_account WHERE id = :id';
    Q.ParamByName('id').AsLargeInt := AId;
    LogQuery(Q, 'CodeOf');
    Q.Open;
    if not Q.IsEmpty then
      Result := Q.FieldByName('code').AsString;
  finally
    Q.Free;
  end;
end;

function TAccAccountRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TAccAccount) +
            ' (code, name, acc_set_account_type_id, acc_group_id, acc_region_id, root_code, sub_code, iban, iban_currency, discount_rate, e_invoice_active, e_despatch_active, e_invoice_package_name, is_passive, notes) ' +
            ' VALUES (:code, :name, :acc_set_account_type_id, :acc_group_id, :acc_region_id, :root_code, :sub_code, :iban, :iban_currency, :discount_rate, :e_invoice_active, :e_despatch_active, :e_invoice_package_name, :is_passive, :notes)';
end;

function TAccAccountRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TAccAccount) +
            ' SET code = :code, name = :name, acc_set_account_type_id = :acc_set_account_type_id, acc_group_id = :acc_group_id, acc_region_id = :acc_region_id, root_code = :root_code, sub_code = :sub_code, iban = :iban, iban_currency = :iban_currency, discount_rate = :discount_rate, e_invoice_active = :e_invoice_active, e_despatch_active = :e_despatch_active, e_invoice_package_name = :e_invoice_package_name, is_passive = :is_passive, notes = :notes ' +
            ' WHERE id = :id';
end;

function TAccAccountRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TAccAccount) + ' WHERE';
end;

procedure TAccAccountRepository.SetInsertParams(Q: TFDQuery; AModel: TAccAccount; AIndex: Integer);

  // Kod ile bağlanan FK: boş değer NULL gönderilir
  procedure SetCode(const AName, AValue: string);
  begin
    Q.ParamByName(AName).DataType := ftWideString;
    if AValue <> '' then
    begin
      if AIndex < 0 then
        Q.ParamByName(AName).AsWideString := AValue
      else
        Q.ParamByName(AName).AsWideStrings[AIndex] := AValue;
    end
    else if AIndex < 0 then
      Q.ParamByName(AName).Clear
    else
      Q.ParamByName(AName).Clear(AIndex);
  end;

begin
  if AIndex < 0 then
  begin
    Q.ParamByName('code').AsWideString := AModel.Code;
    Q.ParamByName('name').AsWideString := AModel.Name;
    Q.ParamByName('root_code').AsWideString := AModel.RootCode;
    Q.ParamByName('sub_code').AsWideString := AModel.SubCode;
    Q.ParamByName('iban').AsWideString := AModel.Iban;
    Q.ParamByName('discount_rate').AsBCD := AModel.DiscountRate;
    Q.ParamByName('e_invoice_active').AsBoolean := AModel.EInvoiceActive;
    Q.ParamByName('e_despatch_active').AsBoolean := AModel.EDespatchActive;
    Q.ParamByName('e_invoice_package_name').AsWideString := AModel.EInvoicePackageName;
    Q.ParamByName('is_passive').AsBoolean := AModel.IsPassive;
    Q.ParamByName('notes').AsWideString := AModel.Notes;
  end
  else
  begin
    Q.ParamByName('code').AsWideStrings[AIndex] := AModel.Code;
    Q.ParamByName('name').AsWideStrings[AIndex] := AModel.Name;
    Q.ParamByName('root_code').AsWideStrings[AIndex] := AModel.RootCode;
    Q.ParamByName('sub_code').AsWideStrings[AIndex] := AModel.SubCode;
    Q.ParamByName('iban').AsWideStrings[AIndex] := AModel.Iban;
    Q.ParamByName('discount_rate').AsBCDs[AIndex] := AModel.DiscountRate;
    Q.ParamByName('e_invoice_active').AsBooleans[AIndex] := AModel.EInvoiceActive;
    Q.ParamByName('e_despatch_active').AsBooleans[AIndex] := AModel.EDespatchActive;
    Q.ParamByName('e_invoice_package_name').AsWideStrings[AIndex] := AModel.EInvoicePackageName;
    Q.ParamByName('is_passive').AsBooleans[AIndex] := AModel.IsPassive;
    Q.ParamByName('notes').AsWideStrings[AIndex] := AModel.Notes;
  end;

  SetNullableParam(Q.ParamByName('acc_set_account_type_id'), ftLargeint, AModel.AccSetAccountTypeId, AIndex);
  SetNullableParam(Q.ParamByName('acc_group_id'), ftLargeint, AModel.AccGroupId, AIndex);
  SetNullableParam(Q.ParamByName('acc_region_id'), ftLargeint, AModel.AccRegionId, AIndex);
  SetCode('iban_currency', AModel.IbanCurrency);
end;

procedure TAccAccountRepository.SetUpdateParams(Q: TFDQuery; AModel: TAccAccount; AIndex: Integer);

  // Kod ile bağlanan FK: boş değer NULL gönderilir
  procedure SetCode(const AName, AValue: string);
  begin
    Q.ParamByName(AName).DataType := ftWideString;
    if AValue <> '' then
    begin
      if AIndex < 0 then
        Q.ParamByName(AName).AsWideString := AValue
      else
        Q.ParamByName(AName).AsWideStrings[AIndex] := AValue;
    end
    else if AIndex < 0 then
      Q.ParamByName(AName).Clear
    else
      Q.ParamByName(AName).Clear(AIndex);
  end;

begin
  if AIndex < 0 then
  begin
    Q.ParamByName('id').AsLargeInt := AModel.Id;
    Q.ParamByName('code').AsWideString := AModel.Code;
    Q.ParamByName('name').AsWideString := AModel.Name;
    Q.ParamByName('root_code').AsWideString := AModel.RootCode;
    Q.ParamByName('sub_code').AsWideString := AModel.SubCode;
    Q.ParamByName('iban').AsWideString := AModel.Iban;
    Q.ParamByName('discount_rate').AsBCD := AModel.DiscountRate;
    Q.ParamByName('e_invoice_active').AsBoolean := AModel.EInvoiceActive;
    Q.ParamByName('e_despatch_active').AsBoolean := AModel.EDespatchActive;
    Q.ParamByName('e_invoice_package_name').AsWideString := AModel.EInvoicePackageName;
    Q.ParamByName('is_passive').AsBoolean := AModel.IsPassive;
    Q.ParamByName('notes').AsWideString := AModel.Notes;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('code').AsWideStrings[AIndex] := AModel.Code;
    Q.ParamByName('name').AsWideStrings[AIndex] := AModel.Name;
    Q.ParamByName('root_code').AsWideStrings[AIndex] := AModel.RootCode;
    Q.ParamByName('sub_code').AsWideStrings[AIndex] := AModel.SubCode;
    Q.ParamByName('iban').AsWideStrings[AIndex] := AModel.Iban;
    Q.ParamByName('discount_rate').AsBCDs[AIndex] := AModel.DiscountRate;
    Q.ParamByName('e_invoice_active').AsBooleans[AIndex] := AModel.EInvoiceActive;
    Q.ParamByName('e_despatch_active').AsBooleans[AIndex] := AModel.EDespatchActive;
    Q.ParamByName('e_invoice_package_name').AsWideStrings[AIndex] := AModel.EInvoicePackageName;
    Q.ParamByName('is_passive').AsBooleans[AIndex] := AModel.IsPassive;
    Q.ParamByName('notes').AsWideStrings[AIndex] := AModel.Notes;
  end;

  SetNullableParam(Q.ParamByName('acc_set_account_type_id'), ftLargeint, AModel.AccSetAccountTypeId, AIndex);
  SetNullableParam(Q.ParamByName('acc_group_id'), ftLargeint, AModel.AccGroupId, AIndex);
  SetNullableParam(Q.ParamByName('acc_region_id'), ftLargeint, AModel.AccRegionId, AIndex);
  SetCode('iban_currency', AModel.IbanCurrency);
end;

function TAccAccountRepository.MapFromQuery(Q: TFDQuery): TAccAccount;
begin
  Result := TAccAccount.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.Code := Q.FieldByName('code').AsString;
  Result.Name := Q.FieldByName('name').AsString;
  Result.AccSetAccountTypeId := Q.FieldByName('acc_set_account_type_id').AsLargeInt;
  Result.AccGroupId := Q.FieldByName('acc_group_id').AsLargeInt;
  Result.AccRegionId := Q.FieldByName('acc_region_id').AsLargeInt;
  Result.RootCode := Q.FieldByName('root_code').AsString;
  Result.SubCode := Q.FieldByName('sub_code').AsString;
  Result.Iban := Q.FieldByName('iban').AsString;
  Result.IbanCurrency := Q.FieldByName('iban_currency').AsString;
  Result.DiscountRate := Q.FieldByName('discount_rate').AsCurrency;
  Result.EInvoiceActive := Q.FieldByName('e_invoice_active').AsBoolean;
  Result.EDespatchActive := Q.FieldByName('e_despatch_active').AsBoolean;
  Result.EInvoicePackageName := Q.FieldByName('e_invoice_package_name').AsString;
  Result.IsPassive := Q.FieldByName('is_passive').AsBoolean;
  Result.Notes := Q.FieldByName('notes').AsString;
  Result.TaxpayerType := Q.FieldByName('taxpayer_type').AsInteger;
  Result.TaxpayerName := Q.FieldByName('taxpayer_name').AsString;
  Result.TaxpayerName2 := Q.FieldByName('taxpayer_name2').AsString;
  Result.TaxpayerSurname := Q.FieldByName('taxpayer_surname').AsString;
  Result.TaxOffice := Q.FieldByName('tax_office').AsString;
  Result.TaxNo := Q.FieldByName('tax_no').AsString;
  Result.NaceCode := Q.FieldByName('nace_code').AsString;
  Result.AuthorizedPerson1 := Q.FieldByName('authorized_person_1').AsString;
  Result.AuthorizedPhone1 := Q.FieldByName('authorized_phone_1').AsString;
  Result.AuthorizedPerson2 := Q.FieldByName('authorized_person_2').AsString;
  Result.AuthorizedPhone2 := Q.FieldByName('authorized_phone_2').AsString;
  Result.AuthorizedPerson3 := Q.FieldByName('authorized_person_3').AsString;
  Result.AuthorizedPhone3 := Q.FieldByName('authorized_phone_3').AsString;
  Result.Fax := Q.FieldByName('fax').AsString;
  Result.AccountantPhone := Q.FieldByName('accountant_phone').AsString;
  Result.AccountantEmail := Q.FieldByName('accountant_email').AsString;
  Result.AccountantAuthorized := Q.FieldByName('accountant_authorized').AsString;
  Result.AccountTypeName := Q.FieldByName('account_type_name').AsString;
  Result.GroupName := Q.FieldByName('group_name').AsString;
  Result.RegionName := Q.FieldByName('region_name').AsString;
end;

procedure TAccAccountRepository.SaveDetails(AModel: TAccAccount);
var
  Q: TFDQuery;
  AIndex: Integer;
begin
  AIndex := -1;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;

    Q.SQL.Text := 'INSERT INTO public.acc_account_taxpayer (acc_account_id, taxpayer_type, taxpayer_name, taxpayer_name2, taxpayer_surname, tax_office, tax_no, nace_code) ' +
                  ' VALUES (:acc_account_id, :taxpayer_type, :taxpayer_name, :taxpayer_name2, :taxpayer_surname, :tax_office, :tax_no, :nace_code) ' +
                  ' ON CONFLICT (acc_account_id) DO UPDATE SET ' +
                  'taxpayer_type = EXCLUDED.taxpayer_type, taxpayer_name = EXCLUDED.taxpayer_name, taxpayer_name2 = EXCLUDED.taxpayer_name2, taxpayer_surname = EXCLUDED.taxpayer_surname, tax_office = EXCLUDED.tax_office, tax_no = EXCLUDED.tax_no, nace_code = EXCLUDED.nace_code';
    Q.ParamByName('acc_account_id').AsLargeInt := AModel.Id;
    SetNullableParam(Q.ParamByName('taxpayer_type'), ftInteger, AModel.TaxpayerType, AIndex);
    Q.ParamByName('taxpayer_name').AsWideString := AModel.TaxpayerName;
    Q.ParamByName('taxpayer_name2').AsWideString := AModel.TaxpayerName2;
    Q.ParamByName('taxpayer_surname').AsWideString := AModel.TaxpayerSurname;
    Q.ParamByName('tax_office').AsWideString := AModel.TaxOffice;
    Q.ParamByName('tax_no').AsWideString := AModel.TaxNo;
    Q.ParamByName('nace_code').AsWideString := AModel.NaceCode;
    ApplyNullPolicy(Q, 'acc_account_taxpayer');
    LogQuery(Q, 'SaveDetails');
    Q.ExecSQL;

    Q.SQL.Text := 'INSERT INTO public.acc_account_contact (acc_account_id, authorized_person_1, authorized_phone_1, authorized_person_2, authorized_phone_2, authorized_person_3, authorized_phone_3, fax, accountant_phone, accountant_email, accountant_authorized) ' +
                  ' VALUES (:acc_account_id, :authorized_person_1, :authorized_phone_1, :authorized_person_2, :authorized_phone_2, :authorized_person_3, :authorized_phone_3, :fax, :accountant_phone, :accountant_email, :accountant_authorized) ' +
                  ' ON CONFLICT (acc_account_id) DO UPDATE SET ' +
                  'authorized_person_1 = EXCLUDED.authorized_person_1, authorized_phone_1 = EXCLUDED.authorized_phone_1, authorized_person_2 = EXCLUDED.authorized_person_2, authorized_phone_2 = EXCLUDED.authorized_phone_2, authorized_person_3 = EXCLUDED.authorized_person_3, authorized_phone_3 = EXCLUDED.authorized_phone_3, fax = EXCLUDED.fax, accountant_phone = EXCLUDED.accountant_phone, accountant_email = EXCLUDED.accountant_email, accountant_authorized = EXCLUDED.accountant_authorized';
    Q.ParamByName('acc_account_id').AsLargeInt := AModel.Id;
    Q.ParamByName('authorized_person_1').AsWideString := AModel.AuthorizedPerson1;
    Q.ParamByName('authorized_phone_1').AsWideString := AModel.AuthorizedPhone1;
    Q.ParamByName('authorized_person_2').AsWideString := AModel.AuthorizedPerson2;
    Q.ParamByName('authorized_phone_2').AsWideString := AModel.AuthorizedPhone2;
    Q.ParamByName('authorized_person_3').AsWideString := AModel.AuthorizedPerson3;
    Q.ParamByName('authorized_phone_3').AsWideString := AModel.AuthorizedPhone3;
    Q.ParamByName('fax').AsWideString := AModel.Fax;
    Q.ParamByName('accountant_phone').AsWideString := AModel.AccountantPhone;
    Q.ParamByName('accountant_email').AsWideString := AModel.AccountantEmail;
    Q.ParamByName('accountant_authorized').AsWideString := AModel.AccountantAuthorized;
    ApplyNullPolicy(Q, 'acc_account_contact');
    LogQuery(Q, 'SaveDetails');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

function TAccAccountRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id', 'locale']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TAccAccount) + ' WHERE locale = :locale ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
  Result.ParamByName('locale').Value := TAppContext.Instance.CurrentUser.ActiveLanguage;
end;

function TAccAccountRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TAccAccount>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TAccAccount>.Create(True);
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := Self.PrepareSelectFromView(AFilter, ALock, False, True);

    if Assigned(AFilter) and (AFilter.Count > 0) then
      for Criteria in AFilter do
        Q.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
    Q.ParamByName('locale').Value := TAppContext.Instance.CurrentUser.ActiveLanguage;

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

function TAccAccountRepository.DoFindById(AId: TValue; ALock: Boolean): TAccAccount;
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
    LogQuery(Q, 'DoFindById');
    Q.Open;

    if not Q.IsEmpty then
      Result := MapFromQuery(Q);
  finally
    Q.Free;
    Criteria.Free;
  end;
end;

function TAccAccountRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TAccAccount;
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
      Result := MapFromQuery(Q);
  finally
    Q.Free;
  end;
end;

procedure TAccAccountRepository.DoAdd(AModel: TAccAccount);
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

  SaveDetails(AModel);
end;

procedure TAccAccountRepository.DoAddBatch(AModels: TArray<TAccAccount>);
var
  I: Integer;
begin
  // RETURNING id gerektiği için (1:1 detay tabloları) kayıtlar tek tek eklenir
  for I := 0 to Length(AModels) - 1 do
    DoAdd(AModels[I]);
end;

procedure TAccAccountRepository.DoUpdate(AModel: TAccAccount);
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

  SaveDetails(AModel);
end;

procedure TAccAccountRepository.DoUpdateBatch(AModels: TArray<TAccAccount>);
var
  Q: TFDQuery;
  I, Count: Integer;
begin
  Count := Length(AModels);
  if Count = 0 then
    Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareUpdateSql;
    Q.Params.ArraySize := Count;

    for I := 0 to Count - 1 do
      SetUpdateParams(Q, AModels[I], I);

    ApplyNullPolicy(Q);

    LogQuery(Q, 'DoUpdateBatch');
    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;

  for I := 0 to Count - 1 do
    SaveDetails(AModels[I]);
end;

procedure TAccAccountRepository.DoDelete(AID: TValue);
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

procedure TAccAccountRepository.DoDelete(AModel: TAccAccount);
begin
  Delete(AModel.Id);
end;

procedure TAccAccountRepository.DoDeleteBatch(AModels: TArray<TAccAccount>);
var
  Q: TFDQuery;
  I, Count: Integer;
begin
  Count := Length(AModels);
  if Count = 0 then
    Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareDeleteSql + ' id = :id';
    Q.Params.ArraySize := Count;

    for I := 0 to Count - 1 do
      Q.ParamByName('id').AsLargeInts[I] := AModels[I].Id;

    LogQuery(Q, 'DoDeleteBatch');
    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TAccAccountRepository.DoDeleteBatch(AIDs: TArray<TValue>);
var
  Q: TFDQuery;
  I, Count: Integer;
begin
  Count := Length(AIDs);
  if Count = 0 then
    Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareDeleteSql + ' id = :id';
    Q.Params.ArraySize := Count;

    for I := 0 to Count - 1 do
      Q.ParamByName('id').AsLargeInts[I] := AIDs[I].AsInt64;

    LogQuery(Q, 'DoDeleteBatch');
    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TAccAccountRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
