unit SetEvinOdemeSekli;

interface

uses
  SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('einv_payment_method')]
  TSetEvinPaymentMethod = class(TEntity)
  private
    FPaymentMethodCode: string;
    FCode: string;
    FDescription: string;
    FEfatura: Boolean;
  public
    [Column('payment_method_code')]
    [MaxLength(96)]
    property PaymentMethodCode: string read FPaymentMethodCode write FPaymentMethodCode;

    [Column('code')]
    [MaxLength(16)]
    property Code: string read FCode write FCode;

    [Column('description')]
    [MaxLength(512)]
    property Description: string read FDescription write FDescription;

    [Column('is_efatura')]
    property Efatura: Boolean read FEfatura write FEfatura;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSetEvinPaymentMethod.Create();
begin
  inherited;
  FEfatura := False;
end;

destructor TSetEvinPaymentMethod.Destroy;
begin
  inherited;
end;

end.
