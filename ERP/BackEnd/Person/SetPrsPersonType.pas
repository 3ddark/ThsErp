unit SetPrsPersonType;

interface

{$I Ths.inc}

uses
  System.SysUtils, Entity, EntityAttributes;

type
  [Table('set_prs_person_types')]
  TSetPrsPersonType = class(TEntity)
  private
    FPersonType: string;
  public
    [Column('person_type')]
    Property PersonType: string read FPersonType write FPersonType;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSetPrsPersonType.Create;
begin
  inherited;
end;

destructor TSetPrsPersonType.Destroy;
begin

  inherited;
end;

end.
