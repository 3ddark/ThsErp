unit StkStokGrubuTuru;

interface

{$I Ths.inc}

uses
  System.SysUtils, Entity, EntityAttributes;

type
  [Table('stk_stok_grubu_turu')]
  TStkStokGrubuTuru = class(TEntity)
  private
    FGruAbi: string;
  public
    [Column('gru_abi')]
    Property GruAbi: string read FGruAbi write FGruAbi;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TStkStokGrubuTuru.Create;
begin
  inherited;
end;

destructor TStkStokGrubuTuru.Destroy;
begin
  inherited;
end;

end.
