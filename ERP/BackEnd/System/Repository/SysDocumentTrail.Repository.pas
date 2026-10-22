unit SysDocumentTrail.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, SysDocumentTrail;

type
  // vw_sys_document_trail salt okunur: her okuma kaynak belge (source_table + source_id) filtresiyle yapılır,
  // filtresiz okuma tüm belgelerin izini hesaplar. Yazma işlemleri desteklenmez.
  TSysDocumentTrailRepository = class(TRepository<TSysDocumentTrail>)
  private
    FAllowedDocTables: TArray<string>;
    function AllowedDocTablesCondition: string;
    procedure RaiseReadOnly;
  protected
    function MapFromQuery(Q: TFDQuery): TSysDocumentTrail; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TSysDocumentTrail>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TSysDocumentTrail; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TSysDocumentTrail; override;

    procedure DoAdd(AModel: TSysDocumentTrail); override;
    procedure DoAddBatch(AModels: TArray<TSysDocumentTrail>); override;

    procedure DoUpdate(AModel: TSysDocumentTrail); override;
    procedure DoUpdateBatch(AModels: TArray<TSysDocumentTrail>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TSysDocumentTrail); override;
    procedure DoDeleteBatch(AModels: TArray<TSysDocumentTrail>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);

    // Belgenin vergi özeti (vw_sys_document_tax_summary; KDV satırları oran büyükten küçüğe, sonra tevkifat)
    function ReadTaxSummary(const ADocTable: string; ADocId: Int64): TArray<TSysDocumentTaxRow>;

    // Okunabilen belge tabloları (servis yetkiye göre verir); boş = hiçbir satır
    property AllowedDocTables: TArray<string> read FAllowedDocTables write FAllowedDocTables;
  end;

implementation

uses
  SysDocumentTrail.Exception;

constructor TSysDocumentTrailRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

// Değerler servisin sabit tablo listesinden gelir (kullanıcı girdisi değil)
function TSysDocumentTrailRepository.AllowedDocTablesCondition: string;
var
  LTable: string;
begin
  Result := '';
  for LTable in FAllowedDocTables do
  begin
    if Result <> '' then
      Result := Result + ', ';
    Result := Result + QuotedStr(LTable);
  end;
  if Result = '' then
    Result := ' AND 1=0 '
  else
    Result := ' AND doc_table IN (' + Result + ') ';
end;

function TSysDocumentTrailRepository.ReadTaxSummary(const ADocTable: string; ADocId: Int64): TArray<TSysDocumentTaxRow>;
var
  Q: TFDQuery;
  LRow: TSysDocumentTaxRow;
begin
  Result := [];
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text :=
      'SELECT summary_type, tax_rate, withholding_code, withholding_name, base_amount, tax_amount ' +
      '  FROM public.vw_sys_document_tax_summary WHERE doc_table = :doc_table AND doc_id = :doc_id ORDER BY id';
    Q.ParamByName('doc_table').AsWideString := ADocTable;
    Q.ParamByName('doc_id').AsLargeInt := ADocId;
    LogQuery(Q, 'ReadTaxSummary');
    Q.Open;
    while not Q.Eof do
    begin
      LRow.SummaryType := Q.FieldByName('summary_type').AsInteger;
      LRow.TaxRate := Q.FieldByName('tax_rate').AsCurrency;
      LRow.WithholdingCode := Q.FieldByName('withholding_code').AsString;
      LRow.WithholdingName := Q.FieldByName('withholding_name').AsString;
      LRow.BaseAmount := Q.FieldByName('base_amount').AsCurrency;
      LRow.TaxAmount := Q.FieldByName('tax_amount').AsCurrency;
      Result := Result + [LRow];
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

procedure TSysDocumentTrailRepository.RaiseReadOnly;
begin
  raise ESysDocumentTrailExceptionReadOnly.Create;
end;

function TSysDocumentTrailRepository.MapFromQuery(Q: TFDQuery): TSysDocumentTrail;
begin
  Result := TSysDocumentTrail.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.SourceTable := Q.FieldByName('source_table').AsString;
  Result.SourceId := Q.FieldByName('source_id').AsLargeInt;
  Result.TrailLevel := Q.FieldByName('trail_level').AsInteger;
  Result.DocTable := Q.FieldByName('doc_table').AsString;
  Result.DocId := Q.FieldByName('doc_id').AsLargeInt;
  Result.DocNo := Q.FieldByName('doc_no').AsString;
  if Q.FieldByName('doc_date').IsNull then
    Result.DocDate := 0
  else
    Result.DocDate := Q.FieldByName('doc_date').AsDateTime;
  Result.AccAccountId := Q.FieldByName('acc_account_id').AsLargeInt;
  Result.AccountCode := Q.FieldByName('account_code').AsString;
  Result.AccountName := Q.FieldByName('account_name').AsString;
  Result.Status := Q.FieldByName('status').AsInteger;
  Result.Currency := Q.FieldByName('currency').AsString;
  Result.TotalAmount := Q.FieldByName('total_amount').AsCurrency;
end;

function TSysDocumentTrailRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id', 'doc_table', 'doc_id', 'status']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TSysDocumentTrail) + ' WHERE 1=1 ' +
    AllowedDocTablesCondition;

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TSysDocumentTrailRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TSysDocumentTrail>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TSysDocumentTrail>.Create(True);
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := Self.PrepareSelectFromView(AFilter, False, False, False);

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

// id tek başına kaynak belirtmez (her izde 1'den başlar) ve filtresiz okuma tüm izleri hesaplar: kaynakla okunur
function TSysDocumentTrailRepository.DoFindById(AId: TValue; ALock: Boolean): TSysDocumentTrail;
begin
  RaiseReadOnly;
  Result := nil;
end;

function TSysDocumentTrailRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TSysDocumentTrail;
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
    Q.SQL.Text := Self.PrepareSelectFromView(AFilter, False, True, False);

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

procedure TSysDocumentTrailRepository.DoAdd(AModel: TSysDocumentTrail);
begin
  RaiseReadOnly;
end;

procedure TSysDocumentTrailRepository.DoAddBatch(AModels: TArray<TSysDocumentTrail>);
begin
  RaiseReadOnly;
end;

procedure TSysDocumentTrailRepository.DoUpdate(AModel: TSysDocumentTrail);
begin
  RaiseReadOnly;
end;

procedure TSysDocumentTrailRepository.DoUpdateBatch(AModels: TArray<TSysDocumentTrail>);
begin
  RaiseReadOnly;
end;

procedure TSysDocumentTrailRepository.DoDelete(AID: TValue);
begin
  RaiseReadOnly;
end;

procedure TSysDocumentTrailRepository.DoDelete(AModel: TSysDocumentTrail);
begin
  RaiseReadOnly;
end;

procedure TSysDocumentTrailRepository.DoDeleteBatch(AModels: TArray<TSysDocumentTrail>);
begin
  RaiseReadOnly;
end;

procedure TSysDocumentTrailRepository.DoDeleteBatch(AIDs: TArray<TValue>);
begin
  RaiseReadOnly;
end;

procedure TSysDocumentTrailRepository.DoDeleteBatch(AFilter: TFilterCriteria);
begin
  RaiseReadOnly;
end;

end.
