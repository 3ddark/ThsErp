unit StkCardKindInfo;

interface

{$I Ths.inc}

uses
  System.SysUtils, Entity, EntityAttributes;

type
  [Table('stk_card_kind_info')]
  TStkCardKindInfo = class(TEntity)
  private
    FStkKartID: Int64;
    FCinsID: Int64;
    FDeger: string;
  public
    [Column('stk_kart_id')]
    Property StkKartID: Int64 read FStkKartID write FStkKartID;

    [Column('cins_id')]
    Property CinsID: Int64 read FCinsID write FCinsID;

    [Column('deger')]
    Property Deger: string read FDeger write FDeger;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TStkCardKindInfo.Create;
begin
  inherited;
end;

destructor TStkCardKindInfo.Destroy;
begin
  inherited;
end;

end.
