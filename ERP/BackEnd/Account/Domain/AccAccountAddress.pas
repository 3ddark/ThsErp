unit AccAccountAddress;

interface

{$I Ths.inc}

uses
  System.SysUtils, Entity, EntityAttributes, AccAccount, SysAddress;

type
  [Table('acc_account_address')]
  TAccAccountAddress = class(TEntity)
  private
    FAccountId: Int64;
    FAccount: TAccAccount;
    FAddressId: Int64;
    FAddress: TSysAddress;
    FAddressType: string;
    FIsPrimary: Boolean;
    FValidFrom: TDate;
    FValidTo: TDate;
  public
    [Column('account_id')]
    property AccountId: Int64 read FAccountId write FAccountId;

    [BelongsTo('AccountId')]
    property Account: TAccAccount read FAccount write FAccount;

    [Column('address_id')]
    property AddressId: Int64 read FAddressId write FAddressId;

    [BelongsTo('AddressId')]
    property Address: TSysAddress read FAddress write FAddress;

    [Column('address_type')]
    property AddressType: string read FAddressType write FAddressType;

    [Column('is_primary')]
    property IsPrimary: Boolean read FIsPrimary write FIsPrimary;

    [Column('valid_from')]
    property ValidFrom: TDate read FValidFrom write FValidFrom;

    [Column('valid_to')]
    property ValidTo: TDate read FValidTo write FValidTo;
  end;

implementation

end.
