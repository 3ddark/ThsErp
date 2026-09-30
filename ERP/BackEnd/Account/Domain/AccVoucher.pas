unit AccVoucher;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('acc_voucher')]
  TAccVoucher = class(TEntity)
  private
    FJournalNo: Integer;
    FJournalDate: TDate;
  public
    [Column('journal_no')]
    property JournalNo: Integer read FJournalNo write FJournalNo;

    [Column('journal_date')]
    property JournalDate: TDate read FJournalDate write FJournalDate;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TAccVoucher;
  end;

implementation

constructor TAccVoucher.Create;
begin
  inherited;
end;

destructor TAccVoucher.Destroy;
begin
  inherited;
end;

function TAccVoucher.Clone: TAccVoucher;
begin
  Result := TAccVoucher.Create;
  Result.Id := Self.Id;
  Result.JournalNo := Self.JournalNo;
  Result.JournalDate := Self.JournalDate;
end;

end.
