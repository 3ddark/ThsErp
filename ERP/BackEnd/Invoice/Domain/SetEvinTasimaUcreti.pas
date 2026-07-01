unit SetEvinTasimaUcreti;

interface

uses
  SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('einv_transport_price')]
  TSetEvinTransportPrice = class(TEntity)
  private
    FTransportCharge: string;
  public
    [Column('transport_charge')]
    [Required]
    [MaxLength(16)]
    property TransportCharge: string read FTransportCharge write FTransportCharge;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSetEvinTransportPrice.Create();
begin
  inherited;
end;

destructor TSetEvinTransportPrice.Destroy;
begin
  inherited;
end;

end.
