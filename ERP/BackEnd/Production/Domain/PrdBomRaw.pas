unit PrdBomRaw;

interface

uses
  SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('prd_bom_raw')]
  TPrdBomRaw = class(TEntity)
  private
    FHeaderId: Int64;
    FReceteId: Int64;
    FSkuCode: string;
    FQuantity: double;
    FScrapRate: double;
  public
    [Column('header_id')]
    [Required]
    property HeaderId: Int64 read FHeaderId write FHeaderId;

    [Column('recete_id')]
    property ReceteId: Int64 read FReceteId write FReceteId;

    [Column('stok_kodu')]
    [Required]
    [MaxLength(32)]
    property SkuCode: string read FSkuCode write FSkuCode;

    [Column('quantity')]
    [Required]
    property Quantity: double read FQuantity write FQuantity;

    [Column('scrap_rate')]
    [Required]
    property ScrapRate: double read FScrapRate write FScrapRate;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TPrdBomRaw.Create();
begin
  inherited;
  FScrapRate := 0;
end;

destructor TPrdBomRaw.Destroy;
begin
  inherited;
end;

end.
