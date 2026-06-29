unit SetStkUrunTipleri;

interface

{$I Ths.inc}

uses
  System.SysUtils, Entity, EntityAttributes;

type
  [Table('set_stk_urun_tipleri')]
  TSetStkUrunTipleri = class(TEntity)
  private
    FUrunTipi: string;
  public
    [Column('urun_tipi')]
    Property UrunTipi: string read FUrunTipi write FUrunTipi;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSetStkUrunTipleri.Create;
begin
  inherited;
end;

destructor TSetStkUrunTipleri.Destroy;
begin
  inherited;
end;

end.
