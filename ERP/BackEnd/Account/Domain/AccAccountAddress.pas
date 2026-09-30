unit AccAccountAddress;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('acc_account_address')]
  TAccAccountAddress = class(TEntity)
  private
    FAccAccountId: Int64;
    FSysAddressId: Int64;
    FAddressType: string;
    FIsPrimary: Boolean;
    FValidFrom: TDate;
    FValidTo: TDate;

    // View (vw_acc_account_address) okunabilir alanları
    FAccountName: string;
    FAddressText: string;
    FAccountCode: string;
  public
    [Column('acc_account_id')]
    property AccAccountId: Int64 read FAccAccountId write FAccAccountId;

    [Column('sys_address_id')]
    property SysAddressId: Int64 read FSysAddressId write FSysAddressId;

    [Column('address_type')]
    [MaxLength(16), Required(TLangKeys.TValidation.Required, True)]
    property AddressType: string read FAddressType write FAddressType;

    [Column('is_primary')]
    property IsPrimary: Boolean read FIsPrimary write FIsPrimary;

    [Column('valid_from')]
    property ValidFrom: TDate read FValidFrom write FValidFrom;

    [Column('valid_to')]
    property ValidTo: TDate read FValidTo write FValidTo;

    [NotMapped]
    property AccountName: string read FAccountName write FAccountName;

    [NotMapped]
    property AddressText: string read FAddressText write FAddressText;

    [NotMapped]
    property AccountCode: string read FAccountCode write FAccountCode;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TAccAccountAddress;
  end;

implementation

constructor TAccAccountAddress.Create;
begin
  inherited;
end;

destructor TAccAccountAddress.Destroy;
begin
  inherited;
end;

function TAccAccountAddress.Clone: TAccAccountAddress;
begin
  Result := TAccAccountAddress.Create;
  Result.Id := Self.Id;
  Result.AccAccountId := Self.AccAccountId;
  Result.SysAddressId := Self.SysAddressId;
  Result.AddressType := Self.AddressType;
  Result.IsPrimary := Self.IsPrimary;
  Result.ValidFrom := Self.ValidFrom;
  Result.ValidTo := Self.ValidTo;
  Result.AccountName := Self.AccountName;
  Result.AddressText := Self.AddressText;
  Result.AccountCode := Self.AccountCode;
end;

end.
