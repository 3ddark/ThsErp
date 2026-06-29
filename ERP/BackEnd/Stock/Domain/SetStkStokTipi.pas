unit SetStkStokTipi;

interface

{$I Ths.inc}

uses
  System.SysUtils, Entity, EntityAttributes;

type
  [Table('set_stk_stok_tipi')]
  TSetStkStokTipi = class(TEntity)
  private
    FStokTipi: string;
  public
    [Column('stok_tipi')]
    Property StokTipi: string read FStokTipi write FStokTipi;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSetStkStokTipi.Create;
begin
  inherited;
end;

destructor TSetStkStokTipi.Destroy;
begin
  inherited;
end;

end.
