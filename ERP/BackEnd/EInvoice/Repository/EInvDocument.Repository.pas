unit EInvDocument.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, EInvDocument, EInvUbl.Model;

type
  TEInvDocumentRepository = class(TRepository<TEInvDocument>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TEInvDocument; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TEInvDocument; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TEInvDocument; override;

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

function TEInvDocumentRepository.LoadSalesInvoice(AInvoiceId: Int64): TEInvUblInvoice;
var
  Q: TFDQuery;
  LAccountId, LSellerAddressId, LCustomerAddressId: Int64;
  L: TEInvUblLine;

  function S(const AField: string): string;
  begin
    Result := Trim(Q.FieldByName(AField).AsString);
  end;

  function C(const AField: string): Currency;
  begin
    Result := Q.FieldByName(AField).AsCurrency;
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

  procedure ReadAddress(AAddressId: Int64; var AParty: TEInvUblParty);
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
    LogQuery(Q, 'LoadSalesInvoice.Address');
    Q.Open;
    if Q.IsEmpty then
      Exit;
    AParty.Address.StreetName := JoinText([S('neighborhood'), S('quarter'), S('road'), S('street')]);
    AParty.Address.BuildingName := S('building_name');
    AParty.Address.BuildingNumber := S('door_number');
    AParty.Address.CitySubdivisionName := S('district');
    AParty.Address.CityName := S('city_name');
    AParty.Address.PostalZone := S('zip_code');
    AParty.Address.CountryName := S('country_name');
    AParty.Address.CountryCode := S('country_code');
    if AParty.Email = '' then
      AParty.Email := S('email');
    if AParty.Website = '' then
      AParty.Website := S('web');
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

      // ---- satıcı: uygulama ayarları (taxpayer_type 'TCKN' = gerçek kişi)
      Q.Close;
      Q.SQL.Text := 'SELECT company_title, phone, fax, tax_authority, tax_no, sys_address_id, taxpayer_name, ' +
                    '       taxpayer_surname, taxpayer_type FROM public.sys_application_setting ORDER BY id LIMIT 1';
      LogQuery(Q, 'LoadSalesInvoice.Supplier');
      Q.Open;
      LSellerAddressId := 0;
      if not Q.IsEmpty then
      begin
        Result.Supplier.Found := True;
        Result.Supplier.TaxNo := S('tax_no');
        Result.Supplier.IsPerson := SameText(S('taxpayer_type'), 'TCKN') or (Length(Result.Supplier.TaxNo) = 11);
        Result.Supplier.Name := S('company_title');
        Result.Supplier.FirstName := S('taxpayer_name');
        Result.Supplier.FamilyName := S('taxpayer_surname');
        Result.Supplier.TaxOffice := S('tax_authority');
        Result.Supplier.Phone := S('phone');
        Result.Supplier.Fax := S('fax');
        LSellerAddressId := Q.FieldByName('sys_address_id').AsLargeInt;
      end;
      ReadAddress(LSellerAddressId, Result.Supplier);

      // ---- alıcı: cari + mükellef bilgisi (1 tüzel, 2 gerçek kişi) + fatura adresi (yoksa birincil / yasal adres)
      Q.Close;
      Q.SQL.Text :=
        'SELECT a.name, t.taxpayer_type, t.taxpayer_name, t.taxpayer_name2, t.taxpayer_surname, t.tax_office, t.tax_no, ' +
        '       (SELECT aa.sys_address_id FROM public.acc_account_address aa WHERE aa.acc_account_id = a.id ' +
        '         ORDER BY (aa.address_type = ''BILLING'') DESC, aa.is_primary DESC, (aa.address_type = ''LEGAL'') DESC, aa.id ' +
        '         LIMIT 1) AS sys_address_id ' +
        '  FROM public.acc_account a LEFT JOIN public.acc_account_taxpayer t ON t.acc_account_id = a.id ' +
        ' WHERE a.id = :id';
      Q.ParamByName('id').AsLargeInt := LAccountId;
      LogQuery(Q, 'LoadSalesInvoice.Customer');
      Q.Open;
      LCustomerAddressId := 0;
      if not Q.IsEmpty then
      begin
        Result.Customer.Found := True;
        Result.Customer.TaxNo := S('tax_no');
        Result.Customer.TaxOffice := S('tax_office');
        Result.Customer.IsPerson := (Q.FieldByName('taxpayer_type').AsInteger = 2) or
          (Q.FieldByName('taxpayer_type').IsNull and (Length(Result.Customer.TaxNo) = 11));
        if Result.Customer.IsPerson then
        begin
          Result.Customer.FirstName := S('taxpayer_name');
          Result.Customer.FamilyName := S('taxpayer_surname');
          Result.Customer.Name := JoinText([Result.Customer.FirstName, Result.Customer.FamilyName]);
          if (Result.Customer.FirstName = '') and (Result.Customer.FamilyName = '') then
          begin
            Result.Customer.Name := S('name');
            SplitName(S('name'), Result.Customer);
          end;
        end
        else
        begin
          Result.Customer.Name := JoinText([S('taxpayer_name'), S('taxpayer_name2')]);
          if Result.Customer.Name = '' then
            Result.Customer.Name := S('name');
        end;
        LCustomerAddressId := Q.FieldByName('sys_address_id').AsLargeInt;
        // e-Arşiv: kimlik numarası bilinmeyen nihai tüketici
        if not Result.IsExport and (Result.Customer.TaxNo = '') and (Result.ProfileCode = EINV_PROFILE_ARCHIVE) then
        begin
          Result.Customer.TaxNo := EINV_UNKNOWN_TCKN;
          Result.Customer.IsPerson := True;
          if Result.Customer.FirstName = '' then
            SplitName(Result.Customer.Name, Result.Customer);
        end;
      end;
      ReadAddress(LCustomerAddressId, Result.Customer);

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
