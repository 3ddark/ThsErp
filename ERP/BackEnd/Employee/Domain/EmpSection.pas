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

end.