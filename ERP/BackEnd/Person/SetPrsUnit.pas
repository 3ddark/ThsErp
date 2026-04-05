unit SetPrsUnit;

interface

{$I Ths.inc}

uses
  System.SysUtils, Entity, EntityAttributes, SetPrsSection;

type
  [Table('set_prs_units')]
  TSetPrsUnit = class(TEntity)
  private
    FSectionId: Int64;
    FUnitName: string;
    FSection: TSetPrsSection;
  public
    [Column('section_id')]
    Property SectionId: Int64 read FSectionId write FSectionId;

    [Column('unit_name')]
    Property UnitName_: string read FUnitName write FUnitName;

    [BelongsTo('SectionId')]
    Property Section: TSetPrsSection read FSection write FSection;

    destructor Destroy; override;
    constructor Create(); override;
  end;

implementation

constructor TSetPrsUnit.Create();
begin
  inherited;
end;

destructor TSetPrsUnit.Destroy;
begin
  inherited;
end;

end.
