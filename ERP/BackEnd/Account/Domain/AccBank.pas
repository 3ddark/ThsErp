unit AccBank;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('acc_bank')]
  TAccBank = class(TEntity)
  private
    FBankName: string;
    FSwiftCode: string;
  public
    [Column('bank_name')]
    [MaxLength(128), Required(TLangKeys.TValidation.Required, True)]
    property BankName: string read FBankName write FBankName;

    [Column('swift_code')]
    [MaxLength(16)]
    property SwiftCode: string read FSwiftCode write FSwiftCode;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TAccBank;
  end;

implementation

constructor TAccBank.Create;
begin
  inherited;
end;

destructor TAccBank.Destroy;
begin
  inherited;
end;

function TAccBank.Clone: TAccBank;
begin
  Result := TAccBank.Create;
  Result.Id := Self.Id;
  Result.BankName := Self.BankName;
  Result.SwiftCode := Self.SwiftCode;
end;

end.
