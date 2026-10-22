unit SlsInvoice.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, SlsInvoice;

type
  // Başlıkta seçilen e-belge kodlarının kuralları (tek sorgu; bulunamayan kod Found / Active = False)
  TSlsEInvRules = record
    ProfileFound, ProfileActive, RequiresExportInfo: Boolean;
    ProfileKind: Integer;
    TypeActive, RequiresExemption, RequiresWithholding: Boolean;
    TypeCode: string;
    ExemptionActive, ExemptionRequiresGtip, ExemptionRequiresDiib, ExemptionRequiresZeroVat: Boolean;
    // seçili tipte %0 KDV gerektirmeyen aktif istisna kodu var (555, ÖTV, özel matrah ...): KDV'li faturada da istisna alanı açık
    TypeHasPlainExemption: Boolean;
    ExemptionTypeId: Int64;
    ExemptionCode: string;
    DeliveryActive, DeliveryIsIncoterms: Boolean;
    TransportActive, PaymentActive: Boolean;
  end;

  // e-Belge alanlarının bu faturada uygulanabilirliği (TSlsInvoiceService.GetEInvScope). Formlar alanları buna göre
  // açar / kapatır ve zorunlu işaretler; servis kayıtta uygulanamayan alanları temizler, kural ihlallerini reddeder.
  TSlsEInvScope = record
    IsEDoc: Boolean;                  // senaryo seçili (kağıt fatura değil): fatura tipi, ödeme şekli
    IsExport: Boolean;                // IHRACAT: teslim şartı, taşıma şekli, gümrük çıkış bilgileri
    ExemptionRequired: Boolean;       // tip istisna kodu ister (ISTISNA, IHRACKAYITLI, OZELMATRAH ...)
    ExemptionAvailable: Boolean;      // istisna alanı açık: zorunlu / %0 KDV'li kalem var / tipte KDV'li kod var
    ExemptionNeedsZeroVat: Boolean;   // seçili kod KDV istisnası: en az bir %0 KDV'li kalem
    ExemptionTypeMismatch: Boolean;   // seçili kod başka bir fatura tipine ait
    WithholdingAllowed: Boolean;      // kağıt fatura ya da tevkifat tipi (kalemde ayrıca KDV > 0)
    WithholdingRequired: Boolean;     // tevkifat tipi: en az bir kalemde kod
    CustomsLine: Boolean;             // kalemde GTİP + kap bilgisi (ihracat / GTİP isteyen istisna, ör. 702)
    GtipRequired: Boolean;
    PackageRequired: Boolean;         // ihracat: kap cinsi + adedi
    DiibAllowed: Boolean;             // DİİB satır kodları yalnız DİİB isteyen istisnada (IHRACKAYITLI 702)
    HasZeroVatLine: Boolean;
  end;

  // Fatura kalemine bağlanan DİİB satırı
  TSlsDiibLineInfo = record
    Found, Active, DiibActive: Boolean;
    HolderType: Integer;
    AccountId, GtipId: Int64;
    LineCode, GtipCode: string;
    ValidUntil: TDate;
  end;

  TSlsInvoiceRepository = class(TRepository<TSlsInvoice>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TSlsInvoice; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TSlsInvoice; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TSlsInvoice; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TSlsInvoice>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TSlsInvoice; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TSlsInvoice; override;

    procedure DoAdd(AModel: TSlsInvoice); override;
    procedure DoAddBatch(AModels: TArray<TSlsInvoice>); override;

    procedure DoUpdate(AModel: TSlsInvoice); override;
    procedure DoUpdateBatch(AModels: TArray<TSlsInvoice>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TSlsInvoice); override;
    procedure DoDeleteBatch(AModels: TArray<TSlsInvoice>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
    function NextDocumentNo(const APrefix: string): string;
    function LineCount(AInvoiceId: Int64): Integer;
    function StockLineCount(AInvoiceId: Int64): Integer;
    procedure RecalculateTotals(AInvoiceId: Int64);
    procedure SyncStockTransactions(AInvoiceId: Int64);
    function StockInventoryIdsOfInvoice(AInvoiceId: Int64): TArray<Int64>;
    function OrderIdsOfInvoice(AInvoiceId: Int64): TArray<Int64>;
    // Faturanın irsaliyeli kalemlerinin irsaliyeleri (tekil; irsaliye durumu)
    function DispatchIdsOfInvoice(AInvoiceId: Int64): TArray<Int64>;
    function GetDefaultCurrency: string;
    // Kayıtta faturada olacak cari vergi bilgisi (party_snapshot tetikleyicisiyle aynı kural): kayıtlı faturada cari
    // aynı ve kopya doluysa faturadaki, değilse cari kartındaki
    procedure ReadEffectiveParty(AInvoiceId, AAccountId: Int64; out ATaxpayerType: Integer; out ATaxOffice, ATaxNo: string);

    // ---- e-Belge (UBL-TR) kuralları için okumalar
    function ReadEInvRules(AProfileId, ATypeId, AExemptionId, ADeliveryTermId, ATransportModeId, APaymentMeansId: Int64): TSlsEInvRules;
    function ReadDiibLine(AId: Int64): TSlsDiibLineInfo;
    function ReadWithholding(AId: Int64; out ARate: Currency; out AActive: Boolean; out ACode: string): Boolean;
    function ReadInventoryGtip(AInventoryId: Int64; out AGtipId: Int64; out AGtipCode: string): Boolean;
    // einv_gtip / einv_packaging_type kaydı aktif mi (yalnız bu iki tablo)
    function IsEInvCodeActive(const ATable: string; AId: Int64): Boolean;
    // Aktif senaryo / fatura tipi id'si koddan (yoksa 0; yalnız einv_profile / einv_invoice_type)
    function EInvIdByCode(const ATable, ACode: string): Int64;
  end;

implementation

constructor TSlsInvoiceRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSlsInvoiceRepository.NextDocumentNo(const APrefix: string): string;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT :prefix || lpad((COALESCE(MAX(CAST(substr(invoice_no, length(:prefix) + 1) AS bigint)), 0) + 1)::text, 6, ''0'') AS v ' +
                  '  FROM public.sls_invoice WHERE invoice_no ~ (''^'' || :prefix || ''[0-9]+$'')';
    Q.ParamByName('prefix').DataType := ftWideString;
    Q.ParamByName('prefix').AsWideString := APrefix;
    LogQuery(Q, 'NextDocumentNo');
    Q.Open;
    Result := Q.FieldByName('v').AsString;
  finally
    Q.Free;
  end;
end;

function TSlsInvoiceRepository.LineCount(AInvoiceId: Int64): Integer;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT count(*) AS v FROM public.sls_invoice_detail WHERE sls_invoice_id = :id';
    Q.ParamByName('id').AsLargeInt := AInvoiceId;
    LogQuery(Q, 'LineCount');
    Q.Open;
    Result := Q.FieldByName('v').AsInteger;
  finally
    Q.Free;
  end;
end;

function TSlsInvoiceRepository.StockLineCount(AInvoiceId: Int64): Integer;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT count(*) AS v FROM public.sls_invoice_detail WHERE sls_invoice_id = :id AND sls_dispatch_detail_id IS NULL';
    Q.ParamByName('id').AsLargeInt := AInvoiceId;
    LogQuery(Q, 'StockLineCount');
    Q.Open;
    Result := Q.FieldByName('v').AsInteger;
  finally
    Q.Free;
  end;
end;

procedure TSlsInvoiceRepository.RecalculateTotals(AInvoiceId: Int64);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'UPDATE public.sls_invoice f SET ' +
                  '       gross_amount = s.gross, discount_amount = s.disc, net_amount = s.net, vat_amount = s.vat, total_amount = s.total, ' +
                  '       withholding_amount = s.wh ' +
                  '  FROM (SELECT COALESCE(sum(gross_amount), 0) AS gross, COALESCE(sum(discount_amount), 0) AS disc, ' +
                  '               COALESCE(sum(net_amount), 0) AS net, COALESCE(sum(vat_amount), 0) AS vat, COALESCE(sum(total_amount), 0) AS total, ' +
                  '               COALESCE(sum(withholding_amount), 0) AS wh ' +
                  '          FROM public.sls_invoice_detail WHERE sls_invoice_id = :id) s ' +
                  ' WHERE f.id = :id';
    Q.ParamByName('id').AsLargeInt := AInvoiceId;
    LogQuery(Q, 'RecalculateTotals');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TSlsInvoiceRepository.SyncStockTransactions(AInvoiceId: Int64);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'UPDATE public.stk_transaction t ' +
                  '   SET transaction_date = f.invoice_date, from_stk_warehouse_id = f.stk_warehouse_id, currency = f.currency, ' +
                  '       description = f.invoice_no ' +
                  '  FROM public.sls_invoice_detail d JOIN public.sls_invoice f ON f.id = d.sls_invoice_id ' +
                  ' WHERE t.sls_invoice_detail_id = d.id AND f.id = :id';
    Q.ParamByName('id').AsLargeInt := AInvoiceId;
    LogQuery(Q, 'SyncStockTransactions');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

function TSlsInvoiceRepository.StockInventoryIdsOfInvoice(AInvoiceId: Int64): TArray<Int64>;
var
  Q: TFDQuery;
begin
  Result := [];
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT DISTINCT stk_inventory_id FROM public.sls_invoice_detail WHERE sls_invoice_id = :id AND sls_dispatch_detail_id IS NULL';
    Q.ParamByName('id').AsLargeInt := AInvoiceId;
    LogQuery(Q, 'StockInventoryIdsOfInvoice');
    Q.Open;
    while not Q.Eof do
    begin
      Result := Result + [Q.Fields[0].AsLargeInt];
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

function TSlsInvoiceRepository.OrderIdsOfInvoice(AInvoiceId: Int64): TArray<Int64>;
var
  Q: TFDQuery;
begin
  Result := [];
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT DISTINCT od.sls_order_id FROM public.sls_invoice_detail d ' +
                  '  JOIN public.sls_order_detail od ON od.id = d.sls_order_detail_id WHERE d.sls_invoice_id = :id';
    Q.ParamByName('id').AsLargeInt := AInvoiceId;
    LogQuery(Q, 'OrderIdsOfInvoice');
    Q.Open;
    while not Q.Eof do
    begin
      Result := Result + [Q.Fields[0].AsLargeInt];
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

function TSlsInvoiceRepository.DispatchIdsOfInvoice(AInvoiceId: Int64): TArray<Int64>;
var
  Q: TFDQuery;
  n: Integer;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT DISTINCT dd.sls_dispatch_id FROM public.sls_invoice_detail i ' +
                  '  JOIN public.sls_dispatch_detail dd ON dd.id = i.sls_dispatch_detail_id WHERE i.sls_invoice_id = :id';
    Q.ParamByName('id').AsLargeInt := AInvoiceId;
    LogQuery(Q, 'DispatchIdsOfInvoice');
    Q.Open;
    SetLength(Result, Q.RecordCount);
    n := 0;
    while not Q.Eof do
    begin
      Result[n] := Q.Fields[0].AsLargeInt;
      Inc(n);
      Q.Next;
    end;
    SetLength(Result, n);
  finally
    Q.Free;
  end;
end;

function TSlsInvoiceRepository.GetDefaultCurrency: string;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT public.fn_default_currency() AS currency';
    LogQuery(Q, 'GetDefaultCurrency');
    Q.Open;
    Result := Q.FieldByName('currency').AsString;
  finally
    Q.Free;
  end;
end;

procedure TSlsInvoiceRepository.ReadEffectiveParty(AInvoiceId, AAccountId: Int64; out ATaxpayerType: Integer;
  out ATaxOffice, ATaxNo: string);
var
  Q: TFDQuery;
begin
  ATaxpayerType := 0;
  ATaxOffice := '';
  ATaxNo := '';
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text :=
      'SELECT x.taxpayer_type, x.tax_office, x.tax_no FROM (' +
      '  SELECT 1 AS pri, d.taxpayer_type, d.tax_office, d.tax_no FROM public.sls_invoice d ' +
      '   WHERE d.id = :invoice_id AND d.acc_account_id = :account_id AND d.account_title IS NOT NULL ' +
      '  UNION ALL ' +
      '  SELECT 2, p.taxpayer_type, p.tax_office, p.tax_no FROM public.fn_acc_account_party(:account_id) p' +
      ') x ORDER BY x.pri LIMIT 1';
    Q.ParamByName('invoice_id').AsLargeInt := AInvoiceId;
    Q.ParamByName('account_id').AsLargeInt := AAccountId;
    LogQuery(Q, 'ReadEffectiveParty');
    Q.Open;
    if not Q.IsEmpty then
    begin
      ATaxpayerType := Q.FieldByName('taxpayer_type').AsInteger;
      ATaxOffice := Q.FieldByName('tax_office').AsString;
      ATaxNo := Q.FieldByName('tax_no').AsString;
    end;
  finally
    Q.Free;
  end;
end;

function TSlsInvoiceRepository.ReadEInvRules(AProfileId, ATypeId, AExemptionId, ADeliveryTermId, ATransportModeId,
  APaymentMeansId: Int64): TSlsEInvRules;
var
  Q: TFDQuery;
begin
  Result := Default(TSlsEInvRules);
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text :=
      'SELECT p.id IS NOT NULL AS profile_found, COALESCE(p.is_active, false) AS profile_active, ' +
      '       COALESCE(p.requires_export_info, false) AS requires_export_info, COALESCE(p.document_kind, 0) AS profile_kind, ' +
      '       COALESCE(t.is_active, false) AS type_active, COALESCE(t.requires_exemption, false) AS requires_exemption, ' +
      '       COALESCE(t.requires_withholding, false) AS requires_withholding, COALESCE(t.code, '''') AS type_code, ' +
      '       COALESCE(e.is_active, false) AS exemption_active, COALESCE(e.requires_gtip, false) AS exemption_requires_gtip, ' +
      '       COALESCE(e.requires_diib, false) AS exemption_requires_diib, COALESCE(e.einv_invoice_type_id, 0) AS exemption_type_id, ' +
      '       COALESCE(e.code, '''') AS exemption_code, COALESCE(e.requires_zero_vat, false) AS exemption_requires_zero_vat, ' +
      '       EXISTS (SELECT 1 FROM public.einv_tax_exemption pe WHERE pe.is_active AND NOT pe.requires_zero_vat ' +
      '                  AND (pe.einv_invoice_type_id = :type_id OR pe.einv_invoice_type_id IS NULL)) AS type_has_plain_exemption, ' +
      '       COALESCE(d.is_active, false) AS delivery_active, COALESCE(d.is_incoterms, false) AS delivery_is_incoterms, ' +
      '       COALESCE(m.is_active, false) AS transport_active, COALESCE(pm.is_active, false) AS payment_active ' +
      '  FROM (SELECT 1) x ' +
      '  LEFT JOIN public.einv_profile p ON p.id = :profile_id ' +
      '  LEFT JOIN public.einv_invoice_type t ON t.id = :type_id ' +
      '  LEFT JOIN public.einv_tax_exemption e ON e.id = :exemption_id ' +
      '  LEFT JOIN public.einv_delivery_term d ON d.id = :delivery_term_id ' +
      '  LEFT JOIN public.einv_transport_mode m ON m.id = :transport_mode_id ' +
      '  LEFT JOIN public.einv_payment_means pm ON pm.id = :payment_means_id';
    Q.ParamByName('profile_id').AsLargeInt := AProfileId;
    Q.ParamByName('type_id').AsLargeInt := ATypeId;
    Q.ParamByName('exemption_id').AsLargeInt := AExemptionId;
    Q.ParamByName('delivery_term_id').AsLargeInt := ADeliveryTermId;
    Q.ParamByName('transport_mode_id').AsLargeInt := ATransportModeId;
    Q.ParamByName('payment_means_id').AsLargeInt := APaymentMeansId;
    LogQuery(Q, 'ReadEInvRules');
    Q.Open;
    Result.ProfileFound := Q.FieldByName('profile_found').AsBoolean;
    Result.ProfileActive := Q.FieldByName('profile_active').AsBoolean;
    Result.RequiresExportInfo := Q.FieldByName('requires_export_info').AsBoolean;
    Result.ProfileKind := Q.FieldByName('profile_kind').AsInteger;
    Result.TypeActive := Q.FieldByName('type_active').AsBoolean;
    Result.RequiresExemption := Q.FieldByName('requires_exemption').AsBoolean;
    Result.RequiresWithholding := Q.FieldByName('requires_withholding').AsBoolean;
    Result.TypeCode := Q.FieldByName('type_code').AsString;
    Result.ExemptionActive := Q.FieldByName('exemption_active').AsBoolean;
    Result.ExemptionRequiresGtip := Q.FieldByName('exemption_requires_gtip').AsBoolean;
    Result.ExemptionRequiresDiib := Q.FieldByName('exemption_requires_diib').AsBoolean;
    Result.ExemptionTypeId := Q.FieldByName('exemption_type_id').AsLargeInt;
    Result.ExemptionCode := Q.FieldByName('exemption_code').AsString;
    Result.ExemptionRequiresZeroVat := Q.FieldByName('exemption_requires_zero_vat').AsBoolean;
    Result.TypeHasPlainExemption := Q.FieldByName('type_has_plain_exemption').AsBoolean;
    Result.DeliveryActive := Q.FieldByName('delivery_active').AsBoolean;
    Result.DeliveryIsIncoterms := Q.FieldByName('delivery_is_incoterms').AsBoolean;
    Result.TransportActive := Q.FieldByName('transport_active').AsBoolean;
    Result.PaymentActive := Q.FieldByName('payment_active').AsBoolean;
  finally
    Q.Free;
  end;
end;

function TSlsInvoiceRepository.ReadDiibLine(AId: Int64): TSlsDiibLineInfo;
var
  Q: TFDQuery;
begin
  Result := Default(TSlsDiibLineInfo);
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT is_active, diib_is_active, holder_type, acc_account_id, einv_gtip_id, line_code, gtip_code, valid_until ' +
                  '  FROM public.vw_einv_diib_line WHERE id = :id';
    Q.ParamByName('id').AsLargeInt := AId;
    LogQuery(Q, 'ReadDiibLine');
    Q.Open;
    if Q.IsEmpty then
      Exit;
    Result.Found := True;
    Result.Active := Q.FieldByName('is_active').AsBoolean;
    Result.DiibActive := Q.FieldByName('diib_is_active').AsBoolean;
    Result.HolderType := Q.FieldByName('holder_type').AsInteger;
    Result.AccountId := Q.FieldByName('acc_account_id').AsLargeInt;
    Result.GtipId := Q.FieldByName('einv_gtip_id').AsLargeInt;
    Result.LineCode := Q.FieldByName('line_code').AsString;
    Result.GtipCode := Q.FieldByName('gtip_code').AsString;
    if Q.FieldByName('valid_until').IsNull then
      Result.ValidUntil := 0
    else
      Result.ValidUntil := Q.FieldByName('valid_until').AsDateTime;
  finally
    Q.Free;
  end;
end;

function TSlsInvoiceRepository.ReadWithholding(AId: Int64; out ARate: Currency; out AActive: Boolean; out ACode: string): Boolean;
var
  Q: TFDQuery;
begin
  ARate := 0;
  AActive := False;
  ACode := '';
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT code, rate, is_active FROM public.einv_withholding WHERE id = :id';
    Q.ParamByName('id').AsLargeInt := AId;
    LogQuery(Q, 'ReadWithholding');
    Q.Open;
    Result := not Q.IsEmpty;
    if Result then
    begin
      ARate := Q.FieldByName('rate').AsCurrency;
      AActive := Q.FieldByName('is_active').AsBoolean;
      ACode := Q.FieldByName('code').AsString;
    end;
  finally
    Q.Free;
  end;
end;

function TSlsInvoiceRepository.ReadInventoryGtip(AInventoryId: Int64; out AGtipId: Int64; out AGtipCode: string): Boolean;
var
  Q: TFDQuery;
begin
  AGtipId := 0;
  AGtipCode := '';
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT i.einv_gtip_id, g.code FROM public.stk_inventory i JOIN public.einv_gtip g ON g.id = i.einv_gtip_id ' +
                  ' WHERE i.id = :id';
    Q.ParamByName('id').AsLargeInt := AInventoryId;
    LogQuery(Q, 'ReadInventoryGtip');
    Q.Open;
    Result := not Q.IsEmpty;
    if Result then
    begin
      AGtipId := Q.Fields[0].AsLargeInt;
      AGtipCode := Q.Fields[1].AsString;
    end;
  finally
    Q.Free;
  end;
end;

function TSlsInvoiceRepository.IsEInvCodeActive(const ATable: string; AId: Int64): Boolean;
var
  Q: TFDQuery;
begin
  if not SameText(ATable, 'einv_gtip') and not SameText(ATable, 'einv_packaging_type') then
    raise Exception.Create('IsEInvCodeActive: ' + ATable);
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT is_active FROM public.' + LowerCase(ATable) + ' WHERE id = :id';
    Q.ParamByName('id').AsLargeInt := AId;
    LogQuery(Q, 'IsEInvCodeActive');
    Q.Open;
    Result := (not Q.IsEmpty) and Q.Fields[0].AsBoolean;
  finally
    Q.Free;
  end;
end;

function TSlsInvoiceRepository.EInvIdByCode(const ATable, ACode: string): Int64;
var
  Q: TFDQuery;
begin
  if not SameText(ATable, 'einv_profile') and not SameText(ATable, 'einv_invoice_type') then
    raise Exception.Create('EInvIdByCode: ' + ATable);
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT id FROM public.' + LowerCase(ATable) + ' WHERE code = :code AND is_active';
    Q.ParamByName('code').AsWideString := ACode;
    LogQuery(Q, 'EInvIdByCode');
    Q.Open;
    if Q.IsEmpty then
      Result := 0
    else
      Result := Q.Fields[0].AsLargeInt;
  finally
    Q.Free;
  end;
end;

function TSlsInvoiceRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TSlsInvoice) +
            ' (invoice_no, invoice_date, acc_account_id, due_date, stk_warehouse_id, currency, exchange_rate, gross_amount, discount_amount, net_amount, vat_amount, total_amount, description, einv_profile_id, einv_invoice_type_id, einv_uuid, einv_status, einv_tax_exemption_id, einv_delivery_term_id, einv_transport_mode_id, einv_payment_means_id, customs_declaration_no, gtb_ref_no, actual_export_date, withholding_amount) ' +
            ' VALUES (:invoice_no, :invoice_date, :acc_account_id, :due_date, :stk_warehouse_id, :currency, :exchange_rate, :gross_amount, :discount_amount, :net_amount, :vat_amount, :total_amount, :description, :einv_profile_id, :einv_invoice_type_id, CAST(:einv_uuid AS uuid), :einv_status, :einv_tax_exemption_id, :einv_delivery_term_id, :einv_transport_mode_id, :einv_payment_means_id, :customs_declaration_no, :gtb_ref_no, :actual_export_date, :withholding_amount)';
end;

function TSlsInvoiceRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TSlsInvoice) +
            ' SET invoice_no = :invoice_no, invoice_date = :invoice_date, acc_account_id = :acc_account_id, due_date = :due_date, stk_warehouse_id = :stk_warehouse_id, currency = :currency, exchange_rate = :exchange_rate, gross_amount = :gross_amount, discount_amount = :discount_amount, net_amount = :net_amount, vat_amount = :vat_amount, total_amount = :total_amount, description = :description, einv_profile_id = :einv_profile_id, einv_invoice_type_id = :einv_invoice_type_id, einv_uuid = CAST(:einv_uuid AS uuid), einv_status = :einv_status, einv_tax_exemption_id = :einv_tax_exemption_id, einv_delivery_term_id = :einv_delivery_term_id, einv_transport_mode_id = :einv_transport_mode_id, einv_payment_means_id = :einv_payment_means_id, customs_declaration_no = :customs_declaration_no, gtb_ref_no = :gtb_ref_no, actual_export_date = :actual_export_date, withholding_amount = :withholding_amount ' +
            ' WHERE id = :id';
end;

function TSlsInvoiceRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TSlsInvoice) + ' WHERE';
end;

procedure TSlsInvoiceRepository.SetInsertParams(Q: TFDQuery; AModel: TSlsInvoice; AIndex: Integer);

  procedure SetDate(const AName: string; AValue: TDate);
  begin
    Q.ParamByName(AName).DataType := ftDate;
    if AValue > 0 then
    begin
      if AIndex < 0 then
        Q.ParamByName(AName).AsDate := AValue
      else
        Q.ParamByName(AName).AsDates[AIndex] := AValue;
    end
    else if AIndex < 0 then
      Q.ParamByName(AName).Clear
    else
      Q.ParamByName(AName).Clear(AIndex);
  end;

  // uuid kolonu: boş = NULL (SQL tarafında CAST(:x AS uuid))
  procedure SetUuid(const AName: string; const AValue: string);
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
    Q.ParamByName('invoice_no').AsWideString := AModel.InvoiceNo;
    Q.ParamByName('currency').AsWideString := AModel.Currency;
    Q.ParamByName('exchange_rate').AsBCD := AModel.ExchangeRate;
    Q.ParamByName('gross_amount').AsBCD := AModel.GrossAmount;
    Q.ParamByName('discount_amount').AsBCD := AModel.DiscountAmount;
    Q.ParamByName('net_amount').AsBCD := AModel.NetAmount;
    Q.ParamByName('vat_amount').AsBCD := AModel.VatAmount;
    Q.ParamByName('total_amount').AsBCD := AModel.TotalAmount;
    Q.ParamByName('description').AsWideString := AModel.Description;
    Q.ParamByName('einv_status').AsSmallInt := AModel.EinvStatus;
    Q.ParamByName('customs_declaration_no').AsWideString := AModel.CustomsDeclarationNo;
    Q.ParamByName('gtb_ref_no').AsWideString := AModel.GtbRefNo;
    Q.ParamByName('withholding_amount').AsBCD := AModel.WithholdingAmount;
  end
  else
  begin
    Q.ParamByName('invoice_no').AsWideStrings[AIndex] := AModel.InvoiceNo;
    Q.ParamByName('currency').AsWideStrings[AIndex] := AModel.Currency;
    Q.ParamByName('exchange_rate').AsBCDs[AIndex] := AModel.ExchangeRate;
    Q.ParamByName('gross_amount').AsBCDs[AIndex] := AModel.GrossAmount;
    Q.ParamByName('discount_amount').AsBCDs[AIndex] := AModel.DiscountAmount;
    Q.ParamByName('net_amount').AsBCDs[AIndex] := AModel.NetAmount;
    Q.ParamByName('vat_amount').AsBCDs[AIndex] := AModel.VatAmount;
    Q.ParamByName('total_amount').AsBCDs[AIndex] := AModel.TotalAmount;
    Q.ParamByName('description').AsWideStrings[AIndex] := AModel.Description;
    Q.ParamByName('einv_status').AsSmallInts[AIndex] := AModel.EinvStatus;
    Q.ParamByName('customs_declaration_no').AsWideStrings[AIndex] := AModel.CustomsDeclarationNo;
    Q.ParamByName('gtb_ref_no').AsWideStrings[AIndex] := AModel.GtbRefNo;
    Q.ParamByName('withholding_amount').AsBCDs[AIndex] := AModel.WithholdingAmount;
  end;

  SetDate('invoice_date', AModel.InvoiceDate);
  SetNullableParam(Q.ParamByName('acc_account_id'), ftLargeint, AModel.AccAccountId, AIndex);
  SetDate('due_date', AModel.DueDate);
  SetNullableParam(Q.ParamByName('stk_warehouse_id'), ftLargeint, AModel.StkWarehouseId, AIndex);
  SetNullableParam(Q.ParamByName('einv_profile_id'), ftLargeint, AModel.EinvProfileId, AIndex);
  SetNullableParam(Q.ParamByName('einv_invoice_type_id'), ftLargeint, AModel.EinvInvoiceTypeId, AIndex);
  SetUuid('einv_uuid', AModel.EinvUuid);
  SetNullableParam(Q.ParamByName('einv_tax_exemption_id'), ftLargeint, AModel.EinvTaxExemptionId, AIndex);
  SetNullableParam(Q.ParamByName('einv_delivery_term_id'), ftLargeint, AModel.EinvDeliveryTermId, AIndex);
  SetNullableParam(Q.ParamByName('einv_transport_mode_id'), ftLargeint, AModel.EinvTransportModeId, AIndex);
  SetNullableParam(Q.ParamByName('einv_payment_means_id'), ftLargeint, AModel.EinvPaymentMeansId, AIndex);
  SetDate('actual_export_date', AModel.ActualExportDate);
end;

procedure TSlsInvoiceRepository.SetUpdateParams(Q: TFDQuery; AModel: TSlsInvoice; AIndex: Integer);

  procedure SetDate(const AName: string; AValue: TDate);
  begin
    Q.ParamByName(AName).DataType := ftDate;
    if AValue > 0 then
    begin
      if AIndex < 0 then
        Q.ParamByName(AName).AsDate := AValue
      else
        Q.ParamByName(AName).AsDates[AIndex] := AValue;
    end
    else if AIndex < 0 then
      Q.ParamByName(AName).Clear
    else
      Q.ParamByName(AName).Clear(AIndex);
  end;

  // uuid kolonu: boş = NULL (SQL tarafında CAST(:x AS uuid))
  procedure SetUuid(const AName: string; const AValue: string);
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
    Q.ParamByName('invoice_no').AsWideString := AModel.InvoiceNo;
    Q.ParamByName('currency').AsWideString := AModel.Currency;
    Q.ParamByName('exchange_rate').AsBCD := AModel.ExchangeRate;
    Q.ParamByName('gross_amount').AsBCD := AModel.GrossAmount;
    Q.ParamByName('discount_amount').AsBCD := AModel.DiscountAmount;
    Q.ParamByName('net_amount').AsBCD := AModel.NetAmount;
    Q.ParamByName('vat_amount').AsBCD := AModel.VatAmount;
    Q.ParamByName('total_amount').AsBCD := AModel.TotalAmount;
    Q.ParamByName('description').AsWideString := AModel.Description;
    Q.ParamByName('einv_status').AsSmallInt := AModel.EinvStatus;
    Q.ParamByName('customs_declaration_no').AsWideString := AModel.CustomsDeclarationNo;
    Q.ParamByName('gtb_ref_no').AsWideString := AModel.GtbRefNo;
    Q.ParamByName('withholding_amount').AsBCD := AModel.WithholdingAmount;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('invoice_no').AsWideStrings[AIndex] := AModel.InvoiceNo;
    Q.ParamByName('currency').AsWideStrings[AIndex] := AModel.Currency;
    Q.ParamByName('exchange_rate').AsBCDs[AIndex] := AModel.ExchangeRate;
    Q.ParamByName('gross_amount').AsBCDs[AIndex] := AModel.GrossAmount;
    Q.ParamByName('discount_amount').AsBCDs[AIndex] := AModel.DiscountAmount;
    Q.ParamByName('net_amount').AsBCDs[AIndex] := AModel.NetAmount;
    Q.ParamByName('vat_amount').AsBCDs[AIndex] := AModel.VatAmount;
    Q.ParamByName('total_amount').AsBCDs[AIndex] := AModel.TotalAmount;
    Q.ParamByName('description').AsWideStrings[AIndex] := AModel.Description;
    Q.ParamByName('einv_status').AsSmallInts[AIndex] := AModel.EinvStatus;
    Q.ParamByName('customs_declaration_no').AsWideStrings[AIndex] := AModel.CustomsDeclarationNo;
    Q.ParamByName('gtb_ref_no').AsWideStrings[AIndex] := AModel.GtbRefNo;
    Q.ParamByName('withholding_amount').AsBCDs[AIndex] := AModel.WithholdingAmount;
  end;

  SetDate('invoice_date', AModel.InvoiceDate);
  SetNullableParam(Q.ParamByName('acc_account_id'), ftLargeint, AModel.AccAccountId, AIndex);
  SetDate('due_date', AModel.DueDate);
  SetNullableParam(Q.ParamByName('stk_warehouse_id'), ftLargeint, AModel.StkWarehouseId, AIndex);
  SetNullableParam(Q.ParamByName('einv_profile_id'), ftLargeint, AModel.EinvProfileId, AIndex);
  SetNullableParam(Q.ParamByName('einv_invoice_type_id'), ftLargeint, AModel.EinvInvoiceTypeId, AIndex);
  SetUuid('einv_uuid', AModel.EinvUuid);
  SetNullableParam(Q.ParamByName('einv_tax_exemption_id'), ftLargeint, AModel.EinvTaxExemptionId, AIndex);
  SetNullableParam(Q.ParamByName('einv_delivery_term_id'), ftLargeint, AModel.EinvDeliveryTermId, AIndex);
  SetNullableParam(Q.ParamByName('einv_transport_mode_id'), ftLargeint, AModel.EinvTransportModeId, AIndex);
  SetNullableParam(Q.ParamByName('einv_payment_means_id'), ftLargeint, AModel.EinvPaymentMeansId, AIndex);
  SetDate('actual_export_date', AModel.ActualExportDate);
end;

function TSlsInvoiceRepository.MapFromQuery(Q: TFDQuery): TSlsInvoice;
begin
  Result := TSlsInvoice.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.InvoiceNo := Q.FieldByName('invoice_no').AsString;
  if Q.FieldByName('invoice_date').IsNull then
    Result.InvoiceDate := 0
  else
    Result.InvoiceDate := Q.FieldByName('invoice_date').AsDateTime;
  Result.AccAccountId := Q.FieldByName('acc_account_id').AsLargeInt;
  if Q.FieldByName('due_date').IsNull then
    Result.DueDate := 0
  else
    Result.DueDate := Q.FieldByName('due_date').AsDateTime;
  Result.StkWarehouseId := Q.FieldByName('stk_warehouse_id').AsLargeInt;
  Result.Currency := Q.FieldByName('currency').AsString;
  Result.ExchangeRate := Q.FieldByName('exchange_rate').AsCurrency;
  Result.GrossAmount := Q.FieldByName('gross_amount').AsCurrency;
  Result.DiscountAmount := Q.FieldByName('discount_amount').AsCurrency;
  Result.NetAmount := Q.FieldByName('net_amount').AsCurrency;
  Result.VatAmount := Q.FieldByName('vat_amount').AsCurrency;
  Result.TotalAmount := Q.FieldByName('total_amount').AsCurrency;
  Result.Description := Q.FieldByName('description').AsString;
  Result.AccountCode := Q.FieldByName('account_code').AsString;
  Result.AccountName := Q.FieldByName('account_name').AsString;
  Result.AccountTitle := Q.FieldByName('account_title').AsString;
  Result.TaxpayerType := Q.FieldByName('taxpayer_type').AsInteger;
  Result.TaxOffice := Q.FieldByName('tax_office').AsString;
  Result.TaxNo := Q.FieldByName('tax_no').AsString;
  Result.WarehouseName := Q.FieldByName('warehouse_name').AsString;
  Result.EinvProfileId := Q.FieldByName('einv_profile_id').AsLargeInt;
  Result.EinvInvoiceTypeId := Q.FieldByName('einv_invoice_type_id').AsLargeInt;
  Result.EinvUuid := LowerCase(Q.FieldByName('einv_uuid').AsString.Replace('{', '').Replace('}', ''));
  Result.EinvStatus := Q.FieldByName('einv_status').AsInteger;
  Result.EinvTaxExemptionId := Q.FieldByName('einv_tax_exemption_id').AsLargeInt;
  Result.EinvDeliveryTermId := Q.FieldByName('einv_delivery_term_id').AsLargeInt;
  Result.EinvTransportModeId := Q.FieldByName('einv_transport_mode_id').AsLargeInt;
  Result.EinvPaymentMeansId := Q.FieldByName('einv_payment_means_id').AsLargeInt;
  Result.CustomsDeclarationNo := Q.FieldByName('customs_declaration_no').AsString;
  Result.GtbRefNo := Q.FieldByName('gtb_ref_no').AsString;
  if Q.FieldByName('actual_export_date').IsNull then
    Result.ActualExportDate := 0
  else
    Result.ActualExportDate := Q.FieldByName('actual_export_date').AsDateTime;
  Result.WithholdingAmount := Q.FieldByName('withholding_amount').AsCurrency;
  Result.ProfileCode := Q.FieldByName('profile_code').AsString;
  Result.InvoiceTypeCode := Q.FieldByName('invoice_type_code').AsString;
  Result.TaxExemptionCode := Q.FieldByName('tax_exemption_code').AsString;
  Result.TaxExemptionName := Q.FieldByName('tax_exemption_name').AsString;
  Result.DeliveryTermCode := Q.FieldByName('delivery_term_code').AsString;
  Result.TransportModeName := Q.FieldByName('transport_mode_name').AsString;
  Result.PaymentMeansName := Q.FieldByName('payment_means_name').AsString;
  Result.PayableAmount := Q.FieldByName('payable_amount').AsCurrency;
  Result.AccountEInvoiceActive := Q.FieldByName('account_e_invoice_active').AsBoolean;
end;

function TSlsInvoiceRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TSlsInvoice) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TSlsInvoiceRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TSlsInvoice>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TSlsInvoice>.Create(True);
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

function TSlsInvoiceRepository.DoFindById(AId: TValue; ALock: Boolean): TSlsInvoice;
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

function TSlsInvoiceRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TSlsInvoice;
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

procedure TSlsInvoiceRepository.DoAdd(AModel: TSlsInvoice);
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

procedure TSlsInvoiceRepository.DoAddBatch(AModels: TArray<TSlsInvoice>);
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

procedure TSlsInvoiceRepository.DoUpdate(AModel: TSlsInvoice);
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

procedure TSlsInvoiceRepository.DoUpdateBatch(AModels: TArray<TSlsInvoice>);
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

procedure TSlsInvoiceRepository.DoDelete(AID: TValue);
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

procedure TSlsInvoiceRepository.DoDelete(AModel: TSlsInvoice);
begin
  Delete(AModel.Id);
end;

procedure TSlsInvoiceRepository.DoDeleteBatch(AModels: TArray<TSlsInvoice>);
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

procedure TSlsInvoiceRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TSlsInvoiceRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
