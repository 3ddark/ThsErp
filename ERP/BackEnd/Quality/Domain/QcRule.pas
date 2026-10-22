unit QcRule;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  // Kalite kontrol gerekliliği: stok grubu ya da stok kartı için (kart kuralı grup kuralını ezer)
  [Table('qc_rule')]
  TQcRule = class(TEntity)
  private
    FStkGroupId: Int64;
    FStkInventoryId: Int64;
    FIsRequired: Boolean;
    FInspectionCriteria: string;

    // View (vw_qc_rule) okunabilir alanları
    FGroupName: string;
    FInventoryCode: string;
    FInventoryName: string;
  public
    [Column('stk_group_id')]
    property StkGroupId: Int64 read FStkGroupId write FStkGroupId;

    [Column('stk_inventory_id')]
    property StkInventoryId: Int64 read FStkInventoryId write FStkInventoryId;

    [Column('is_required')]
    property IsRequired: Boolean read FIsRequired write FIsRequired;

    [Column('inspection_criteria')]
    [MaxLength(256)]
    property InspectionCriteria: string read FInspectionCriteria write FInspectionCriteria;

    [NotMapped]
    property GroupName: string read FGroupName write FGroupName;

    [NotMapped]
    property InventoryCode: string read FInventoryCode write FInventoryCode;

    [NotMapped]
    property InventoryName: string read FInventoryName write FInventoryName;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TQcRule;
  end;

implementation

constructor TQcRule.Create;
begin
  inherited;
  FIsRequired := True;
end;

destructor TQcRule.Destroy;
begin
  inherited;
end;

function TQcRule.Clone: TQcRule;
begin
  Result := TQcRule.Create;
  Result.Id := Self.Id;
  Result.StkGroupId := Self.StkGroupId;
  Result.StkInventoryId := Self.StkInventoryId;
  Result.IsRequired := Self.IsRequired;
  Result.InspectionCriteria := Self.InspectionCriteria;
  Result.GroupName := Self.GroupName;
  Result.InventoryCode := Self.InventoryCode;
  Result.InventoryName := Self.InventoryName;
end;

end.
