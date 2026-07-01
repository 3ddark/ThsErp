unit AccTransferCode;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('acc_transfer_code')]
  TAccTransferCode = class(TEntity)
  private
    FTransferCode: string;
    FDescription: string;
    FAccount: string;
  public
    [Column('transfer_code'), MaxLength(32), Required()]
    property TransferCode: string read FTransferCode write FTransferCode;

    [Column('description'), MaxLength(128), Required()]
    property Description: string read FDescription write FDescription;

    [Column('account'), MaxLength(16), Required()]
    property Account: string read FAccount write FAccount;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TAccTransferCode.Create();
begin
  inherited;
end;

destructor TAccTransferCode.Destroy;
begin
  inherited;
end;

end.
