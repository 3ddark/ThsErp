unit StkProductType;

interface

{$I Ths.inc}

uses
  System.SysUtils, Entity, EntityAttributes;

type
  [Table('stk_product_type')]
  TStkProductType = class(TEntity)
  private
    FProductTypeName: string;
  public
    [Column('product_type_name'), MaxLength(64), Required()]
    Property ProductTypeName: string read FProductTypeName write FProductTypeName;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TStkProductType;
  end;

implementation

constructor TStkProductType.Create;
begin
  inherited;
end;

destructor TStkProductType.Destroy;
begin
  inherited;
end;

function TStkProductType.Clone: TStkProductType;
begin
  Result := TStkProductType.Create;
  Result.ProductTypeName := Self.ProductTypeName;
end;

end.
