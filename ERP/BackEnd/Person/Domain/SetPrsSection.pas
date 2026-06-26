unit SetPrsSection;

interface

{$I Ths.inc}

uses
  System.SysUtils, Entity, EntityAttributes;

type
  [Table('set_prs_sections')]
  TSetPrsSection = class(TEntity)
  private
    FSectionName: string;
  public
    [Column('section_name')]
    Property SectionName: string read FSectionName write FSectionName;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSetPrsSection.Create();
begin
  inherited;
end;

destructor TSetPrsSection.Destroy;
begin

  inherited;
end;

end.
