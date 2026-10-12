unit PurRequestDetail;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('pur_request_detail')]
  TPurRequestDetail = class(TEntity)
  private
    FPurRequestId: Int64;
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
  Result := TPurRequestDetail.Create;
  Result.Id := Self.Id;
  Result.PurRequestId := Self.PurRequestId;
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
