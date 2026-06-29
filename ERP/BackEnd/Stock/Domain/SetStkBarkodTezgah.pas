unit SetStkBarkodTezgah;

interface

{$I Ths.inc}

uses
  System.SysUtils, Entity, EntityAttributes;

type
  [Table('set_stk_barkod_tezgah')]
  TSetStkBarkodTezgah = class(TEntity)
  private
    FTezgahAdi: string;
    FAmbarID: Int64;
  public
    [Column('tezgah_adi')]
    Property TezgahAdi: string read FTezgahAdi write FTezgahAdi;

    [Column('ambar_id')]
    Property AmbarID: Int64 read FAmbarID write FAmbarID;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSetStkBarkodTezgah.Create;
begin
  inherited;
end;

destructor TSetStkBarkodTezgah.Destroy;
begin
  inherited;
end;

end.
