unit EInvDocument.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, EInvDocument, EInvUbl.Model;

const
  // gönderim işlemlerinde kaynak belge tablosu (ReadSendState / SetEInvNo / SetEInvStatus / SaveTransmission)
  EINV_SOURCE_INVOICE  = 'sls_invoice';
  EINV_SOURCE_DISPATCH = 'sls_dispatch';

type
  // Kaynak belgenin e-belge gönderim durumu
  TEInvSendState = record
    Status: Integer;           // einv_status (yok = 0)
    EInvNo: string;            // GİB numarası (gönderimde verilir)
    Uuid: string;
    IssueDate: TDate;          // fatura / irsaliye tarihi (numara yılı)
    ProfileCode: string;       // senaryo (boş = kağıt belge)
  end;

  TEInvDocumentRepository = class(TRepository<TEInvDocument>)
  private
    class function SourceColumn(const ASource: string): string; static;
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TEInvDocument; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TEInvDocument; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TEInvDocument; override;

    // UBL tarafları (fatura / irsaliye ortak)
    procedure ReadAddress(Q: TFDQuery; AAddressId: Int64; var AParty: TEInvUblParty);
    procedure ReadSupplier(Q: TFDQuery; var AParty: TEInvUblParty);
    // Cari tarafı: ADocTable / ADocId verilirse ünvan / mükellef / vergi bilgisi belgenin kopyasından (belge düzenlendiği
    // andaki bilgi), değilse cari kartından; adres her durumda cari adresinden
    procedure ReadAccountParty(Q: TFDQuery; AAccountId: Int64; const AAddressType: string; var AParty: TEInvUblParty;
      const ADocTable: string = ''; ADocId: Int64 = 0);
    procedure ReadAliases(Q: TFDQuery; AScope: Integer; AAccountId: Int64; var ASenderAlias, AReceiverAlias: string);

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TEInvDocument>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TEInvDocument; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TEInvDocument; override;

    procedure DoAdd(AModel: TEInvDocument); override;
    procedure DoAddBatch(AModels: TArray<TEInvDocument>); override;

    procedure DoUpdate(AModel: TEInvDocument); override;
    procedure DoUpdateBatch(AModels: TArray<TEInvDocument>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TEInvDocument); override;
    procedure DoDeleteBatch(AModels: TArray<TEInvDocument>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);

    // faturanın e-belge XML kaydı (yoksa nil)
    function FindByInvoiceId(AInvoiceId: Int64): TEInvDocument;
    // fatura başına tek kayıt: varsa üzerine yazılır, üretilme zamanı yenilenir
    procedure SaveForInvoice(AInvoiceId: Int64; const AUuid, AEInvNo, AXml: string; AValid: Boolean; const AMessage: string);
    procedure DeleteByInvoiceId(AInvoiceId: Int64);
    // faturanın e-belge durumu (sls_invoice.einv_status; yok = 0)
    function InvoiceEInvStatus(AInvoiceId: Int64): Integer;
    // UBL verisi: fatura başlığı + kalemler (vw_sls_invoice / vw_sls_invoice_detail), satıcı (sys_application_setting),
    // alıcı (cari + mükellef bilgisi + fatura adresi). Fatura yoksa nil.
    function LoadSalesInvoice(AInvoiceId: Int64): TEInvUblInvoice;

    // irsaliyenin e-İrsaliye XML kaydı (yoksa nil); irsaliye başına tek kayıt
    function FindByDispatchId(ADispatchId: Int64): TEInvDocument;
    procedure SaveForDispatch(ADispatchId: Int64; const AUuid, AEInvNo, AXml: string; AValid: Boolean; const AMessage: string);
    procedure DeleteByDispatchId(ADispatchId: Int64);
    function DispatchEInvStatus(ADispatchId: Int64): Integer;
    // UBL verisi: irsaliye + taşıma + kalemler (fiyatsız), sevk eden, teslim alan (sevk adresi), taşıyıcı. Yoksa nil.
    function LoadSalesDispatch(ADispatchId: Int64): TEInvUblDespatch;

    // ---- gönderim (fatura / irsaliye ortak; ASource = EINV_SOURCE_*). Durum yazımı belge iş kuralı kilidinden bağımsızdır
    // ALock: kaynak satır FOR UPDATE ile kilitlenir. Belge yoksa False
    function ReadSendState(const ASource: string; AId: Int64; ALock: Boolean; out AState: TEInvSendState): Boolean;
    procedure SetEInvNo(const ASource: string; AId: Int64; const AEInvNo: string);
    procedure SetEInvStatus(const ASource: string; AId: Int64; AStatus: Integer);
    // einv_document son gönderim / sorgu sonucu (ASent: gönderim zamanı yazılır; boş ref eskisini korur; kod 0 = NULL)
    procedure SaveTransmission(const ASource: string; AId: Int64; const AProviderCode, AProviderRef: string; ASent: Boolean;
      AStatusCode: Integer; const AMessage: string);
    // Firma e-Belge Ayarları: belge türünün API servis türü (vw_einv_document_setting.service_kind; yoksa '')
    function ServiceKindOf(AScope: Integer): string;
  end;

implementation

uses
  EInvLookup;

const
  ADDRESS_LOCALE = 'tr-TR';   // e-belge adresleri Türkçe (ülke adı Türkiye)

constructor TEInvDocumentRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TEInvDocumentRepository.FindByInvoiceId(AInvoiceId: Int64): TEInvDocument;
var
  Q: TFDQuery;
begin
  Result := nil;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT * FROM ' + Self.GetFullViewName(TEInvDocument) + ' WHERE sls_invoice_id = :id';
    Q.ParamByName('id').AsLargeInt := AInvoiceId;
    LogQuery(Q, 'FindByInvoiceId');
    Q.Open;
    if not Q.IsEmpty then
      Result := MapFromQuery(Q);
  finally
    Q.Free;
  end;
end;

procedure TEInvDocumentRepository.SaveForInvoice(AInvoiceId: Int64; const AUuid, AEInvNo, AXml: string; AValid: Boolean;
  const AMessage: string);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text :=
      'INSERT INTO public.einv_document (sls_invoice_id, einv_uuid, einv_no, xml_content, is_valid, validation_message) ' +
      'VALUES (:sls_invoice_id, :einv_uuid, :einv_no, :xml_content, :is_valid, :validation_message) ' +
      'ON CONFLICT (sls_invoice_id) DO UPDATE SET einv_uuid = EXCLUDED.einv_uuid, einv_no = EXCLUDED.einv_no, ' +
      '  xml_content = EXCLUDED.xml_content, is_valid = EXCLUDED.is_valid, validation_message = EXCLUDED.validation_message, ' +
      '  generated_at = now()';
    Q.ParamByName('sls_invoice_id').AsLargeInt := AInvoiceId;
    Q.ParamByName('einv_uuid').AsWideString := AUuid;
    Q.ParamByName('einv_no').AsWideString := AEInvNo;
    Q.ParamByName('xml_content').AsWideMemo := AXml;
    Q.ParamByName('is_valid').AsBoolean := AValid;
    Q.ParamByName('validation_message').DataType := ftWideMemo;
    if AMessage = '' then
      Q.ParamByName('validation_message').Clear
    else
      Q.ParamByName('validation_message').AsWideMemo := AMessage;
    LogQuery(Q, 'SaveForInvoice');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TEInvDocumentRepository.DeleteByInvoiceId(AInvoiceId: Int64);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'DELETE FROM public.einv_document WHERE sls_invoice_id = :id';
    Q.ParamByName('id').AsLargeInt := AInvoiceId;
    LogQuery(Q, 'DeleteByInvoiceId');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

function TEInvDocumentRepository.InvoiceEInvStatus(AInvoiceId: Int64): Integer;
var
  Q: TFDQuery;
begin
  Result := 0;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT COALESCE(einv_status, 0) FROM public.sls_invoice WHERE id = :id';
    Q.ParamByName('id').AsLargeInt := AInvoiceId;
    LogQuery(Q, 'InvoiceEInvStatus');
    Q.Open;
    if not Q.IsEmpty then
      Result := Q.Fields[0].AsInteger;
  finally
    Q.Free;
  end;
end;

function FieldText(Q: TFDQuery; const AField: string): string;
begin
  Result := Trim(Q.FieldByName(AField).AsString);
end;

function JoinText(const AParts: array of string): string;
var
  LPart: string;
begin
  Result := '';
  for LPart in AParts do
    if Trim(LPart) <> '' then
      if Result = '' then
        Result := Trim(LPart)
      else
        Result := Result + ' ' + Trim(LPart);
end;

// ad soyad: son kelime soyad (e-Arşiv'de kimliksiz nihai tüketici)
procedure SplitName(const AFull: string; var AParty: TEInvUblParty);
var
  p: Integer;
begin
  p := LastDelimiter(' ', Trim(AFull));
  if p > 0 then
  begin
    AParty.FirstName := Trim(Copy(Trim(AFull), 1, p - 1));
    AParty.FamilyName := Trim(Copy(Trim(AFull), p + 1, MaxInt));
  end
  else
  begin
    AParty.FirstName := Trim(AFull);
    AParty.FamilyName := Trim(AFull);
  end;
end;

procedure TEInvDocumentRepository.ReadAddress(Q: TFDQuery; AAddressId: Int64; var AParty: TEInvUblParty);
begin
  AParty.Address := Default(TEInvUblAddress);
  if AAddressId <= 0 then
    Exit;
  Q.Close;
  Q.SQL.Text := 'SELECT a.neighborhood, a.quarter, a.road, a.street, a.building_name, a.door_number, a.district, ' +
                '       a.city_name, a.zip_code, a.country_name, c.country_code, a.email, a.web ' +
                '  FROM public.vw_sys_address a LEFT JOIN public.sys_country c ON c.id = a.sys_country_id ' +
                ' WHERE a.id = :id AND a.locale = :locale';
  Q.ParamByName('id').AsLargeInt := AAddressId;
  Q.ParamByName('locale').AsWideString := ADDRESS_LOCALE;
  LogQuery(Q, 'ReadAddress');
  Q.Open;
  if Q.IsEmpty then
    Exit;
  AParty.Address.StreetName := JoinText([FieldText(Q, 'neighborhood'), FieldText(Q, 'quarter'), FieldText(Q, 'road'),
    FieldText(Q, 'street')]);
  AParty.Address.BuildingName := FieldText(Q, 'building_name');
  AParty.Address.BuildingNumber := FieldText(Q, 'door_number');
  AParty.Address.CitySubdivisionName := FieldText(Q, 'district');
  AParty.Address.CityName := FieldText(Q, 'city_name');
  AParty.Address.PostalZone := FieldText(Q, 'zip_code');
  AParty.Address.CountryName := FieldText(Q, 'country_name');
  AParty.Address.CountryCode := FieldText(Q, 'country_code');
  if AParty.Email = '' then
    AParty.Email := FieldText(Q, 'email');
  if AParty.Website = '' then
    AParty.Website := FieldText(Q, 'web');
end;

// Firmamız: uygulama ayarları (taxpayer_type 'TCKN' = gerçek kişi)
procedure TEInvDocumentRepository.ReadSupplier(Q: TFDQuery; var AParty: TEInvUblParty);
var
  LAddressId: Int64;
begin
  AParty := Default(TEInvUblParty);
  Q.Close;
  Q.SQL.Text := 'SELECT company_title, phone, fax, tax_authority, tax_no, sys_address_id, taxpayer_name, ' +
                '       taxpayer_surname, taxpayer_type FROM public.sys_application_setting ORDER BY id LIMIT 1';
  LogQuery(Q, 'ReadSupplier');
  Q.Open;
  LAddressId := 0;
  if not Q.IsEmpty then
  begin
    AParty.Found := True;
    AParty.TaxNo := FieldText(Q, 'tax_no');
    AParty.IsPerson := SameText(FieldText(Q, 'taxpayer_type'), 'TCKN') or (Length(AParty.TaxNo) = 11);
    AParty.Name := FieldText(Q, 'company_title');
    AParty.FirstName := FieldText(Q, 'taxpayer_name');
    AParty.FamilyName := FieldText(Q, 'taxpayer_surname');
    AParty.TaxOffice := FieldText(Q, 'tax_authority');
    AParty.Phone := FieldText(Q, 'phone');
    AParty.Fax := FieldText(Q, 'fax');
    LAddressId := Q.FieldByName('sys_address_id').AsLargeInt;
  end;
  ReadAddress(Q, LAddressId, AParty);
end;

// Cari: mükellef bilgisi (1 tüzel, 2 gerçek kişi) + adres (önce AAddressType, sonra birincil / yasal)
procedure TEInvDocumentRepository.ReadAccountParty(Q: TFDQuery; AAccountId: Int64; const AAddressType: string;
  var AParty: TEInvUblParty; const ADocTable: string; ADocId: Int64);
const
  ADDRESS_SQL =
    '       (SELECT aa.sys_address_id FROM public.acc_account_address aa WHERE aa.acc_account_id = :id ' +
    '         ORDER BY (aa.address_type = :address_type) DESC, aa.is_primary DESC, (aa.address_type = ''LEGAL'') DESC, aa.id ' +
    '         LIMIT 1) AS sys_address_id ';
var
  LAddressId: Int64;
begin
  AParty := Default(TEInvUblParty);
  if AAccountId <= 0 then
    Exit;
  Q.Close;
  if ADocId > 0 then
  begin
    // ADocTable yalnız bu birimin sabitlerinden gelir (sls_invoice / sls_dispatch)
    Q.SQL.Text :=
      'SELECT d.account_title AS name, d.taxpayer_type, d.taxpayer_name, d.taxpayer_name2, d.taxpayer_surname, ' +
      '       d.tax_office, d.tax_no, ' + ADDRESS_SQL +
      '  FROM public.' + ADocTable + ' d WHERE d.id = :doc_id';
    Q.ParamByName('doc_id').AsLargeInt := ADocId;
  end
  else
    Q.SQL.Text :=
      'SELECT a.name, t.taxpayer_type, t.taxpayer_name, t.taxpayer_name2, t.taxpayer_surname, t.tax_office, t.tax_no, ' +
      ADDRESS_SQL +
      '  FROM public.acc_account a LEFT JOIN public.acc_account_taxpayer t ON t.acc_account_id = a.id ' +
      ' WHERE a.id = :id';
  Q.ParamByName('id').AsLargeInt := AAccountId;
  Q.ParamByName('address_type').AsWideString := AAddressType;
  LogQuery(Q, 'ReadAccountParty');
  Q.Open;
  LAddressId := 0;
  if not Q.IsEmpty then
  begin
    AParty.Found := True;
    AParty.TaxNo := FieldText(Q, 'tax_no');
    AParty.TaxOffice := FieldText(Q, 'tax_office');
    AParty.IsPerson := (Q.FieldByName('taxpayer_type').AsInteger = 2) or
      (Q.FieldByName('taxpayer_type').IsNull and (Length(AParty.TaxNo) = 11));
    if AParty.IsPerson then
    begin
      AParty.FirstName := FieldText(Q, 'taxpayer_name');
      AParty.FamilyName := FieldText(Q, 'taxpayer_surname');
      AParty.Name := JoinText([AParty.FirstName, AParty.FamilyName]);
      if (AParty.FirstName = '') and (AParty.FamilyName = '') then
      begin
        AParty.Name := FieldText(Q, 'name');
        SplitName(FieldText(Q, 'name'), AParty);
      end;
    end
    else
    begin
      AParty.Name := JoinText([FieldText(Q, 'taxpayer_name'), FieldText(Q, 'taxpayer_name2')]);
      if AParty.Name = '' then
        AParty.Name := FieldText(Q, 'name');
    end;
    LAddressId := Q.FieldByName('sys_address_id').AsLargeInt;
  end;
  ReadAddress(Q, LAddressId, AParty);
end;

class function TEInvDocumentRepository.SourceColumn(const ASource: string): string;
begin
  if ASource = EINV_SOURCE_INVOICE then
    Result := 'sls_invoice_id'
  else if ASource = EINV_SOURCE_DISPATCH then
    Result := 'sls_dispatch_id'
  else
    raise Exception.CreateFmt('Invalid e-document source: %s', [ASource]);
end;

function TEInvDocumentRepository.ReadSendState(const ASource: string; AId: Int64; ALock: Boolean;
  out AState: TEInvSendState): Boolean;
var
  Q: TFDQuery;
  LDateField: string;
begin
  AState := Default(TEInvSendState);
  SourceColumn(ASource);
  if ASource = EINV_SOURCE_INVOICE then
    LDateField := 'invoice_date'
  else
    LDateField := 'dispatch_date';
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text :=
      'SELECT COALESCE(x.einv_status, 0) AS einv_status, x.einv_no, x.einv_uuid::text AS einv_uuid, x.' + LDateField +
      ' AS doc_date, p.code AS profile_code FROM public.' + ASource + ' x ' +
      ' LEFT JOIN public.einv_profile p ON p.id = x.einv_profile_id WHERE x.id = :id';
    if ALock then
      Q.SQL.Add(' FOR UPDATE OF x');
    Q.ParamByName('id').AsLargeInt := AId;
    LogQuery(Q, 'ReadSendState');
    Q.Open;
    Result := not Q.IsEmpty;
    if Result then
    begin
      AState.Status := Q.FieldByName('einv_status').AsInteger;
      AState.EInvNo := Q.FieldByName('einv_no').AsString;
      AState.Uuid := Q.FieldByName('einv_uuid').AsString;
      AState.IssueDate := Q.FieldByName('doc_date').AsDateTime;
      AState.ProfileCode := Q.FieldByName('profile_code').AsString;
    end;
  finally
    Q.Free;
  end;
end;

procedure TEInvDocumentRepository.SetEInvNo(const ASource: string; AId: Int64; const AEInvNo: string);
var
  Q: TFDQuery;
begin
  SourceColumn(ASource);
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'UPDATE public.' + ASource + ' SET einv_no = :einv_no WHERE id = :id';
    Q.ParamByName('einv_no').AsWideString := AEInvNo;
    Q.ParamByName('id').AsLargeInt := AId;
    LogQuery(Q, 'SetEInvNo');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TEInvDocumentRepository.SetEInvStatus(const ASource: string; AId: Int64; AStatus: Integer);
var
  Q: TFDQuery;
begin
  SourceColumn(ASource);
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'UPDATE public.' + ASource + ' SET einv_status = :einv_status WHERE id = :id';
    Q.ParamByName('einv_status').AsSmallInt := AStatus;
    Q.ParamByName('id').AsLargeInt := AId;
    LogQuery(Q, 'SetEInvStatus');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TEInvDocumentRepository.SaveTransmission(const ASource: string; AId: Int64; const AProviderCode,
  AProviderRef: string; ASent: Boolean; AStatusCode: Integer; const AMessage: string);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text :=
      'UPDATE public.einv_document SET provider_code = :provider_code, ' +
      '       provider_ref = COALESCE(:provider_ref, provider_ref), ' +
      '       sent_at = CASE WHEN :sent THEN now() ELSE sent_at END, ' +
      '       status_code = :status_code, status_message = :status_message, status_at = now() ' +
      ' WHERE ' + SourceColumn(ASource) + ' = :id';
    Q.ParamByName('provider_code').AsWideString := AProviderCode;
    Q.ParamByName('provider_ref').DataType := ftWideString;
    if AProviderRef = '' then
      Q.ParamByName('provider_ref').Clear
    else
      Q.ParamByName('provider_ref').AsWideString := AProviderRef;
    Q.ParamByName('sent').AsBoolean := ASent;
    SetNullableParam(Q.ParamByName('status_code'), ftInteger, AStatusCode);
    Q.ParamByName('status_message').DataType := ftWideMemo;
    if AMessage = '' then
      Q.ParamByName('status_message').Clear
    else
      Q.ParamByName('status_message').AsWideMemo := AMessage;
    Q.ParamByName('id').AsLargeInt := AId;
    LogQuery(Q, 'SaveTransmission');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

function TEInvDocumentRepository.ServiceKindOf(AScope: Integer): string;
var
  Q: TFDQuery;
begin
  Result := '';
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT service_kind FROM public.vw_einv_document_setting WHERE series_scope = :scope ' +
                  '   AND sys_application_setting_id = (SELECT min(id) FROM public.sys_application_setting)';
    Q.ParamByName('scope').AsSmallInt := AScope;
    LogQuery(Q, 'ServiceKindOf');
    Q.Open;
    if not Q.IsEmpty then
      Result := Q.FieldByName('service_kind').AsString;
  finally
    Q.Free;
  end;
end;

// Gönderim etiketleri: gönderici = firmanın belge türü ayarındaki GB etiketi, alıcı = carinin PK etiketi
// (e-İrsaliye kapsamında e-İrsaliye etiketi, diğerlerinde e-Fatura etiketi)
procedure TEInvDocumentRepository.ReadAliases(Q: TFDQuery; AScope: Integer; AAccountId: Int64;
  var ASenderAlias, AReceiverAlias: string);
begin
  Q.Close;
  Q.SQL.Text :=
    'SELECT (SELECT d.sender_alias FROM public.einv_document_setting d ' +
    '         WHERE d.sys_application_setting_id = (SELECT id FROM public.sys_application_setting ORDER BY id LIMIT 1) ' +
    '           AND d.series_scope = :scope) AS sender_alias, ' +
    '       (SELECT CASE WHEN :scope = :despatch_scope THEN a.e_despatch_pk_alias ELSE a.e_invoice_pk_alias END ' +
    '          FROM public.acc_account a WHERE a.id = :account_id) AS receiver_alias';
  Q.ParamByName('scope').AsInteger := AScope;
  Q.ParamByName('despatch_scope').AsInteger := EINV_SERIES_DESPATCH;
  Q.ParamByName('account_id').AsLargeInt := AAccountId;
  LogQuery(Q, 'ReadAliases');
  Q.Open;
  ASenderAlias := FieldText(Q, 'sender_alias');
  AReceiverAlias := FieldText(Q, 'receiver_alias');
end;

function TEInvDocumentRepository.FindByDispatchId(ADispatchId: Int64): TEInvDocument;
var
  Q: TFDQuery;
begin
  Result := nil;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT * FROM ' + Self.GetFullViewName(TEInvDocument) + ' WHERE sls_dispatch_id = :id';
    Q.ParamByName('id').AsLargeInt := ADispatchId;
    LogQuery(Q, 'FindByDispatchId');
    Q.Open;
    if not Q.IsEmpty then
      Result := MapFromQuery(Q);
  finally
    Q.Free;
  end;
end;

procedure TEInvDocumentRepository.SaveForDispatch(ADispatchId: Int64; const AUuid, AEInvNo, AXml: string; AValid: Boolean;
  const AMessage: string);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text :=
      'INSERT INTO public.einv_document (sls_dispatch_id, einv_uuid, einv_no, xml_content, is_valid, validation_message) ' +
      'VALUES (:sls_dispatch_id, :einv_uuid, :einv_no, :xml_content, :is_valid, :validation_message) ' +
      'ON CONFLICT (sls_dispatch_id) DO UPDATE SET einv_uuid = EXCLUDED.einv_uuid, einv_no = EXCLUDED.einv_no, ' +
      '  xml_content = EXCLUDED.xml_content, is_valid = EXCLUDED.is_valid, validation_message = EXCLUDED.validation_message, ' +
      '  generated_at = now()';
    Q.ParamByName('sls_dispatch_id').AsLargeInt := ADispatchId;
    Q.ParamByName('einv_uuid').AsWideString := AUuid;
    Q.ParamByName('einv_no').AsWideString := AEInvNo;
    Q.ParamByName('xml_content').AsWideMemo := AXml;
    Q.ParamByName('is_valid').AsBoolean := AValid;
    Q.ParamByName('validation_message').DataType := ftWideMemo;
    if AMessage = '' then
      Q.ParamByName('validation_message').Clear
    else
      Q.ParamByName('validation_message').AsWideMemo := AMessage;
    LogQuery(Q, 'SaveForDispatch');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TEInvDocumentRepository.DeleteByDispatchId(ADispatchId: Int64);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'DELETE FROM public.einv_document WHERE sls_dispatch_id = :id';
    Q.ParamByName('id').AsLargeInt := ADispatchId;
    LogQuery(Q, 'DeleteByDispatchId');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

function TEInvDocumentRepository.DispatchEInvStatus(ADispatchId: Int64): Integer;
var
  Q: TFDQuery;
begin
  Result := 0;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT COALESCE(einv_status, 0) FROM public.sls_dispatch WHERE id = :id';
    Q.ParamByName('id').AsLargeInt := ADispatchId;
    LogQuery(Q, 'DispatchEInvStatus');
    Q.Open;
    if not Q.IsEmpty then
      Result := Q.Fields[0].AsInteger;
  finally
    Q.Free;
  end;
end;

function TEInvDocumentRepository.LoadSalesInvoice(AInvoiceId: Int64): TEInvUblInvoice;
var
  Q: TFDQuery;
  LAccountId: Int64;
  L: TEInvUblLine;

  function S(const AField: string): string;
  begin
    Result := FieldText(Q, AField);
  end;

  function C(const AField: string): Currency;
  begin
    Result := Q.FieldByName(AField).AsCurrency;
  end;

begin
  Result := nil;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;

    // ---- başlık
    Q.SQL.Text :=
      'SELECT v.invoice_no, v.invoice_date, v.due_date, v.currency, v.exchange_rate, v.description, v.einv_uuid, ' +
      '       f.einv_no, v.profile_code, v.invoice_type_code, v.tax_exemption_code, v.tax_exemption_name, ' +
      '       v.delivery_term_code, tm.code AS transport_mode_code, pm.code AS payment_means_code, ' +
      '       COALESCE(pr.requires_export_info, false) AS requires_export_info, v.acc_account_id, ' +
      '       v.gross_amount, v.discount_amount, v.net_amount, v.vat_amount, v.total_amount, v.withholding_amount ' +
      '  FROM public.vw_sls_invoice v ' +
      '  JOIN public.sls_invoice f ON f.id = v.id ' +
      '  LEFT JOIN public.einv_profile pr ON pr.id = f.einv_profile_id ' +
      '  LEFT JOIN public.einv_transport_mode tm ON tm.id = f.einv_transport_mode_id ' +
      '  LEFT JOIN public.einv_payment_means pm ON pm.id = f.einv_payment_means_id ' +
      ' WHERE v.id = :id';
    Q.ParamByName('id').AsLargeInt := AInvoiceId;
    LogQuery(Q, 'LoadSalesInvoice');
    Q.Open;
    if Q.IsEmpty then
      Exit;
    Result := TEInvUblInvoice.Create;
    try
      Result.InvoiceId := AInvoiceId;
      Result.InvoiceNo := S('invoice_no');
      Result.IssueDate := Q.FieldByName('invoice_date').AsDateTime;
      Result.DueDate := Q.FieldByName('due_date').AsDateTime;
      Result.Currency := TEInvLookup.UblCurrency(S('currency'));
      Result.ExchangeRate := C('exchange_rate');
      Result.Description := S('description');
      Result.Uuid := S('einv_uuid');
      Result.EInvNo := S('einv_no');
      Result.ProfileCode := S('profile_code');
      Result.InvoiceTypeCode := S('invoice_type_code');
      Result.ExemptionCode := S('tax_exemption_code');
      Result.ExemptionName := S('tax_exemption_name');
      Result.DeliveryTermCode := S('delivery_term_code');
      Result.TransportModeCode := S('transport_mode_code');
      Result.PaymentMeansCode := S('payment_means_code');
      Result.IsExport := Q.FieldByName('requires_export_info').AsBoolean;
      Result.GrossAmount := C('gross_amount');
      Result.DiscountAmount := C('discount_amount');
      Result.NetAmount := C('net_amount');
      Result.VatAmount := C('vat_amount');
      Result.TotalAmount := C('total_amount');
      Result.WithholdingAmount := C('withholding_amount');
      LAccountId := Q.FieldByName('acc_account_id').AsLargeInt;

      // ---- satıcı: uygulama ayarları; alıcı: cari + fatura adresi (yoksa birincil / yasal adres)
      ReadSupplier(Q, Result.Supplier);
      ReadAccountParty(Q, LAccountId, 'BILLING', Result.Customer, 'sls_invoice', AInvoiceId);
      // e-Arşiv: kimlik numarası bilinmeyen nihai tüketici
      if Result.Customer.Found and not Result.IsExport and (Result.Customer.TaxNo = '') and
        (Result.ProfileCode = EINV_PROFILE_ARCHIVE) then
      begin
        Result.Customer.TaxNo := EINV_UNKNOWN_TCKN;
        Result.Customer.IsPerson := True;
        if Result.Customer.FirstName = '' then
          SplitName(Result.Customer.Name, Result.Customer);
      end;

      // ---- gönderim etiketleri (e-Arşiv GİB'e raporlanır, etiket yok). IHRACAT: alıcı GTB, carinin etiketi kullanılmaz
      if TEInvLookup.SeriesScopeOf(Result.ProfileCode) <> EINV_SERIES_ARCHIVE then
      begin
        ReadAliases(Q, TEInvLookup.SeriesScopeOf(Result.ProfileCode), LAccountId, Result.SenderAlias, Result.ReceiverAlias);
        if Result.IsExport then
          Result.ReceiverAlias := '';
      end;

      // ---- kalemler (DİİB belge numaraları CustomsDeclaration/ID için)
      Q.Close;
      Q.SQL.Text :=
        'SELECT d.line_no, d.inventory_code, d.inventory_name, d.description, d.quantity, d.uom_code, d.uom_einv_code, ' +
        '       d.unit_price, d.gross_amount, d.discount_rate, d.discount_amount, d.net_amount, d.vat_rate, d.vat_amount, ' +
        '       d.withholding_code, d.withholding_rate, d.withholding_amount, d.gtip_code, d.packaging_type_code, ' +
        '       d.package_no, d.package_quantity, d.package_brand, d.seller_diib_line_code, sd.document_no AS seller_diib_no, ' +
        '       d.buyer_diib_line_code, bd.document_no AS buyer_diib_no ' +
        '  FROM public.vw_sls_invoice_detail d ' +
        '  LEFT JOIN public.vw_einv_diib_line sd ON sd.id = d.seller_einv_diib_line_id ' +
        '  LEFT JOIN public.vw_einv_diib_line bd ON bd.id = d.buyer_einv_diib_line_id ' +
        ' WHERE d.sls_invoice_id = :id ORDER BY d.line_no, d.id';
      Q.ParamByName('id').AsLargeInt := AInvoiceId;
      LogQuery(Q, 'LoadSalesInvoice.Lines');
      Q.Open;
      while not Q.Eof do
      begin
        L := TEInvUblLine.Create;
        Result.Lines.Add(L);
        L.LineNo := Q.FieldByName('line_no').AsInteger;
        L.InventoryCode := S('inventory_code');
        L.InventoryName := S('inventory_name');
        L.Description := S('description');
        L.Quantity := C('quantity');
        L.UomCode := S('uom_code');
        L.UnitCode := S('uom_einv_code');
        L.UnitPrice := C('unit_price');
        L.GrossAmount := C('gross_amount');
        L.DiscountRate := C('discount_rate');
        L.DiscountAmount := C('discount_amount');
        L.NetAmount := C('net_amount');
        L.VatRate := C('vat_rate');
        L.VatAmount := C('vat_amount');
        L.WithholdingCode := S('withholding_code');
        L.WithholdingRate := C('withholding_rate');
        L.WithholdingAmount := C('withholding_amount');
        L.GtipCode := S('gtip_code');
        L.PackagingTypeCode := S('packaging_type_code');
        L.PackageNo := S('package_no');
        L.PackageQuantity := C('package_quantity');
        L.PackageBrand := S('package_brand');
        L.SellerDiibLineCode := S('seller_diib_line_code');
        L.SellerDiibNo := S('seller_diib_no');
        L.BuyerDiibLineCode := S('buyer_diib_line_code');
        L.BuyerDiibNo := S('buyer_diib_no');
        Q.Next;
      end;
    except
      FreeAndNil(Result);
      raise;
    end;
  finally
    Q.Free;
  end;
end;

function TEInvDocumentRepository.LoadSalesDispatch(ADispatchId: Int64): TEInvUblDespatch;
var
  Q: TFDQuery;
  LAccountId, LCarrierId: Int64;
  LDriver: TEInvUblDriver;
  L: TEInvUblDespatchLine;
  LDoc: TEInvUblDespatch;

  function S(const AField: string): string;
  begin
    Result := FieldText(Q, AField);
  end;

  procedure AddTrailer(const APlate: string);
  begin
    if APlate <> '' then
      LDoc.TrailerPlates := LDoc.TrailerPlates + [APlate];
  end;

  procedure AddDriver(const AFirst, AFamily, ANationalId: string);
  begin
    if (AFirst = '') and (AFamily = '') then
      Exit;
    LDriver.FirstName := AFirst;
    LDriver.FamilyName := AFamily;
    LDriver.NationalId := ANationalId;
    LDoc.Drivers := LDoc.Drivers + [LDriver];
  end;

begin
  Result := nil;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;

    // ---- başlık + taşıma
    Q.SQL.Text :=
      'SELECT p.dispatch_no, p.dispatch_date, p.despatch_time, p.description, p.einv_uuid::text AS einv_uuid, p.einv_no, ' +
      '       pr.code AS profile_code, p.acc_account_id, p.carrier_acc_account_id, o.order_no, o.order_date, ' +
      '       v.plate_no AS vehicle_plate, t1.plate_no AS trailer1_plate, t2.plate_no AS trailer2_plate, ' +
      '       d1.first_name AS d1_first, d1.family_name AS d1_family, d1.national_id AS d1_id, ' +
      '       d2.first_name AS d2_first, d2.family_name AS d2_family, d2.national_id AS d2_id ' +
      '  FROM public.sls_dispatch p ' +
      '  LEFT JOIN public.einv_profile pr ON pr.id = p.einv_profile_id ' +
      '  LEFT JOIN public.sls_order o ON o.id = p.sls_order_id ' +
      '  LEFT JOIN public.einv_vehicle v ON v.id = p.einv_vehicle_id ' +
      '  LEFT JOIN public.einv_vehicle t1 ON t1.id = p.trailer1_einv_vehicle_id ' +
      '  LEFT JOIN public.einv_vehicle t2 ON t2.id = p.trailer2_einv_vehicle_id ' +
      '  LEFT JOIN public.einv_driver d1 ON d1.id = p.driver1_einv_driver_id ' +
      '  LEFT JOIN public.einv_driver d2 ON d2.id = p.driver2_einv_driver_id ' +
      ' WHERE p.id = :id';
    Q.ParamByName('id').AsLargeInt := ADispatchId;
    LogQuery(Q, 'LoadSalesDispatch');
    Q.Open;
    if Q.IsEmpty then
      Exit;
    LDoc := TEInvUblDespatch.Create;
    try
      LDoc.DispatchId := ADispatchId;
      LDoc.DispatchNo := S('dispatch_no');
      LDoc.IssueDate := Q.FieldByName('dispatch_date').AsDateTime;
      if not Q.FieldByName('despatch_time').IsNull then
        LDoc.DespatchTime := Frac(Q.FieldByName('despatch_time').AsDateTime);
      LDoc.Description := S('description');
      LDoc.Uuid := S('einv_uuid');
      LDoc.EInvNo := S('einv_no');
      LDoc.ProfileCode := S('profile_code');
      LDoc.OrderNo := S('order_no');
      if not Q.FieldByName('order_date').IsNull then
        LDoc.OrderDate := Q.FieldByName('order_date').AsDateTime;
      LDoc.VehiclePlate := S('vehicle_plate');
      AddTrailer(S('trailer1_plate'));
      AddTrailer(S('trailer2_plate'));
      AddDriver(S('d1_first'), S('d1_family'), S('d1_id'));
      AddDriver(S('d2_first'), S('d2_family'), S('d2_id'));
      LAccountId := Q.FieldByName('acc_account_id').AsLargeInt;
      LCarrierId := Q.FieldByName('carrier_acc_account_id').AsLargeInt;

      // ---- sevk eden: uygulama ayarları; teslim alan: cari + sevk adresi; taşıyıcı: cari
      ReadSupplier(Q, LDoc.Supplier);
      ReadAccountParty(Q, LAccountId, 'SHIPPING', LDoc.Customer, 'sls_dispatch', ADispatchId);
      LDoc.HasCarrier := LCarrierId > 0;
      if LDoc.HasCarrier then
        ReadAccountParty(Q, LCarrierId, 'LEGAL', LDoc.Carrier);
      ReadAliases(Q, EINV_SERIES_DESPATCH, LAccountId, LDoc.SenderAlias, LDoc.ReceiverAlias);

      // ---- kalemler (fiyat yazılmaz)
      Q.Close;
      Q.SQL.Text :=
        'SELECT d.line_no, d.inventory_code, d.inventory_name, d.description, d.quantity, d.uom_code, ' +
        '       u.unit_einv AS uom_einv_code, od.line_no AS order_line_no ' +
        '  FROM public.vw_sls_dispatch_detail d ' +
        '  JOIN public.stk_inventory i ON i.id = d.stk_inventory_id ' +
        '  LEFT JOIN public.sys_uom u ON u.id = i.sys_uom_id ' +
        '  LEFT JOIN public.sls_order_detail od ON od.id = d.sls_order_detail_id ' +
        ' WHERE d.sls_dispatch_id = :id ORDER BY d.line_no, d.id';
      Q.ParamByName('id').AsLargeInt := ADispatchId;
      LogQuery(Q, 'LoadSalesDispatch.Lines');
      Q.Open;
      while not Q.Eof do
      begin
        L := TEInvUblDespatchLine.Create;
        LDoc.Lines.Add(L);
        L.LineNo := Q.FieldByName('line_no').AsInteger;
        L.InventoryCode := S('inventory_code');
        L.InventoryName := S('inventory_name');
        L.Description := S('description');
        L.Quantity := Q.FieldByName('quantity').AsCurrency;
        L.UomCode := S('uom_code');
        L.UnitCode := S('uom_einv_code');
        L.OrderLineNo := Q.FieldByName('order_line_no').AsInteger;
        Q.Next;
      end;
      Result := LDoc;
    except
      LDoc.Free;
      raise;
    end;
  finally
    Q.Free;
  end;
end;

function TEInvDocumentRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TEInvDocument) +
            ' (sls_invoice_id, einv_uuid, einv_no, xml_content, is_valid, validation_message) ' +
            ' VALUES (:sls_invoice_id, :einv_uuid, :einv_no, :xml_content, :is_valid, :validation_message)';
end;

function TEInvDocumentRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TEInvDocument) +
            ' SET sls_invoice_id = :sls_invoice_id, einv_uuid = :einv_uuid, einv_no = :einv_no, xml_content = :xml_content, is_valid = :is_valid, validation_message = :validation_message ' +
            ' WHERE id = :id';
end;

function TEInvDocumentRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TEInvDocument) + ' WHERE';
end;

procedure TEInvDocumentRepository.SetInsertParams(Q: TFDQuery; AModel: TEInvDocument; AIndex: Integer);

begin
  if AIndex < 0 then
  begin
    Q.ParamByName('einv_uuid').AsWideString := AModel.EinvUuid;
    Q.ParamByName('einv_no').AsWideString := AModel.EinvNo;
    Q.ParamByName('xml_content').AsWideString := AModel.XmlContent;
    Q.ParamByName('is_valid').AsBoolean := AModel.IsValid;
    Q.ParamByName('validation_message').AsWideString := AModel.ValidationMessage;
  end
  else
  begin
    Q.ParamByName('einv_uuid').AsWideStrings[AIndex] := AModel.EinvUuid;
    Q.ParamByName('einv_no').AsWideStrings[AIndex] := AModel.EinvNo;
    Q.ParamByName('xml_content').AsWideStrings[AIndex] := AModel.XmlContent;
    Q.ParamByName('is_valid').AsBooleans[AIndex] := AModel.IsValid;
    Q.ParamByName('validation_message').AsWideStrings[AIndex] := AModel.ValidationMessage;
  end;

  SetNullableParam(Q.ParamByName('sls_invoice_id'), ftLargeint, AModel.SlsInvoiceId, AIndex);
end;

procedure TEInvDocumentRepository.SetUpdateParams(Q: TFDQuery; AModel: TEInvDocument; AIndex: Integer);

begin
  if AIndex < 0 then
  begin
    Q.ParamByName('id').AsLargeInt := AModel.Id;
    Q.ParamByName('einv_uuid').AsWideString := AModel.EinvUuid;
    Q.ParamByName('einv_no').AsWideString := AModel.EinvNo;
    Q.ParamByName('xml_content').AsWideString := AModel.XmlContent;
    Q.ParamByName('is_valid').AsBoolean := AModel.IsValid;
    Q.ParamByName('validation_message').AsWideString := AModel.ValidationMessage;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('einv_uuid').AsWideStrings[AIndex] := AModel.EinvUuid;
    Q.ParamByName('einv_no').AsWideStrings[AIndex] := AModel.EinvNo;
    Q.ParamByName('xml_content').AsWideStrings[AIndex] := AModel.XmlContent;
    Q.ParamByName('is_valid').AsBooleans[AIndex] := AModel.IsValid;
    Q.ParamByName('validation_message').AsWideStrings[AIndex] := AModel.ValidationMessage;
  end;

  SetNullableParam(Q.ParamByName('sls_invoice_id'), ftLargeint, AModel.SlsInvoiceId, AIndex);
end;

function TEInvDocumentRepository.MapFromQuery(Q: TFDQuery): TEInvDocument;
begin
  Result := TEInvDocument.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.SlsInvoiceId := Q.FieldByName('sls_invoice_id').AsLargeInt;
  Result.EinvUuid := Q.FieldByName('einv_uuid').AsString;
  Result.EinvNo := Q.FieldByName('einv_no').AsString;
  Result.XmlContent := Q.FieldByName('xml_content').AsString;
  Result.IsValid := Q.FieldByName('is_valid').AsBoolean;
  Result.ValidationMessage := Q.FieldByName('validation_message').AsString;
  Result.GeneratedAt := Q.FieldByName('generated_at').AsString;
  Result.InvoiceNo := Q.FieldByName('invoice_no').AsString;
  Result.SlsDispatchId := Q.FieldByName('sls_dispatch_id').AsLargeInt;
  Result.DispatchNo := Q.FieldByName('dispatch_no').AsString;
  Result.ProviderCode := Q.FieldByName('provider_code').AsString;
  Result.ProviderRef := Q.FieldByName('provider_ref').AsString;
  Result.SentAt := Q.FieldByName('sent_at').AsString;
  Result.StatusCode := Q.FieldByName('status_code').AsInteger;
  Result.StatusMessage := Q.FieldByName('status_message').AsString;
  Result.StatusAt := Q.FieldByName('status_at').AsString;
end;

function TEInvDocumentRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TEInvDocument) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TEInvDocumentRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TEInvDocument>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TEInvDocument>.Create(True);
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := Self.PrepareSelectFromView(AFilter, ALock, False, False);

    if Assigned(AFilter) and (AFilter.Count > 0) then
      for Criteria in AFilter do
        Q.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;

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

function TEInvDocumentRepository.DoFindById(AId: TValue; ALock: Boolean): TEInvDocument;
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
    Q.SQL.Text := Self.PrepareSelectFromView(Criteria, ALock, True, False);

    Q.ParamByName('id').AsLargeInt := AId.AsInt64;
    LogQuery(Q, 'DoFindById');
    Q.Open;

    if not Q.IsEmpty then
      Result := MapFromQuery(Q);
  finally
    Q.Free;
    Criteria.Free;
  end;
end;

function TEInvDocumentRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TEInvDocument;
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
    Q.SQL.Text := Self.PrepareSelectFromView(AFilter, ALock, True, False);

    for Criteria in AFilter do
      Q.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
    LogQuery(Q, 'DoFindOne');
    Q.Open;

    if not Q.IsEmpty then
      Result := MapFromQuery(Q);
  finally
    Q.Free;
  end;
end;

procedure TEInvDocumentRepository.DoAdd(AModel: TEInvDocument);
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
end;

procedure TEInvDocumentRepository.DoAddBatch(AModels: TArray<TEInvDocument>);
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
    Q.SQL.Text := PrepareAddSql;
    Q.Params.ArraySize := Count;

    for I := 0 to Count - 1 do
      SetInsertParams(Q, AModels[I], I);

    ApplyNullPolicy(Q);

    LogQuery(Q, 'DoAddBatch');
    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TEInvDocumentRepository.DoUpdate(AModel: TEInvDocument);
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
end;

procedure TEInvDocumentRepository.DoUpdateBatch(AModels: TArray<TEInvDocument>);
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
end;

procedure TEInvDocumentRepository.DoDelete(AID: TValue);
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

procedure TEInvDocumentRepository.DoDelete(AModel: TEInvDocument);
begin
  Delete(AModel.Id);
end;

procedure TEInvDocumentRepository.DoDeleteBatch(AModels: TArray<TEInvDocument>);
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

procedure TEInvDocumentRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TEInvDocumentRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
