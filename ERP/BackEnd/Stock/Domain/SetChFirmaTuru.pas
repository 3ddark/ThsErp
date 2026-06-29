unit SetChFirmaTuru;

interface

{$I Ths.inc}

uses
  System.SysUtils, Entity, EntityAttributes;

type
  [Table('set_ch_firma_turleri')]
  TSetChFirmaTuru = class(TEntity)
  private
    FFirmaTuru: string;
  public
    [Column('firma_turu')]
    Property FirmaTuru: string read FFirmaTuru write FFirmaTuru;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSetChFirmaTuru.Create;
begin
  inherited;
end;

destructor TSetChFirmaTuru.Destroy;
begin
  inherited;
end;

end.
