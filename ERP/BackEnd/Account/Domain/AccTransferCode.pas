unit AccTransferCode;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('acc_transfer_code')]
  TAccTransferCode = class(TEntity)
  private
    FTransferCode: string;
    FDescription: string;
    FAccount: string;

    // View (vw_acc_transfer_code) okunabilir alanları
    FAccountName: string;
  public
    [Column('transfer_code')]
    [MaxLength(32), Required(TLangKeys.TValidation.Required, True)]
    property TransferCode: string read FTransferCode write FTransferCode;

    [Column('description')]
    [MaxLength(128), Required(TLangKeys.TValidation.Required, True)]
    property Description: string read FDescription write FDescription;

    [Column('account')]
    [MaxLength(16), Required(TLangKeys.TValidation.Required, True)]
    property Account: string read FAccount write FAccount;

    [NotMapped]
    property AccountName: string read FAccountName write FAccountName;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TAccTransferCode;
  end;

implementation

constructor TAccTransferCode.Create;
begin
  inherited;
end;

destructor TAccTransferCode.Destroy;
begin
  inherited;
end;

function TAccTransferCode.Clone: TAccTransferCode;
begin
  Result := TAccTransferCode.Create;
  Result.Id := Self.Id;
  Result.TransferCode := Self.TransferCode;
  Result.Description := Self.Description;
  Result.Account := Self.Account;
  Result.AccountName := Self.AccountName;
end;

end.
