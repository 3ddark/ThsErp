unit SetStkBarkodHazirlikDosyaTuru;

interface

{$I Ths.inc}

uses
  System.SysUtils, Entity, EntityAttributes;

type
  [Table('set_stk_barkod_hazirlik_dosya_turu')]
  TSetStkBarkodHazirlikDosyaTuru = class(TEntity)
  private
    FDosyaTuru: string;
  public
    [Column('dosya_turu')]
    Property DosyaTuru: string read FDosyaTuru write FDosyaTuru;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSetStkBarkodHazirlikDosyaTuru.Create;
begin
  inherited;
end;

destructor TSetStkBarkodHazirlikDosyaTuru.Destroy;
begin
  inherited;
end;

end.
