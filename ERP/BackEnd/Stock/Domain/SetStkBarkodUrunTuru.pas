unit SetStkBarkodUrunTuru;

interface

{$I Ths.inc}

uses
  System.SysUtils, Entity, EntityAttributes;

type
  [Table('set_stk_barkod_urun_turu')]
  TSetStkBarkodUrunTuru = class(TEntity)
  private
    FUrunTuru: string;
  public
    [Column('urun_turu')]
    Property UrunTuru: string read FUrunTuru write FUrunTuru;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSetStkBarkodUrunTuru.Create;
begin
  inherited;
end;

destructor TSetStkBarkodUrunTuru.Destroy;
begin
  inherited;
end;

end.
