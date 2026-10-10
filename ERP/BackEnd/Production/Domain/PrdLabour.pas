unit PrdLabour;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('prd_labour')]
  TPrdLabour = class(TEntity)
  private
    FCode: string;
    FName: string;
    FCostType: SmallInt;
    FSysUomId: Int64;
    FUnitPrice: Currency;
    FCurrency: string;
    FAccAccountCode: string;

    // View (vw_prd_labour) okunabilir alanları
    FUomCode: string;
    FAccountName: string;
  public
    [Column('code')]
    [MaxLength(16), Required(TLangKeys.TValidation.Required, True)]
    property Code: string read FCode write FCode;

    [Column('name')]
    [MaxLength(128), Required(TLangKeys.TValidation.Required, True)]
    property Name: string read FName write FName;

    [Column('cost_type')]
    property CostType: SmallInt read FCostType write FCostType;

    [Column('sys_uom_id'), Required()]
    property SysUomId: Int64 read FSysUomId write FSysUomId;

    [Column('unit_price')]
    property UnitPrice: Currency read FUnitPrice write FUnitPrice;

    [Column('currency')]
    [MaxLength(3)]
    property Currency: string read FCurrency write FCurrency;

    [Column('acc_account_code')]
    [MaxLength(16)]
    property AccAccountCode: string read FAccAccountCode write FAccAccountCode;

    [NotMapped]
    property UomCode: string read FUomCode write FUomCode;

    [NotMapped]
    property AccountName: string read FAccountName write FAccountName;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TPrdLabour;
  end;

implementation

constructor TPrdLabour.Create;
begin
  inherited;
end;

destructor TPrdLabour.Destroy;
begin
  inherited;
end;

function TPrdLabour.Clone: TPrdLabour;
begin
  Result := TPrdLabour.Create;
  Result.Id := Self.Id;
  Result.Code := Self.Code;
  Result.Name := Self.Name;
  Result.CostType := Self.CostType;
  Result.SysUomId := Self.SysUomId;
  Result.UnitPrice := Self.UnitPrice;
  Result.Currency := Self.Currency;
  Result.AccAccountCode := Self.AccAccountCode;
  Result.UomCode := Self.UomCode;
  Result.AccountName := Self.AccountName;
end;

end.
