unit SetStkBarkodSeriNoTuru;

interface

{$I Ths.inc}

uses
  System.SysUtils, Entity, EntityAttributes;

type
  [Table('set_stk_barkod_seri_no_turu')]
  TSetStkBarkodSeriNoTuru = class(TEntity)
  private
    FSeriNoTuru: string;
  public
    [Column('seri_no_turu')]
    Property SeriNoTuru: string read FSeriNoTuru write FSeriNoTuru;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSetStkBarkodSeriNoTuru.Create;
begin
  inherited;
end;

destructor TSetStkBarkodSeriNoTuru.Destroy;
begin
  inherited;
end;

end.
