unit Grid.Types;

// Liste ekranlarının (TfrmGridBase / TfrmGrid<>) ortak tipleri, sabitleri ve kancaları

interface

uses
  System.Classes, Vcl.StdCtrls, Vcl.DBGrids, FireDAC.Comp.DataSet, SharedFormTypes;

const
  DB_STATUS_RECORD_COUNT = 0;
  DB_STATUS_SQL_SERVER   = 1;
  DB_STATUS_PERIOD       = 2;
  DB_STATUS_USER         = 3;
  DB_STATUS_KEY_F6       = 4;
  DB_STATUS_KEY_F7       = 5;
  DB_STATUS_KEY_F11      = 6;

  GRID_PAGE_SIZES: array[0..5] of Integer = (50, 100, 250, 500, 1000, 0);
  GRID_DEFAULT_PAGE_SIZE = 100;
  GRID_PAGE_SIZE_KEY = 'grid.page_size';

type
  TAggregateType = SharedFormTypes.TAggregateType;

  TFooterColumn = class
  public
    ColumnFieldName: string;
    AggregateType: TAggregateType;
    DisplayFormat: string;
    AggregateField: TFDAggregate;
    ServerValue: Variant;       // sayfalı modda tüm (filtreli) kayıtlar üzerinden SQL ile hesaplanan değer
    DisplayControl: TLabel;
    constructor Create(const AColumnFieldName: string; AAggregateType: TAggregateType; const ADisplayFormat: string = '');
  end;

  // Hızlı filtre seçeneği (başlık çubuğunda radyo düğmesi); Sql boş = koşulsuz
  TQuickFilter = class
  public
    Sql: string;
    Params: TArray<Variant>;     // Sql içinde :qc0, :qc1 …
    Button: TRadioButton;
  end;

  // Kolon genişliği değişim olayı + çizimde gereken korumalı üyeler (aktif kayıt, satır, başlık yenileme)
  THackDBGrid = class(TDBGrid)
  private
    FOnColWidthsChanged: TNotifyEvent;
    function GetActiveRecord: Integer;
  protected
    procedure ColWidthsChanged; override;
  public
    procedure InvalidateTitleRow;
    property ActiveRecord: Integer read GetActiveRecord;
    property Row;
    property OnColWidthsChanged: TNotifyEvent read FOnColWidthsChanged write FOnColWidthsChanged;
  end;

  // Sayfa değişiminde kullanıcının o anki kolon düzeni (genişlik / görünürlük / sıra / başlık) korunur
  TGridColumnState = record
    FieldName: string;
    Width: Integer;
    Visible: Boolean;
    Caption: string;
  end;

  // Kayıt geçmişi (işlem geçmişi) kancası: ufrmSysAuditLogs initialization'da bağlanır (grid ona bağımlı olmasın)
  TRecordHistoryAvailable = function(const ATableName: string): Boolean;
  TRecordHistoryShow = procedure(AOwner: TComponent; const ATableName: string; ARowId: Int64; const ARecordCaption: string);

var
  GRecordHistoryAvailable: TRecordHistoryAvailable = nil;
  GRecordHistoryShow: TRecordHistoryShow = nil;

implementation

{ TFooterColumn }

constructor TFooterColumn.Create(const AColumnFieldName: string; AAggregateType: TAggregateType; const ADisplayFormat: string);
begin
  inherited Create;
  ColumnFieldName := AColumnFieldName;
  AggregateType := AAggregateType;
  DisplayFormat := ADisplayFormat;
end;

{ THackDBGrid }

procedure THackDBGrid.ColWidthsChanged;
begin
  inherited;
  if Assigned(FOnColWidthsChanged) then
    FOnColWidthsChanged(Self);
end;

function THackDBGrid.GetActiveRecord: Integer;
begin
  Result := DataLink.ActiveRecord;
end;

procedure THackDBGrid.InvalidateTitleRow;
begin
  InvalidateTitles;
end;

end.
