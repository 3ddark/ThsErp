unit SysDocumentTrail;

interface

{$I Ths.inc}

uses
  System.SysUtils, Entity, EntityAttributes;

const
  // vw_sys_document_tax_summary.summary_type
  DOC_TAX_VAT = 1;             // KDV: oran bazında matrah / tutar
  DOC_TAX_VAT_WITHHOLDING = 2; // KDV tevkifatı: tevkifat kodu bazında (matrah = tevkifata tabi KDV, oran = tevkifat oranı)

type
  // Belge vergi özeti satırı ({belge}_tax_summary, satırlardan DB tetikleyicisiyle; salt okunur)
  TSysDocumentTaxRow = record
    SummaryType: Integer;
    TaxRate: Currency;
    WithholdingCode: string;
    WithholdingName: string;
    BaseAmount: Currency;
    TaxAmount: Currency;
  end;

  // Evrak izi satırı (vw_sys_document_trail, salt okunur): kaynak belgenin (source_table + source_id) atası /
  // torunu olan bir belge. trail_level: 0 kaynak, < 0 önceki belgeler, > 0 sonraki belgeler.
  // id yalnız aynı kaynağın izi içinde tekildir (okumalar kaynağa göre süzülür).
  [Table('sys_document_trail')]
  TSysDocumentTrail = class(TEntity)
  private
    FSourceTable: string;
    FSourceId: Int64;
    FTrailLevel: Integer;
    FDocTable: string;
    FDocId: Int64;
    FDocNo: string;
    FDocDate: TDate;
    FAccAccountId: Int64;
    FAccountCode: string;
    FAccountName: string;
    FStatus: SmallInt;
    FCurrency: string;
    FTotalAmount: Currency;
  public
    [Column('source_table')]
    property SourceTable: string read FSourceTable write FSourceTable;

    [Column('source_id')]
    property SourceId: Int64 read FSourceId write FSourceId;

    [Column('trail_level')]
    property TrailLevel: Integer read FTrailLevel write FTrailLevel;

    [Column('doc_table')]
    property DocTable: string read FDocTable write FDocTable;

    [Column('doc_id')]
    property DocId: Int64 read FDocId write FDocId;

    [Column('doc_no')]
    property DocNo: string read FDocNo write FDocNo;

    [Column('doc_date')]
    property DocDate: TDate read FDocDate write FDocDate;

    [Column('acc_account_id')]
    property AccAccountId: Int64 read FAccAccountId write FAccAccountId;

    [Column('account_code')]
    property AccountCode: string read FAccountCode write FAccountCode;

    [Column('account_name')]
    property AccountName: string read FAccountName write FAccountName;

    [Column('status')]
    property Status: SmallInt read FStatus write FStatus;

    [Column('currency')]
    property Currency: string read FCurrency write FCurrency;

    [Column('total_amount')]
    property TotalAmount: Currency read FTotalAmount write FTotalAmount;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TSysDocumentTrail;
  end;

implementation

constructor TSysDocumentTrail.Create;
begin
  inherited;
end;

destructor TSysDocumentTrail.Destroy;
begin
  inherited;
end;

function TSysDocumentTrail.Clone: TSysDocumentTrail;
begin
  Result := TSysDocumentTrail.Create;
  Result.Id := Self.Id;
  Result.SourceTable := Self.SourceTable;
  Result.SourceId := Self.SourceId;
  Result.TrailLevel := Self.TrailLevel;
  Result.DocTable := Self.DocTable;
  Result.DocId := Self.DocId;
  Result.DocNo := Self.DocNo;
  Result.DocDate := Self.DocDate;
  Result.AccAccountId := Self.AccAccountId;
  Result.AccountCode := Self.AccountCode;
  Result.AccountName := Self.AccountName;
  Result.Status := Self.Status;
  Result.Currency := Self.Currency;
  Result.TotalAmount := Self.TotalAmount;
end;

end.
