unit PurRequestDetail;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  // Talep kalemi. Talebin Lines listesinde durum (yeni / kayıtlı / silinecek) TDetailEntity'den; başlığa tipli
  // erişim PurRequest birimindeki class helper ile (Line.Header.RequestNo)
  [Table('pur_request_detail')]
  TPurRequestDetail = class(TDetailEntity)
  private
    FPurRequestId: Int64;
    FLineNo: SmallInt;
    FStkInventoryId: Int64;
    FQuantity: Currency;
    FOrderedQuantity: Currency;
    FRequiredDate: TDate;
    FDescription: string;

    // View (vw_pur_request_detail) okunabilir alanları
    FRequestNo: string;
    FInventoryCode: string;
    FInventoryName: string;
    FUomCode: string;
  public
    [Column('pur_request_id')]
    [Required()]
    property PurRequestId: Int64 read FPurRequestId write FPurRequestId;

    [Column('line_no')]
    property LineNo: SmallInt read FLineNo write FLineNo;

    [Column('stk_inventory_id')]
    [Required()]
    property StkInventoryId: Int64 read FStkInventoryId write FStkInventoryId;

    [Column('quantity')]
    property Quantity: Currency read FQuantity write FQuantity;

    [Column('ordered_quantity')]
    property OrderedQuantity: Currency read FOrderedQuantity write FOrderedQuantity;

    [Column('required_date')]
    property RequiredDate: TDate read FRequiredDate write FRequiredDate;

    [Column('description')]
    [MaxLength(128)]
    property Description: string read FDescription write FDescription;

    [NotMapped]
    property RequestNo: string read FRequestNo write FRequestNo;

    [NotMapped]
    property InventoryCode: string read FInventoryCode write FInventoryCode;

    [NotMapped]
    property InventoryName: string read FInventoryName write FInventoryName;

    [NotMapped]
    property UomCode: string read FUomCode write FUomCode;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TPurRequestDetail;
  end;

implementation

constructor TPurRequestDetail.Create;
begin
  inherited;
end;

destructor TPurRequestDetail.Destroy;
begin
  inherited;
end;

function TPurRequestDetail.Clone: TPurRequestDetail;
begin
  // başlık referansı kopyalanmaz (kopyayı sahiplenen başlık verir)
  Result := TPurRequestDetail.Create;
  Result.Id := Self.Id;
  Result.Deleted := Self.Deleted;
  Result.PurRequestId := Self.PurRequestId;
  Result.LineNo := Self.LineNo;
  Result.StkInventoryId := Self.StkInventoryId;
  Result.Quantity := Self.Quantity;
  Result.OrderedQuantity := Self.OrderedQuantity;
  Result.RequiredDate := Self.RequiredDate;
  Result.Description := Self.Description;
  Result.RequestNo := Self.RequestNo;
  Result.InventoryCode := Self.InventoryCode;
  Result.InventoryName := Self.InventoryName;
  Result.UomCode := Self.UomCode;
end;

end.
