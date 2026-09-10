unit EmpPersonType;

interface

{$I Ths.inc}

uses
  System.SysUtils, Entity, EntityAttributes;

type
  [Table('emp_person_type')]
  TEmpPersonType = class(TEntity)
  private
    FPersonType: string;
  public
    [Column('person_type')]
    Property PersonType: string read FPersonType write FPersonType;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TEmpPersonType;
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

function TEmpPersonType.Clone: TEmpPersonType;
begin
  Result := TEmpPersonType.Create;
  Result.PersonType := Self.PersonType;
end;

end.