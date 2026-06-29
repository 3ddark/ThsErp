unit SetStkHareketTipi;

interface

{$I Ths.inc}

uses
  System.SysUtils, Entity, EntityAttributes;

type
  [Table('set_stk_hareket_tipi')]
  TSetStkHareketTipi = class(TEntity)
  private
    FDeger: string;
    FIsInput: Boolean;
  public
    [Column('deger')]
    Property Deger: string read FDeger write FDeger;

    [Column('is_input')]
    Property IsInput: Boolean read FIsInput write FIsInput;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSetStkHareketTipi.Create;
begin
  inherited;
  FIsInput := False;
end;

destructor TSetStkHareketTipi.Destroy;
begin
  inherited;
end;

end.
