unit AccVoucher;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('acc_voucher')]
  TAccVoucher = class(TEntity)
  private
    FJournalNo: Integer;
    FJournalDate: TDateTime;
  public
    [Column('journal_no'), Required()]
    property JournalNo: Integer read FJournalNo write FJournalNo;

    [Column('journal_date')]
    property JournalDate: TDateTime read FJournalDate write FJournalDate;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TAccVoucher.Create();
begin
  inherited;
end;

destructor TAccVoucher.Destroy;
begin
  inherited;
end;

end.
