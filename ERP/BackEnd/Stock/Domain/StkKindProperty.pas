unit StkKindProperty;

interface

{$I Ths.inc}

uses
  System.SysUtils, Entity, EntityAttributes;

type
  [Table('stk_kind_property')]
  TStkKindProperty = class(TEntity)
  private
    FKind: string;
    FDesciption: string;
    FS1, FS2, FS3, FS4, FS5, FS6, FS7, FS8, FS9: string;
    FI1, FI2, FI3, FI4, FI5: string;
    FD1, FD2, FD3, FD4, FD5: string;
  public
    [Column('kind')]
    Property Kind: string read FKind write FKind;

    [Column('desciption')]
    Property Desciption: string read FDesciption write FDesciption;

    [Column('s1')]
    Property S1: string read FS1 write FS1;
    [Column('s2')]
    Property S2: string read FS2 write FS2;
    [Column('s3')]
    Property S3: string read FS3 write FS3;
    [Column('s4')]
    Property S4: string read FS4 write FS4;
    [Column('s5')]
    Property S5: string read FS5 write FS5;
    [Column('s6')]
    Property S6: string read FS6 write FS6;
    [Column('s7')]
    Property S7: string read FS7 write FS7;
    [Column('s8')]
    Property S8: string read FS8 write FS8;
    [Column('s9')]
    Property S9: string read FS9 write FS9;

    [Column('i1')]
    Property I1: string read FI1 write FI1;
    [Column('i2')]
    Property I2: string read FI2 write FI2;
    [Column('i3')]
    Property I3: string read FI3 write FI3;
    [Column('i4')]
    Property I4: string read FI4 write FI4;
    [Column('i5')]
    Property I5: string read FI5 write FI5;

    [Column('d1')]
    Property D1: string read FD1 write FD1;
    [Column('d2')]
    Property D2: string read FD2 write FD2;
    [Column('d3')]
    Property D3: string read FD3 write FD3;
    [Column('d4')]
    Property D4: string read FD4 write FD4;
    [Column('d5')]
    Property D5: string read FD5 write FD5;

    constructor Create(); override;
    destructor Destroy; override;
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

end.
