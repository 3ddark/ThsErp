unit SetChFirmaTipleri;

interface

{$I Ths.inc}

uses
  System.SysUtils, Entity, EntityAttributes, SetChFirmaTuru;

type
  [Table('set_ch_firma_tipleri')]
  TSetChFirmaTipleri = class(TEntity)
  private
    FFirmaTuruID: Int64;
    FFirmaTipi: string;
    FSetChFirmaTuru: TSetChFirmaTuru;
  public
    [Column('firma_turu_id')]
    Property FirmaTuruID: Int64 read FFirmaTuruID write FFirmaTuruID;

    [BelongsTo('firma_turu_id', 'set_ch_firma_turleri')]
    Property SetChFirmaTuru: TSetChFirmaTuru read FSetChFirmaTuru write FSetChFirmaTuru;

    [Column('firma_tipi')]
    Property FirmaTipi: string read FFirmaTipi write FFirmaTipi;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSetChFirmaTipleri.Create;
begin
  inherited;
end;

destructor TSetChFirmaTipleri.Destroy;
begin
  inherited;
end;

end.
