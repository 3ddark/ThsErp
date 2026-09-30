unit StkKindProperty;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('stk_kind_property')]
  TStkKindProperty = class(TEntity)
  private
    FKind: string;
    FDescription: string;
    FStkKindFamilyId: Int64;
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
    FI1: string;
    FI2: string;
    FI3: string;
    FI4: string;
    FI5: string;
    FD1: string;
    FD2: string;
    FD3: string;
    FD4: string;
    FD5: string;

    // View (vw_stk_kind_property) okunabilir alanları
    FFamilyName: string;
  public
    [Column('kind')]
    [MaxLength(32), Required(TLangKeys.TValidation.Required, True)]
    property Kind: string read FKind write FKind;

    [Column('description')]
    [MaxLength(128)]
    property Description: string read FDescription write FDescription;

    [Column('stk_kind_family_id')]
    property StkKindFamilyId: Int64 read FStkKindFamilyId write FStkKindFamilyId;

    [Column('s1')]
    [MaxLength(32)]
    property S1: string read FS1 write FS1;

    [Column('s2')]
    [MaxLength(32)]
    property S2: string read FS2 write FS2;

    [Column('s3')]
    [MaxLength(32)]
    property S3: string read FS3 write FS3;

    [Column('s4')]
    [MaxLength(32)]
    property S4: string read FS4 write FS4;

    [Column('s5')]
    [MaxLength(32)]
    property S5: string read FS5 write FS5;

    [Column('s6')]
    [MaxLength(32)]
    property S6: string read FS6 write FS6;

    [Column('s7')]
    [MaxLength(32)]
    property S7: string read FS7 write FS7;

    [Column('s8')]
    [MaxLength(32)]
    property S8: string read FS8 write FS8;

    [Column('s9')]
    [MaxLength(32)]
    property S9: string read FS9 write FS9;

    [Column('s10')]
    [MaxLength(32)]
    property S10: string read FS10 write FS10;

    [Column('i1')]
    [MaxLength(32)]
    property I1: string read FI1 write FI1;

    [Column('i2')]
    [MaxLength(32)]
    property I2: string read FI2 write FI2;

    [Column('i3')]
    [MaxLength(32)]
    property I3: string read FI3 write FI3;

    [Column('i4')]
    [MaxLength(32)]
    property I4: string read FI4 write FI4;

    [Column('i5')]
    [MaxLength(32)]
    property I5: string read FI5 write FI5;

    [Column('d1')]
    [MaxLength(32)]
    property D1: string read FD1 write FD1;

    [Column('d2')]
    [MaxLength(32)]
    property D2: string read FD2 write FD2;

    [Column('d3')]
    [MaxLength(32)]
    property D3: string read FD3 write FD3;

    [Column('d4')]
    [MaxLength(32)]
    property D4: string read FD4 write FD4;

    [Column('d5')]
    [MaxLength(32)]
    property D5: string read FD5 write FD5;

    [NotMapped]
    property FamilyName: string read FFamilyName write FFamilyName;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TStkKindProperty;
  end;

implementation

constructor TStkKindProperty.Create;
begin
  inherited;
end;

destructor TStkKindProperty.Destroy;
begin
  inherited;
end;

function TStkKindProperty.Clone: TStkKindProperty;
begin
  Result := TStkKindProperty.Create;
  Result.Id := Self.Id;
  Result.Kind := Self.Kind;
  Result.Description := Self.Description;
  Result.StkKindFamilyId := Self.StkKindFamilyId;
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
  Result.FamilyName := Self.FamilyName;
end;

end.
