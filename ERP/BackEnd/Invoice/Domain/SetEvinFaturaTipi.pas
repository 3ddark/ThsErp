unit SetEvinFaturaTipi;

interface

uses
  SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('einv_invoice_type')]
  TSetEvinInvoiceType = class(TEntity)
  private
    FInvoiceTypeName: string;
    FCode: string;
    FDescription: string;
  public
    [Column('invoice_type_name')]
    [Required]
    [MaxLength(64)]
    property InvoiceTypeName: string read FInvoiceTypeName write FInvoiceTypeName;

    [Column('code')]
    [Required]
    [MaxLength(16)]
    property Code: string read FCode write FCode;

    [Column('description')]
    property Description: string read FDescription write FDescription;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSetEvinInvoiceType.Create();
begin
  inherited;
end;

destructor TSetEvinInvoiceType.Destroy;
begin
  inherited;
end;

end.
