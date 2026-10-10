unit PrdBomLabour;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('prd_bom_labour')]
  TPrdBomLabour = class(TEntity)
  private
    FPrdBomId: Int64;
    FPrdLabourId: Int64;
    FQuantity: Currency;

    // View (vw_prd_bom_labour) okunabilir alanları
    FBomName: string;
    FLabourCode: string;
    FLabourName: string;
    FUnitPrice: string;
    FCurrency: string;
    FTotalAmount: string;
  public
    [Column('prd_bom_id'), Required()]
    property PrdBomId: Int64 read FPrdBomId write FPrdBomId;

    [Column('prd_labour_id'), Required()]
    property PrdLabourId: Int64 read FPrdLabourId write FPrdLabourId;

    [Column('quantity')]
    property Quantity: Currency read FQuantity write FQuantity;

    [NotMapped]
    property BomName: string read FBomName write FBomName;

    [NotMapped]
    property LabourCode: string read FLabourCode write FLabourCode;

    [NotMapped]
    property LabourName: string read FLabourName write FLabourName;

    [NotMapped]
    property UnitPrice: string read FUnitPrice write FUnitPrice;

    [NotMapped]
    property Currency: string read FCurrency write FCurrency;

    [NotMapped]
    property TotalAmount: string read FTotalAmount write FTotalAmount;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TPrdBomLabour;
  end;

implementation

constructor TPrdBomLabour.Create;
begin
  inherited;
end;

destructor TPrdBomLabour.Destroy;
begin
  inherited;
end;

function TPrdBomLabour.Clone: TPrdBomLabour;
begin
  Result := TPrdBomLabour.Create;
  Result.Id := Self.Id;
  Result.PrdBomId := Self.PrdBomId;
  Result.PrdLabourId := Self.PrdLabourId;
  Result.Quantity := Self.Quantity;
  Result.BomName := Self.BomName;
  Result.LabourCode := Self.LabourCode;
  Result.LabourName := Self.LabourName;
  Result.UnitPrice := Self.UnitPrice;
  Result.Currency := Self.Currency;
  Result.TotalAmount := Self.TotalAmount;
end;

end.
