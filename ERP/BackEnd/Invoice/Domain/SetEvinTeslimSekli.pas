unit SetEvinTeslimSekli;

interface

uses
  SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('einv_delivery_type')]
  TSetEvinDeliveryType = class(TEntity)
  private
    FDeliveryTypeName: string;
    FDescription: string;
    FEfatura: Boolean;
  public
    [Column('delivery_type_name')]
    [Required]
    [MaxLength(64)]
    property DeliveryTypeName: string read FDeliveryTypeName write FDeliveryTypeName;

    [Column('description')]
    [MaxLength(512)]
    property Description: string read FDescription write FDescription;

    [Column('is_efatura')]
    property Efatura: Boolean read FEfatura write FEfatura;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSetEvinDeliveryType.Create();
begin
  inherited;
  FEfatura := False;
end;

destructor TSetEvinDeliveryType.Destroy;
begin
  inherited;
end;

end.
