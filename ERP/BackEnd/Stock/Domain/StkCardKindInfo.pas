unit StkCardKindInfo;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('stk_card_kind_info')]
  TStkCardKindInfo = class(TEntity)
  private
    FStkInventoryId: Int64;
    FStkKindPropertyId: Int64;
    FS1: string;
    FS2: string;
    FS3: string;
    FS4: string;
    FS5: string;
    FS6: string;
    FS7: string;
    FS8: string;
    FS9: string;
    FS10: string;
    FI1: Integer;
    FI2: Integer;
    FI3: Integer;
    FI4: Integer;
    FI5: Integer;
    FD1: Double;
    FD2: Double;
    FD3: Double;
    FD4: Double;
    FD5: Double;

    // View (vw_stk_card_kind_info) okunabilir alanları
    FInventoryName: string;
    FKindName: string;
    FInventoryCode: string;
  public
    [Column('stk_inventory_id')]
    property StkInventoryId: Int64 read FStkInventoryId write FStkInventoryId;

    [Column('stk_kind_property_id')]
    property StkKindPropertyId: Int64 read FStkKindPropertyId write FStkKindPropertyId;

    [Column('s1')]
    [MaxLength(64)]
    property S1: string read FS1 write FS1;

    [Column('s2')]
    [MaxLength(64)]
    property S2: string read FS2 write FS2;

    [Column('s3')]
    [MaxLength(64)]
    property S3: string read FS3 write FS3;

    [Column('s4')]
    [MaxLength(64)]
    property S4: string read FS4 write FS4;

    [Column('s5')]
    [MaxLength(64)]
    property S5: string read FS5 write FS5;

    [Column('s6')]
    [MaxLength(64)]
    property S6: string read FS6 write FS6;

    [Column('s7')]
    [MaxLength(64)]
    property S7: string read FS7 write FS7;

    [Column('s8')]
    [MaxLength(64)]
    property S8: string read FS8 write FS8;

    [Column('s9')]
    [MaxLength(64)]
    property S9: string read FS9 write FS9;

    [Column('s10')]
    [MaxLength(64)]
    property S10: string read FS10 write FS10;

    [Column('i1')]
    property I1: Integer read FI1 write FI1;

    [Column('i2')]
    property I2: Integer read FI2 write FI2;

    [Column('i3')]
    property I3: Integer read FI3 write FI3;

    [Column('i4')]
    property I4: Integer read FI4 write FI4;

    [Column('i5')]
    property I5: Integer read FI5 write FI5;

    [Column('d1')]
    property D1: Double read FD1 write FD1;

    [Column('d2')]
    property D2: Double read FD2 write FD2;

    [Column('d3')]
    property D3: Double read FD3 write FD3;

    [Column('d4')]
    property D4: Double read FD4 write FD4;

    [Column('d5')]
    property D5: Double read FD5 write FD5;

    [NotMapped]
    property InventoryName: string read FInventoryName write FInventoryName;

    [NotMapped]
    property KindName: string read FKindName write FKindName;

    [NotMapped]
    property InventoryCode: string read FInventoryCode write FInventoryCode;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TStkCardKindInfo;
  end;

implementation

constructor TStkCardKindInfo.Create;
begin
  inherited;
end;

destructor TStkCardKindInfo.Destroy;
begin
  inherited;
end;

function TStkCardKindInfo.Clone: TStkCardKindInfo;
begin
  Result := TStkCardKindInfo.Create;
  Result.Id := Self.Id;
  Result.StkInventoryId := Self.StkInventoryId;
  Result.StkKindPropertyId := Self.StkKindPropertyId;
  Result.S1 := Self.S1;
  Result.S2 := Self.S2;
  Result.S3 := Self.S3;
  Result.S4 := Self.S4;
  Result.S5 := Self.S5;
  Result.S6 := Self.S6;
  Result.S7 := Self.S7;
  Result.S8 := Self.S8;
  Result.S9 := Self.S9;
  Result.S10 := Self.S10;
  Result.I1 := Self.I1;
  Result.I2 := Self.I2;
  Result.I3 := Self.I3;
  Result.I4 := Self.I4;
  Result.I5 := Self.I5;
  Result.D1 := Self.D1;
  Result.D2 := Self.D2;
  Result.D3 := Self.D3;
  Result.D4 := Self.D4;
  Result.D5 := Self.D5;
  Result.InventoryName := Self.InventoryName;
  Result.KindName := Self.KindName;
  Result.InventoryCode := Self.InventoryCode;
end;

end.
