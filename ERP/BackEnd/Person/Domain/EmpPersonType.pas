unit EmpPersonType;

interface

{$I Ths.inc}

uses
  System.SysUtils, Entity, EntityAttributes;

type
  [Table('emp_person_types')]
  TEmpPersonType = class(TEntity)
  private
    FPersonType: string;
  public
    [Column('person_type')]
    Property PersonType: string read FPersonType write FPersonType;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TEmpPersonType.Create;
begin
  inherited;
end;

destructor TEmpPersonType.Destroy;
begin

  inherited;
end;

end.