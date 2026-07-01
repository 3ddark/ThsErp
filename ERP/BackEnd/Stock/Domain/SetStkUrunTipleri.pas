unit SetStkUrunTipleri;

interface

{$I Ths.inc}

uses
  System.SysUtils, Entity, EntityAttributes;

type
  [Table('stk_product_type')]
  TSetStkUrunTipleri = class(TEntity)
  private
    FProductName: string;
  public
    [Column('product_type_name')]
    Property ProductTypeName: string read FProductName write FProductName;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSetStkUrunTipleri.Create;
begin
  inherited;
end;

destructor TSetStkUrunTipleri.Destroy;
begin
  inherited;
end;

end.
