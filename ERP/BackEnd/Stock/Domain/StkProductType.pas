unit StkProductType;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('stk_product_type')]
  TStkProductType = class(TEntity)
  private
    FProductTypeName: string;
    FDescription: string;
    FActive: Boolean;
  public
    [Column('product_type_name')]
    [MaxLength(32), Required(TLangKeys.TValidation.Required, True)]
    property ProductTypeName: string read FProductTypeName write FProductTypeName;

    [Column('description')]
    [MaxLength(128)]
    property Description: string read FDescription write FDescription;

    [Column('active')]
    property Active: Boolean read FActive write FActive;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TStkProductType;
  end;

implementation

constructor TStkProductType.Create;
begin
  inherited;
  FActive := True;
end;

destructor TStkProductType.Destroy;
begin
  inherited;
end;

function TStkProductType.Clone: TStkProductType;
begin
  Result := TStkProductType.Create;
  Result.Id := Self.Id;
  Result.ProductTypeName := Self.ProductTypeName;
  Result.Description := Self.Description;
  Result.Active := Self.Active;
end;

end.
