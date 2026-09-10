unit EmpSection;

interface

{$I Ths.inc}

uses
  System.SysUtils, Entity, EntityAttributes;

type
  [Table('emp_section')]
  TEmpSection = class(TEntity)
  private
    FSectionName: string;
  public
    [Column('section_name')]
    Property SectionName: string read FSectionName write FSectionName;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TEmpSection;
  end;

implementation

constructor TEmpSection.Create();
begin
  inherited;
end;

destructor TEmpSection.Destroy;
begin

  inherited;
end;

function TEmpSection.Clone: TEmpSection;
begin
  Result := TEmpSection.Create;
  Result.SectionName := Self.SectionName;
end;

end.